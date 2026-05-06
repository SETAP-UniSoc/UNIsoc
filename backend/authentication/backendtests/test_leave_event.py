from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Event, Society, EventRSVP
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

        self.society = Society.objects.create(name="Test Society")

        self.event = Event.objects.create(
            society=self.society,
            title="Test Event",
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=self.user,
            status="upcoming"
        )

        # 🔥 IMPORTANT: ensure RSVP exists in correct state
        self.rsvp = EventRSVP.objects.create(
            user=self.user,
            event=self.event,
            rsvp_status="attending"
        )

        self.url = reverse("leave-event", args=[self.event.id])

    def test_leave_event_success(self):
        # sanity check before request
        self.assertTrue(
            EventRSVP.objects.filter(user=self.user, event=self.event).exists()
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        print(response.data)  # 🔥 remove after debugging

        self.assertIn(response.status_code, [200, 204])

        self.assertFalse(
            EventRSVP.objects.filter(user=self.user, event=self.event).exists()
        )

    def test_leave_event_without_auth(self):
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, 401)

    def test_leave_event_not_joined(self):
        self.rsvp.delete()

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)