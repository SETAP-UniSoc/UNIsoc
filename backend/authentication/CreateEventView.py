from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import Event, Society
from .serializer import EventSerializer
from backend.authentication import serializer

class CreateEventView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):

        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        try:
            society = Society.objects.get(admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "No society found"}, status=404)

        data = request.data.copy()
        data["society"] = society.id
        data["created_by"] = request.user.id

        serializer = EventSerializer(data=data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)
    

class ListEventsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):

            if request.user.role == "admin":
            # Admin sees their own society events
                society = Society.objects.get(admin=request.user)
                events = Event.objects.filter(society=society)

            else:
            # Users see events of societies they belong to
                events = Event.objects.filter(
                    society__membership__user=request.user
                ).distinct()

            serializer = EventSerializer(events, many=True)
            return Response(serializer.data)