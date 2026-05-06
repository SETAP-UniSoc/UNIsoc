from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society, Membership

User = get_user_model()


class LeaveSocietyTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        self.membership = Membership.objects.create(
            user=self.user,
            society=self.society,
            role="member"
        )

        self.url = reverse("leave-society", args=[self.society.id])

    def test_leave_society_success(self):
        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        # allow both common DRF behaviours
        self.assertIn(response.status_code, [200, 204])

        self.assertFalse(
            Membership.objects.filter(
                user=self.user,
                society=self.society
            ).exists()
        )

    def test_leave_without_auth_fails(self):
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, 401)

    def test_leave_when_not_member(self):
        self.membership.delete()

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)