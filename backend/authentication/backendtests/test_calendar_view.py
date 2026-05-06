from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.utils import timezone
from datetime import timedelta

from authentication.models import Society, Event, Membership

User = get_user_model()

class MyEventsViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )
        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        # ✅ IMPORTANT: user must be a member to see events
        self.membership = Membership.objects.create(
            user=self.user,
            society=self.society
        )

        self.event = Event.objects.create(
            title="Test Event",
            society=self.society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=self.user
        )

    def test_get_my_events_success(self):
        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_get_my_events_without_auth_fails(self):
        url = reverse("my-events")

        response = self.client.get(url)

        self.assertEqual(response.status_code, 401)

    def test_my_events_response_contains_events(self):
        url = reverse("my-events")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertTrue(len(response.data) > 0)

