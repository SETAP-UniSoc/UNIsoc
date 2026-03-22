from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import NotificationPreference, Society, Membership
from rest_framework.permissions import IsAuthenticated

class NotificationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        preferences = NotificationPreference.objects.filter(user=user)
        data = []
        for pref in preferences:
            data.append({
                "society": pref.society.name,
                "event_notifications": pref.event_notifications
            })
        return Response(data)

    def post(self, request):
        user = request.user
        society_id = request.data.get("society_id")
        event_notifications = bool(request.data.get("event_notifications"))

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        if not Membership.objects.filter(user=user, society=society).exists():
            return Response({"error": "Not a member of this society"}, status=403)

        pref, created = NotificationPreference.objects.update_or_create(
            user=user,
            society=society,
            defaults={
                "event_notifications": event_notifications
            }
        )

        return Response({
            "message": "Notification preferences updated",
            "society": society.name,
            "event_notifications": pref.event_notifications,
            "news_notifications": pref.news_notifications
        })