from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society, Event, Membership, EventRSVP

User = get_user_model()


class AnalyticsViewTests(APITestCase):

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
            name="Test Event",
            society=self.society
        )

        Membership.objects.create(
            user=self.user,
            society=self.society
        )

        EventRSVP.objects.create(
            user=self.user,
            event=self.event
        )

    def test_get_analytics_success(self):
        url = reverse("analytics")  # change this if your urls.py uses a different name

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
        self.assertTrue(len(response.data) > 0)