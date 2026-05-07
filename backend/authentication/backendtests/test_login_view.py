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
    
    def test_login_with_invalid_email_fails(self):

        response = self.client.post(reverse("login"), {
            "email": "wrong@uni.ac.uk",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")


    def test_login_without_email_or_up_number_fails(self):

        response = self.client.post(reverse("login"), {
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            response.data["error"],
            "Email or UP number required"
        )


    def test_login_with_up_number_success(self):

        self.user.up_number = "up1234567"
        self.user.save()

        response = self.client.post(reverse("login"), {
            "up_number": "up1234567",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 200)

        self.assertTrue(
            "token" in response.data or "auth_token" in response.data
        )


    def test_login_with_wrong_up_number_fails(self):

        response = self.client.post(reverse("login"), {
            "up_number": "up9999999",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.data["error"], "Invalid credentials")


    def test_admin_login_without_correct_society_fails(self):

        admin_user = User.objects.create_user(
            email="admin@uni.ac.uk",
            password="Password123!",
            role="admin"
        )

        from authentication.models import Society

        Society.objects.create(
            name="Admin Society",
            admin=admin_user
        )

        response = self.client.post(reverse("login"), {
            "email": "admin@uni.ac.uk",
            "password": "Password123!",
            "society_id": 999
        })

        self.assertEqual(response.status_code, 403)
        self.assertEqual(
            response.data["error"],
            "Invalid society selection"
        )


    def test_admin_login_success(self):

        admin_user = User.objects.create_user(
            email="admin2@uni.ac.uk",
            password="Password123!",
            role="admin"
        )

        from authentication.models import Society

        society = Society.objects.create(
            name="Chess Society",
            admin=admin_user
        )

        response = self.client.post(reverse("login"), {
            "email": "admin2@uni.ac.uk",
            "password": "Password123!",
            "society_id": society.id
        })

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["role"], "admin")
        self.assertEqual(response.data["society_name"], "Chess Society")

    
    def test_login_email_case_insensitive(self):

        response = self.client.post(reverse("login"), {
            "email": "TEST@UNI.AC.UK",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 200)


    def test_login_up_number_auto_adds_prefix(self):

        self.user.up_number = "up1234567"
        self.user.save()

        response = self.client.post(reverse("login"), {
            "up_number": "1234567",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 200)


    def test_admin_without_society_cannot_login(self):

        admin_user = User.objects.create_user(
            email="nosociety@uni.ac.uk",
            password="Password123!",
            role="admin"
        )

        response = self.client.post(reverse("login"), {
            "email": "nosociety@uni.ac.uk",
            "password": "Password123!",
            "society_id": 1
        })

        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            response.data["error"],
            "Admin has no assigned society"
        )


    def test_login_returns_user_details(self):

        self.user.up_number = "up1234567"
        self.user.save()

        response = self.client.post(reverse("login"), {
            "email": "test@uni.ac.uk",
            "password": "Password123!"
        })

        self.assertEqual(response.status_code, 200)

        self.assertIn("email", response.data)
        self.assertIn("role", response.data)
        self.assertIn("up_number", response.data)