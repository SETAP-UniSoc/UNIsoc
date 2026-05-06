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
        self.assertIn("token", response.data)
        self.assertEqual(response.data["email"], "test@uni.ac.uk")

    def test_missing_password_returns_error(self):
        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk"
        })

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Email and password required")

    def test_wrong_password_returns_invalid_credentials(self):
        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk",
            "password": "WrongPassword"
        })

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")