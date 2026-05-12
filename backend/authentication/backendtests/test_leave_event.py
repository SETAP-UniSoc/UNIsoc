from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import (
    Event,
    Society,
    EventAttendance
)
from django.utils import timezone
from datetime import timedelta

User = get_user_model()


class LeaveEventTests(APITestCase):

    def setUp(self):

        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            start_time=timezone.now() + timedelta(hours=1),
            end_time=timezone.now() + timedelta(hours=3),
            created_by=self.user
        )

        self.attendance = EventAttendance.objects.create(
            user=self.user,
            event=self.event
        )

        self.url = reverse("leave-event", args=[self.event.id])

    def test_leave_event_success(self):

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        self.attendance.refresh_from_db()

        self.assertIsNotNone(self.attendance.left_at)

    def test_leave_event_without_auth(self):

        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 401)

    def test_leave_event_not_attending(self):

        self.attendance.left_at = timezone.now()
        self.attendance.save()

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)

    def test_leave_event_returns_success_message(self):

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        self.assertEqual(
            response.data["message"],
            "Left event successfully"
        )


    def test_leave_event_sets_left_at_timestamp(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.attendance.refresh_from_db()

        self.assertIsNotNone(self.attendance.left_at)


    def test_leave_event_does_not_delete_attendance(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        exists = EventAttendance.objects.filter(
            id=self.attendance.id
        ).exists()

        self.assertTrue(exists)


    def test_leave_event_twice_returns_400(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)


    def test_leave_nonexistent_event_returns_400(self):

        url = reverse("leave-event", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        # current backend returns 400 because attendance lookup fails
        self.assertEqual(response.status_code, 400)


    def test_leave_event_marks_user_inactive(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        active_exists = EventAttendance.objects.filter(
            user=self.user,
            event=self.event,
            left_at__isnull=True
        ).exists()

        self.assertFalse(active_exists)


    def test_leave_event_only_affects_current_user(self):

        second_user = User.objects.create_user(
            email="second@uni.ac.uk",
            password="Password123!"
        )

        second_attendance = EventAttendance.objects.create(
            user=second_user,
            event=self.event
        )

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        second_attendance.refresh_from_db()

        self.assertIsNone(second_attendance.left_at)


    def test_leave_event_updates_active_attendee_count(self):

        second_user = User.objects.create_user(
            email="second@uni.ac.uk",
            password="Password123!"
        )

        EventAttendance.objects.create(
            user=second_user,
            event=self.event
        )

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        active_count = EventAttendance.objects.filter(
            event=self.event,
            left_at__isnull=True
        ).count()

        self.assertEqual(active_count, 1)