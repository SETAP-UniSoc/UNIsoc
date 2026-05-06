from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model

User = get_user_model()


class LoginTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

    def test_valid_login_returns_token(self):
        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 200)

        # token can be under different keys depending on implementation
        self.assertTrue(
            "token" in response.data or "auth_token" in response.data
        )

    def test_missing_password_returns_error(self):
        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk"
        })

        self.assertEqual(response.status_code, 400)

        self.assertTrue(
            "error" in response.data
            or "detail" in response.data
            or "message" in response.data
        )

    def test_wrong_password_returns_invalid_credentials(self):
        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk",
            "password": "WrongPassword"
        })

        self.assertIn(response.status_code, [400, 401])

        self.assertTrue(
            "error" in response.data
            or "detail" in response.data
            or "message" in response.data
        )