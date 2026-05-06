from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society

User = get_user_model()


class JoinSocietyTests(APITestCase):

    def setUp(self):
        # create user
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        # create token
        self.token = Token.objects.create(user=self.user)

        # create society
        self.society = Society.objects.create(
            name="Test Society"
        )

    def test_join_society_success(self):
        url = reverse("join_soc")  # adjust if your URL name is different

        response = self.client.post(
            url,
            {"society_id": self.society.id},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_join_society_without_auth_fails(self):
        url = reverse("join_soc")

        response = self.client.post(
            url,
            {"society_id": self.society.id}
        )

        self.assertEqual(response.status_code, 401)

    def test_join_nonexistent_society(self):
        url = reverse("join_soc")

        response = self.client.post(
            url,
            {"society_id": 999},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)