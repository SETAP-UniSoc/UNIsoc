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

    def test_join_society_returns_success_message(self):

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 201)

        self.assertEqual(
            response.data["message"],
            "Joined successfully"
        )


    def test_join_nonexistent_society_returns_correct_error(self):

        url = reverse("join-society", args=[999])

        response = self.client.post(
            url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 404)

        self.assertEqual(
            response.data["error"],
            "Society not found"
        )


    def test_rejoin_society_restores_active_membership(self):

        membership = Membership.objects.create(
            user=self.user,
            society=self.society,
            left_at=timezone.now()
        )

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        membership.refresh_from_db()

        self.assertIsNone(membership.left_at)


    def test_rejoin_society_updates_joined_at(self):

        membership = Membership.objects.create(
            user=self.user,
            society=self.society,
            left_at=timezone.now()
        )

        old_joined_at = membership.joined_at

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        membership.refresh_from_db()

        self.assertNotEqual(
            membership.joined_at,
            old_joined_at
        )


    def test_only_one_active_membership_exists(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        response = self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

        active_memberships = Membership.objects.filter(
            user=self.user,
            society=self.society,
            left_at__isnull=True
        ).count()

        self.assertEqual(active_memberships, 1)


    def test_rejoin_does_not_create_new_membership(self):

        membership = Membership.objects.create(
            user=self.user,
            society=self.society,
            left_at=timezone.now()
        )

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        total_memberships = Membership.objects.filter(
            user=self.user,
            society=self.society
        ).count()

        self.assertEqual(total_memberships, 1)


    def test_membership_is_active_after_join(self):

        self.client.post(
            self.url,
            {},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        membership = Membership.objects.get(
            user=self.user,
            society=self.society
        )

        self.assertIsNone(membership.left_at)