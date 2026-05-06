from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import NotificationPreference

User = get_user_model()


class NotificationPreferenceTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )
        self.token = Token.objects.create(user=self.user)

    def test_update_notification_preferences(self):
        url = reverse("notification_preferences")  # adjust if needed

        response = self.client.post(
            url,
            {
                "email_notifications": True,
                "push_notifications": False
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_update_without_auth(self):
        url = reverse("notification_preferences")

        response = self.client.post(
            url,
            {
                "email_notifications": True
            }
        )

        self.assertEqual(response.status_code, 401)

    def test_get_notification_preferences(self):
        NotificationPreference.objects.create(
            user=self.user,
            email_notifications=True,
            push_notifications=True
        )

        url = reverse("notification_preferences")

        response = self.client.get(
            url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)