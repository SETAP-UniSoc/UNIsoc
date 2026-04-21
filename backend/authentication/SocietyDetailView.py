from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Society, Event

class SocietyDetailView(APIView):
    def get(self, request, society_id):
        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        events = Event.objects.filter(society=society)

        event_data = []
        for event in events:
            event_data.append({
                "id": event.id,
                "title": event.title,
                "description": event.description,
                "location": event.location,
                "start_time": event.start_time,
            })

        return Response({
            "id": society.id,
            "name": society.name,
            "category": society.category,
            "description": society.description,
            "events": event_data
        })