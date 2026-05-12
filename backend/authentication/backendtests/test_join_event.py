from urllib import response

from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import (
    Event,
    Society,
    Membership,
    EventAttendance
)
from django.utils import timezone
from datetime import timedelta

User = get_user_model()


class JoinEventTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(name="Test Society")

        Membership.objects.create(
            user=self.user,
            society=self.society,
            role="member"
        )

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            start_time=timezone.now() + timedelta(hours=1),
            end_time=timezone.now() + timedelta(hours=3),
            created_by=self.user,
            status="upcoming"
        )

        self.url = reverse("join-event", args=[self.event.id])

    def test_join_event_success(self):

        response = self.client.post(
        self.url,
        {},
        HTTP_AUTHORIZATION=f"Token {self.token.key}"
    )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Joined event")

        self.assertTrue(
            EventAttendance.objects.filter(
                user=self.user,
                event=self.event,
                left_at__isnull=True
            ).exists()
     )

    def test_join_event_without_auth(self):
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, 401)

    def test_join_nonexistent_event(self):
        url = reverse("join-event", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)

    def test_join_event_twice_returns_already_attending(self):

        EventAttendance.objects.create(
            user=self.user,
            event=self.event
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["message"], "Already attending")


    def test_cannot_join_past_event(self):

        past_event = Event.objects.create(
            society=self.society,
            title="Past Event",
            start_time=timezone.now() - timedelta(days=1),
            end_time=timezone.now() - timedelta(hours=1),
            created_by=self.user
        )

        url = reverse("join-event", args=[past_event.id])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            response.data["error"],
            "Event has already passed"
        )


    def test_rejoin_event_after_leaving(self):

        attendance = EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=timezone.now()
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        attendance.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertIsNone(attendance.left_at)

    def test_join_event_returns_attendee_count(self):

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        self.assertIn("attendee_count", response.data)
        self.assertEqual(response.data["attendee_count"], 1)


    def test_multiple_users_join_event_count_updates_correctly(self):

        second_user = User.objects.create_user(
            email="second@uni.ac.uk",
            password="Password123!"
        )

        second_token = Token.objects.create(user=second_user)

        Membership.objects.create(
            user=second_user,
            society=self.society,
            role="member"
        )

        # first user joins
        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        # second user joins
        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {second_token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["attendee_count"], 2)


    def test_rejoin_event_updates_attendee_count_correctly(self):

        EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=timezone.now()
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["attendee_count"], 1)


    def test_join_event_creates_only_one_active_attendance(self):

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

        active_count = EventAttendance.objects.filter(
            user=self.user,
            event=self.event,
            left_at__isnull=True
        ).count()

        self.assertEqual(active_count, 1)


    def test_join_event_reactivates_existing_attendance(self):

        attendance = EventAttendance.objects.create(
            user=self.user,
            event=self.event,
            left_at=timezone.now()
        )

        old_joined_at = attendance.joined_at

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        attendance.refresh_from_db()

        self.assertIsNone(attendance.left_at)
        self.assertNotEqual(attendance.joined_at, old_joined_at)


    def test_join_event_response_contains_message(self):

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        self.assertIn("message", response.data)
        self.assertEqual(response.data["message"], "Joined event")


    def test_join_nonexistent_event_returns_correct_error(self):

        url = reverse("join-event", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["error"], "Event not found")


    def test_join_past_event_does_not_create_attendance(self):

        past_event = Event.objects.create(
            society=self.society,
            title="Old Event",
            start_time=timezone.now() - timedelta(days=1),
            end_time=timezone.now() - timedelta(hours=2),
            created_by=self.user
        )

        url = reverse("join-event", args=[past_event.id])

        self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        exists = EventAttendance.objects.filter(
            user=self.user,
            event=past_event
        ).exists()

        self.assertFalse(exists)