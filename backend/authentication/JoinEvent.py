from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import EventAttendance, Society, Membership, Event

class JoinEventView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, event_id):

        try:
            event = Event.objects.get(id=event_id)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=404)

        # prevent joining past events
        if event.event_date < timezone.now():
            return Response(
                {"error": "Event has already passed"},
                status=400
            )

        attendance, created = EventAttendance.objects.get_or_create(
            user=request.user,
            event=event,
            defaults={"left_at": None}
        )

        if not created:
            if attendance.left_at is None:
                return Response({"message": "Already attending"}, status=400)
            else:
                attendance.left_at = None
                attendance.joined_at = timezone.now()
                attendance.save()

        attendee_count = EventAttendance.objects.filter(
            event=event,
            left_at__isnull=True
        ).count()

        return Response({
            "message": "Joined event",
            "attendee_count": attendee_count
        })