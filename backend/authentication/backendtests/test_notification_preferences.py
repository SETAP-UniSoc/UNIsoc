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

        self.url = reverse("notifications")

    def test_update_notification_preferences(self):
        response = self.client.post(
            self.url,
            {
                "notify_new_events": False,
                "notify_cancellations": True,
                "notify_event_created": False,
                "notify_24hr_reminder": True
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_update_without_auth(self):
        response = self.client.post(
            self.url,
            {
                "notify_new_events": True
            }
        )

        self.assertEqual(response.status_code, 401)

    def test_get_notification_preferences(self):
        NotificationPreference.objects.create(
            user=self.user,
            society_id=1,  # ⚠️ required FK in your model
            notify_new_events=True,
            notify_cancellations=True,
            notify_event_created=True,
            notify_24hr_reminder=True
        )

        response = self.client.get(
            self.url,
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)