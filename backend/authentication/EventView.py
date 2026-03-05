from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import Event, Society

class EventListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):  #gets all eventts for socities doesnt include canceled and removed events 
        events = Event.objects.filter(
            society_id=society_id
        ).exclude(status='cancelled')
        
        data = [{
            "id": e.id,
            "title": e.title,
            "description": e.description,
            "location": e.location,
            "start_time": e.start_time,
            "end_time": e.end_time,
            "capacity_limit": e.capacity_limit,
            "status": e.status,
            "attendee_count": e.rsvps.filter(rsvp_status='attending').count()
        } for e in events]

        return Response(data)

    def post(self, request, society_id):
        if request.user.role != 'admin':
            return Response(
                {"error": "Admin only"},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        data = request.data

        event = Event.objects.create(
            society=society,
            title=data.get("title"),
            description=data.get("description", ""),
            location=data.get("location", ""),
            start_time=data.get("start_time"),
            end_time=data.get("end_time"),
            capacity_limit=data.get("capacity_limit"),
            created_by=request.user,
        )

        return Response({
            "id": event.id,
            "title": event.title,
            "message": "Event created successfully"
        }, status=status.HTTP_201_CREATED)


class EventDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, event_id):
        if request.user.role != 'admin':
            return Response(
                {"error": "Admin only"},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            event = Event.objects.get(id=event_id)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=404)

        event.status = 'cancelled'
        event.save()

        return Response({"message": "Event removed"}, status=200)