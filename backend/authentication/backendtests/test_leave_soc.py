from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society, Membership

User = get_user_model()


class LeaveSocietyTests(APITestCase):

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

        # make user a member first
        self.membership = Membership.objects.create(
            user=self.user,
            society=self.society
        )

    def test_leave_society_success(self):
        url = reverse("leave_soc")  # adjust if needed

        response = self.client.post(
            url,
            {"society_id": self.society.id},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_leave_without_auth_fails(self):
        url = reverse("leave_soc")

        response = self.client.post(
            url,
            {"society_id": self.society.id}
        )

        self.assertEqual(response.status_code, 401)

    def test_leave_when_not_member(self):
        # remove membership
        self.membership.delete()

        url = reverse("leave_soc")

        response = self.client.post(
            url,
            {"society_id": self.society.id},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)