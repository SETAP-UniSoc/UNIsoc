from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society

User = get_user_model()

class LoginViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            up_number="up123456",
            password="pass123"
        )
        self.user.role = "member"
        self.user.save()

        self.admin = User.objects.create_user(
            username="admin",
            email="admin@example.com",
            up_number="up999999",
            password="pass123"
        )
        self.admin.role = "admin"
        self.admin.save()

        self.society = Society.objects.create(name="Test Society", admin=self.admin)

        self.url = "/login/"  # adjust

    # --- Missing fields ---

    def test_missing_password_returns_400(self):
        response = self.client.post(self.url, {"email": "test@example.com"})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Password required")

    def test_missing_email_and_up_number_returns_400(self):
        response = self.client.post(self.url, {"password": "pass123"})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Email or UP number required")

    # --- Invalid credentials ---

    def test_wrong_password_returns_401(self):
        response = self.client.post(self.url, {
            "email": "test@example.com",
            "password": "wrongpass"
        })
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")

    def test_nonexistent_email_returns_401(self):
        response = self.client.post(self.url, {
            "email": "nobody@example.com",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")

    def test_nonexistent_up_number_returns_401(self):
        response = self.client.post(self.url, {
            "up_number": "up000000",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")

    # --- Login via email ---

    def test_can_login_with_email(self):
        response = self.client.post(self.url, {
            "email": "test@example.com",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.data)

    def test_email_login_is_case_insensitive(self):
        response = self.client.post(self.url, {
            "email": "TEST@EXAMPLE.COM",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.data)

    # --- Login via up_number ---

    def test_can_login_with_up_number(self):
        response = self.client.post(self.url, {
            "up_number": "up123456",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.data)

    def test_up_number_prepends_up_prefix_if_missing(self):
        response = self.client.post(self.url, {
            "up_number": "123456",  # no "up" prefix
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.data)

    def test_up_number_login_is_case_insensitive(self):
        response = self.client.post(self.url, {
            "up_number": "UP123456",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn("token", response.data)

    # --- Response shape ---

    def test_successful_login_returns_correct_fields(self):
        response = self.client.post(self.url, {
            "email": "test@example.com",
            "password": "pass123"
        })
        for key in ["token", "role", "email", "up_number", "society_id", "society_name"]:
            self.assertIn(key, response.data)

    def test_token_is_created_in_db(self):
        self.client.post(self.url, {
            "email": "test@example.com",
            "password": "pass123"
        })
        self.assertTrue(Token.objects.filter(user=self.user).exists())

    def test_repeated_login_returns_same_token(self):
        r1 = self.client.post(self.url, {"email": "test@example.com", "password": "pass123"})
        r2 = self.client.post(self.url, {"email": "test@example.com", "password": "pass123"})
        self.assertEqual(r1.data["token"], r2.data["token"])

    # --- Society fields ---

    def test_admin_login_returns_society_id_and_name(self):
        response = self.client.post(self.url, {
            "email": "admin@example.com",
            "password": "pass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["society_id"], self.society.id)
        self.assertEqual(response.data["society_name"], "Test Society")

    def test_non_admin_login_returns_null_society_fields(self):
        response = sel