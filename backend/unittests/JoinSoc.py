from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from authentication.models import Society, Membership

class JoinSocietyViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="pass123")
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.society = Society.objects.create(name="Test Society", admin=self.admin)
        self.url = lambda society_id: f"/societies/{society_id}/join/"  # adjust

    # --- Auth ---

    def test_unauthenticated_returns_401(self):
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 401)

    # --- Society not found ---

    def test_nonexistent_society_returns_404(self):
        self.client.login(username="testuser", password="pass123")
        response = self.client.post(self.url(9999))
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["error"], "Society not found")

    # --- Joining ---

    def test_can_join_society(self):
        self.client.login(username="testuser", password="pass123")
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["message"], "Successfully joined")

    def test_joining_creates_membership_record(self):
        self.client.login(username="testuser", password="pass123")
        self.client.post(self.url(self.society.id))
        self.assertTrue(Membership.objects.filter(
            user=self.user,
            society=self.society
        ).exists())

    # --- Already joined ---

    def test_cannot_join_twice(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(user=self.user, society=self.society)
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["message"], "Already joined")

    def test_joining_twice_does_not_create_duplicate_membership(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(user=self.user, society=self.society)
        self.client.post(self.url(self.society.id))
        count = Membership.objects.filter(user=self.user, society=self.society).count()
        self.assertEqual(count, 1)

    # --- Multiple users ---

    def test_two_users_can_join_same_society(self):
        user2 = User.objects.create_user(username="user2", password="pass123")
        self.client.login(username="testuser", password="pass123")
        self.client.post(self.url(self.society.id))
        self.client.logout()
        self.client.login(username="user2", password="pass123")
        self.client.post(self.url(self.society.id))
        self.assertEqual(Membership.objects.filter(society=self.society).count(), 2)

    def test_user_can_join_multiple_societies(self):
        society2 = Society.objects.create(name="Second Society", admin=self.admin) # please explain thought process
        self.client.login(username="testuser", password="pass123")
        self.client.post(self.url(self.society.id))
        self.client.post(self.url(society2.id))
        self.assertEqual(Membership.objects.filter(user=self.user).count(), 2)