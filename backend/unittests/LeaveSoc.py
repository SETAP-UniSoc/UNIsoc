from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from authentication.models import Society, Membership

class LeaveSocietyViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="pass123")
        self.other_user = User.objects.create_user(username="other", password="pass123")
        self.admin = User.objects.create_user(username="admin", password="pass123")
        self.society = Society.objects.create(name="Test Society", admin=self.admin)
        self.url = lambda society_id: f"/societies/{society_id}/leave/"  # adjust

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

    # --- Not a member ---

    def test_cannot_leave_society_never_joined(self):
        self.client.login(username="testuser", password="pass123")
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "You are not an active member")

    def test_cannot_leave_society_already_left(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(
            user=self.user,
            society=self.society,
            left_at=timezone.now() - timedelta(days=1)  # already left
        )
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["error"], "You are not an active member")

    # --- Leaving ---

    def test_can_leave_society(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(user=self.user, society=self.society, left_at=None)
        response = self.client.post(self.url(self.society.id))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Successfully left society")

    def test_leaving_sets_left_at_in_db(self):
        self.client.login(username="testuser", password="pass123")
        membership = Membership.objects.create(user=self.user, society=self.society, left_at=None)
        self.client.post(self.url(self.society.id))
        membership.refresh_from_db()
        self.assertIsNotNone(membership.left_at)

    def test_leaving_does_not_delete_membership_record(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(user=self.user, society=self.society, left_at=None)
        self.client.post(self.url(self.society.id))
        self.assertTrue(Membership.objects.filter(
            user=self.user,
            society=self.society
        ).exists())

    # --- Other users unaffected ---

    def test_leaving_does_not_affect_other_members(self):
        self.client.login(username="testuser", password="pass123")
        Membership.objects.create(user=self.user, society=self.society, left_at=None)
        Membership.objects.create(user=self.other_user, society=self.society, left_at=None)
        self.client.post(self.url(self.society.id))
        other_membership = Membership.objects.get(user=self.other_user, society=self.society)
        self.assertIsNone(other_membership.left_at)