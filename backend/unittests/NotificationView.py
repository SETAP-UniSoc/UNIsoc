from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from authentication.models import Society, Membership, NotificationPreference

User = get_user_model()

class NotificationViewTests(APITestCase):

    def setUp(self):
        self.user = User.objects.create_user(email="user@test.com", password="pass123")
        self.admin = User.objects.create_user(email="admin@test.com", password="pass123")
        self.admin.role = "admin"
        self.admin.save()

        self.society = Society.objects.create(name="Test Society", admin=self.admin)
        self.other_society = Society.objects.create(name="Other Society", admin=self.admin)

        # user is a member of society but not other_society
        Membership.objects.create(user=self.user, society=self.society)

        self.url = "/notifications/"  # adjust

    # --- Auth ---

    def test_unauthenticated_get_returns_401(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 401)

    def test_unauthenticated_post_returns_401(self):
        response = self.client.post(self.url, {})
        self.assertEqual(response.status_code, 401)

    # --- GET ---

    def test_get_returns_empty_list_when_no_preferences(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, [])

    def test_get_returns_existing_preferences(self):
        NotificationPreference.objects.create(
            user=self.user,
            society=self.society,
            event_notifications=True
        )
        self.client.force_authenticate(user=self.user)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["society"], "Test Society")
        self.assertEqual(response.data[0]["event_notifications"], True)

    def test_get_only_returns_own_preferences(self):
        other_user = User.objects.create_user(email="other@test.com", password="pass123")
        NotificationPreference.objects.create(user=other_user, society=self.society, event_notifications=True)
        NotificationPreference.objects.create(user=self.user, society=self.society, event_notifications=False)
        self.client.force_authenticate(user=self.user)
        response = self.client.get(self.url)
        self.assertEqual(len(response.data), 1)

    # --- POST: validation ---

    def test_nonexistent_society_returns_404(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.url, {
            "society_id": 9999,
            "event_notifications": True
        })
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["error"], "Society not found")

    def test_non_member_cannot_set_preferences(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.url, {
            "society_id": self.other_society.id,  # not a member
            "event_notifications": True
        })
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.data["error"], "Not a member of this society")

    # --- POST: creating preferences ---

    def test_member_can_set_preferences(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.url, {
            "society_id": self.society.id,
            "event_notifications": True
        })
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["message"], "Notification preferences updated")

    def test_preference_is_created_in_db(self):
        self.client.force_authenticate(user=self.user)
        self.client.post(self.url, {
            "society_id": self.society.id,
            "event_notifications": True
        })
        self.assertTrue(NotificationPreference.objects.filter(
            user=self.user,
            society=self.society
        ).exists())

    # --- POST: updating preferences ---

    def test_existing_preference_is_updated_not_duplicated(self):
        self.client.force_authenticate(user=self.user)
        self.client.post(self.url, {"society_id": self.society.id, "event_notifications": True})
        self.client.post(self.url, {"society_id": self.society.id, "event_notifications": False})
        self.assertEqual(NotificationPreference.objects.filter(
            user=self.user,
            society=self.society
        ).count(), 1)

    def test_preference_value_is_updated_correctly(self):
        self.client.force_authenticate(user=self.user)
        self.client.post(self.url, {"society_id": self.society.id, "event_notifications": True})
        self.client.post(self.url, {"society_id": self.society.id, "event_notifications": False})
        pref = NotificationPreference.objects.get(user=self.user, society=self.society)
        self.assertFalse(pref.event_notifications)

    # --- Response shape ---

    def test_post_response_contains_correct_fields(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.url, {
            "society_id": self.society.id,
            "event_notifications": True
        })
        for key in ["message", "society", "event_notifications", "news_notifications"]:
            self.assertIn(key, response.data)


#testing 
