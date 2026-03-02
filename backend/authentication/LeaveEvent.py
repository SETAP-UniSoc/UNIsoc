from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import Society, Membership
from .models import EventAttendance

class LeaveEventView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, event_id):
        try:
            attendance = EventAttendance.objects.get(
                user=request.user,
                event_id=event_id,
                left_at__isnull=True
            )
        except EventAttendance.DoesNotExist:
            return Response({"error": "Not attending this event"}, status=400)

        attendance.left_at = timezone.now()
        attendance.save()

        attendee_count = EventAttendance.objects.filter(
            event_id=event_id, 
            left_at__isnull=True).count()

        return Response({"message": "Left event successfully"})