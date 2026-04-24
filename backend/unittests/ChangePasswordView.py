from rest_framework.test import APITestCase
from django.contrib.auth.models import User

class ChangePasswordViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="oldpass123")
        self.url = "/change-password/"  # adjust

    # --- Auth ---

    def test_unauthenticated_returns_401(self):
        response = self.client.post(self.url, {})
        self.assertEqual(response.status_code, 401)# --- Missing fields ---

    def test_missing_old_password_returns_400(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {"new_password": "newpass123"})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Both fields are required")

    def test_missing_new_password_returns_400(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {"old_password": "oldpass123"})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Both fields are required")
def test_missing_both_fields_returns_400(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {})
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Both fields are required")

    # --- Wrong old password ---

    def test_incorrect_old_password_returns_400(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {
            "old_password": "wrongpassword",
            "new_password": "newpass123"
        })
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "Current password is incorrect") # --- New password too short ---

    def test_new_password_too_short_returns_400(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {
            "old_password": "oldpass123",
            "new_password": "short"
        })
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "New password must be at least 8 characters")

    def test_new_password_exactly_8_characters_succeeds(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {
            "old_password": "oldpass123",
            "new_password": "exactly8"
        })
        self.assertEqual(response.status_code, 200)
 # --- Success ---

    def test_valid_change_returns_200(self):
        self.client.login(username="testuser", password="oldpass123")
        response = self.client.post(self.url, {
            "old_password": "oldpass123",
            "new_password": "newpass123"
        })
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Password changed successfully")

    def test_password_actually_changes_in_db(self):
        self.client.login(username="testuser", password="oldpass123")
        self.client.post(self.url, {
            "old_password": "oldpass123",
            "new_password": "newpass123"})
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("newpass123"))

    def test_old_password_no_longer_works_after_change(self):
        self.client.login(username="testuser", password="oldpass123")
        self.client.post(self.url, {
            "old_password": "oldpass123",
            "new_password": "newpass123"
        })
        self.user.refresh_from_db()
        self.assertFalse(self.user.check_password("oldpass123"))