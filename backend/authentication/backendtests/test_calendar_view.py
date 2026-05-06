from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.utils import timezone
from datetime import timedelta
from authentication.models import Society, Event

User = get_user_model()

class CalendarViewTests(APITestCase):

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
            title="Test Event",  # ✅ FIXED
            society=self.society,
            start_time=timezone.now(),  # ✅ REQUIRED
            end_time=timezone.now() + timedelta(hours=2),  # ✅ REQUIRED
            created_by=self.user  # ✅ good practice
        )

    def test_get_calendar_events_success(self):
        url = reverse("calendar")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_get_calendar_events_without_auth_fails(self):
        url = reverse("calendar")

        response = self.client.get(url)

        self.assertEqual(response.status_code, 401)

    def test_calendar_response_contains_events(self):
        url = reverse("calendar")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertTrue(len(response.data) > 0)

