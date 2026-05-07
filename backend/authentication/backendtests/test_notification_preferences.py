from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import (
    NotificationPreference,
    Society,
    Membership
)

User = get_user_model()


class NotificationPreferenceTests(APITestCase):

    def setUp(self):

        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        # REQUIRED because your view checks membership
        Membership.objects.create(
            user=self.user,
            society=self.society
        )

        self.url = reverse("notifications")

    def test_update_notification_preferences(self):

        response = self.client.post(
            self.url,
            {
                "society_id": self.society.id,
                "event_notifications": True
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        pref = NotificationPreference.objects.get(
            user=self.user,
            society=self.society
        )

        self.assertTrue(pref.notify_new_events)

    def test_update_without_auth(self):

        response = self.client.post(
            self.url,
            {
                "society_id": self.society.id,
                "event_notifications": True
            }
        )

        self.assertEqual(response.status_code, 401)

    def test_get_notification_preferences(self):

        NotificationPreference.objects.create(
            user=self.user,
            society=self.society,
            notify_new_events=True
        )

        response = self.client.get(
            self.url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)