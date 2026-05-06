from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.urls import reverse

User = get_user_model()


class ChangePasswordTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="OldPassword123!"
        )
        self.token = Token.objects.create(user=self.user)

        self.url = reverse("change-password")

    def test_change_password_success(self):
        response = self.client.post(
            self.url,
            {
                "old_password": "OldPassword123!",
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("NewPassword123!"))

    def test_change_password_wrong_old_password(self):
        response = self.client.post(
            self.url,
            {
                "old_password": "WrongPassword",
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)

    def test_change_password_without_auth(self):
        response = self.client.post(
            self.url,
            {
                "old_password": "OldPassword123!",
                "new_password": "NewPassword123!"
            }
        )

        self.assertEqual(response.status_code, 401)

    def test_change_password_missing_old_password(self):

        response = self.client.post(
            self.url,
            {
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)


    def test_change_password_missing_new_password(self):

        response = self.client.post(
            self.url,
            {
                "old_password": "OldPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)


    def test_old_password_no_longer_works_after_change(self):

        self.client.post(
            self.url,
            {
                "old_password": "OldPassword123!",
                "new_password": "NewPassword123!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.user.refresh_from_db()

        self.assertFalse(
            self.user.check_password("OldPassword123!")
        )


    def test_new_password_is_saved_correctly(self):

        self.client.post(
            self.url,
            {
                "old_password": "OldPassword123!",
                "new_password": "SecurePass456!"
            },
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.user.refresh_from_db()

        self.assertTrue(
            self.user.check_password("SecurePass456!")
        )