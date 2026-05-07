from time import timezone

from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Society, Membership
from django.utils import timezone

User = get_user_model()


class JoinSocietyTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        self.token = Token.objects.create(user=self.user)

        self.society = Society.objects.create(
            name="Test Society"
        )

        self.url = reverse("join-society", args=[self.society.id])

    def test_join_society_success(self):
        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        # ✔ backend returns CREATED when membership is made
        self.assertEqual(response.status_code, 201)

        # optional: verify DB side effect
        self.assertTrue(
            Membership.objects.filter(
                user=self.user,
                society=self.society
            ).exists()
        )

    def test_join_society_without_auth_fails(self):
        response = self.client.post(self.url)

        self.assertEqual(response.status_code, 401)

    def test_join_nonexistent_society(self):
        url = reverse("join-society", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)
    
    def test_join_society_twice_returns_already_joined(self):

        Membership.objects.create(
            user=self.user,
            society=self.society
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Already joined")


    def test_rejoin_society_after_leaving(self):

        membership = Membership.objects.create(
            user=self.user,
            society=self.society
        )

        membership.left_at = timezone.now()
        membership.save()

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        membership.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Rejoined successfully")
        self.assertIsNone(membership.left_at)


    def test_membership_created_correctly(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        membership = Membership.objects.get(
            user=self.user,
            society=self.society
        )

        self.assertEqual(membership.role, "member")