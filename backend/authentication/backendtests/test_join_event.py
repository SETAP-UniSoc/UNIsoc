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
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
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