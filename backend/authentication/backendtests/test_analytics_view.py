from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.utils import timezone
from datetime import timedelta

from authentication.models import Society, Event, Membership, EventAttendance

User = get_user_model()

class AnalyticsViewTests(APITestCase):


    def setUp(self):
        # ✅ Create ADMIN user
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!",
            role="admin"
        )
        self.token = Token.objects.create(user=self.user)

        # ✅ Society MUST have this admin
        self.society = Society.objects.create(
            name="Test Society",
            admin=self.user
        )

        # ✅ Membership (optional but realistic)
        Membership.objects.create(
            user=self.user,
            society=self.society,
            role="admin"
        )

        # ✅ Valid event
        self.event = Event.objects.create(
            title="Test Event",
            society=self.society,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=2),
            created_by=self.user
        )

        # ✅ Attendance (used in analytics)
        EventAttendance.objects.create(
            user=self.user,
            event=self.event
        )

    def test_get_analytics_success(self):
        url = reverse("analytics")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_get_analytics_without_auth_fails(self):
        url = reverse("analytics")

        response = self.client.get(url)

        self.assertEqual(response.status_code, 401)

    def test_analytics_response_contains_data(self):
        url = reverse("analytics")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("labels", response.data)
        self.assertIn("totals", response.data)
        self.assertIn("total_events", response.data)

