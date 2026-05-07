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