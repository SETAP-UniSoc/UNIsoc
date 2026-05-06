from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token

User = get_user_model()

class ChangePasswordTests(APITestCase):


    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="OldPassword123!"
        )
        self.token = Token.objects.create(user=self.user)

    def test_change_password_success(self):
        url = reverse("change_password")

        response = self.client.post(
            url,
            {
                "old_password": "OldPassword123!",
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        # ✅ verify password actually changed
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("NewPassword123!"))

    def test_change_password_wrong_old_password(self):
        url = reverse("change_password")

        response = self.client.post(
            url,
            {
                "old_password": "WrongPassword",
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)

        # ✅ ensure password did NOT change
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("OldPassword123!"))

    def test_change_password_without_auth(self):
        url = reverse("change_password")

        response = self.client.post(
            url,
            {
                "old_password": "OldPassword123!",
                "new_password": "NewPassword123!"
            }
        )

        self.assertEqual(response.status_code, 401)
