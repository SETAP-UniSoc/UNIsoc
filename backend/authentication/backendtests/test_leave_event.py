from django.urls import reverse
from rest_framework.test import APITestCase
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from authentication.models import Event, Society, EventRSVP

User = get_user_model()


class LeaveEventTests(APITestCase):

    def setUp(self):
        # create user
        self.user = User.objects.create_user(
            email="test@uni.ac.uk",
            password="Password123!"
        )

        # token
        self.token = Token.objects.create(user=self.user)

        # society
        self.society = Society.objects.create(name="Test Society")

        # event
        self.event = Event.objects.create(
            name="Test Event",
            society=self.society
        )

        # user is already joined (RSVP)
        self.rsvp = EventRSVP.objects.create(
            user=self.user,
            event=self.event
        )

    def test_leave_event_success(self):
        url = reverse("leave_event")  # adjust if needed

        response = self.client.post(
            url,
            {"event_id": self.event.id},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 200)

    def test_leave_event_without_auth(self):
        url = reverse("leave_event")

        response = self.client.post(
            url,
            {"event_id": self.event.id}
        )

        self.assertEqual(response.status_code, 401)

    def test_leave_event_not_joined(self):
        # remove RSVP first
        self.rsvp.delete()

        url = reverse("leave_event")

        response = self.client.post(
            url,
            {"event_id": self.event.id},
            HTTP_AUTHORIZATION=f"Token {self.token.key}"
        )

        self.assertEqual(response.status_code, 400)