from flask import request
from rest_framework import generics
from .models import User, Event, Society
from .serializer import UserSerializer
from .serializer import SocietySerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from rest_framework.exceptions import PermissionDenied
from .serializer import EventSerializer
from .import serializer



class UserListView(generics.ListAPIView):
    serializer_class = UserSerializer

    def get_queryset(self):
        queryset = User.objects.all().order_by('name')

        search = self.request.query_params.get('search')
        letter = self.request.query_params.get('letter')

        if search:
            queryset = queryset.filter(name__icontains=search)

        if letter:
            queryset = queryset.filter(name__istartswith=letter)

        return queryset
    
class SocietyListView(generics.ListAPIView):
    queryset = Society.objects.all().order_by('name')
    serializer_class = SocietySerializer

class AddEventView(generics.CreateAPIView):
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        if self.request.user.role != "admin":
            raise PermissionDenied("Admins only")

        society = Society.objects.get(admin=self.request.user)

        serializer.save(
            created_by=self.request.user,
            society=society
        )

class DeleteEventView(generics.DestroyAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Event.objects.all()
    lookup_field = 'id'

    def get_queryset(self):
        return Event.objects.filter(created_by=self.request.user)
        

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
    
class SocietyEventView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        events = Event.objects.filter(society=society)
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)
    
    def post(self, request, society_id):
        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        try:
            society = Society.objects.get(id=society_id, admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "Society not found or not admin"}, status=404)

        data = request.data.copy()
        data["society"] = society.id
        data["created_by"] = request.user.id

        serializer = EventSerializer(data=data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)

class EventDetailView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    lookup_field = 'id'

class UpdateEventView(generics.UpdateAPIView):
    permission_classes = [IsAuthenticated]
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    lookup_field = 'id'

    def get_queryset(self):
        return Event.objects.filter(created_by=self.request.user)
    
class MyEventsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role == "admin":
            society = Society.objects.get(admin=request.user)
            events = Event.objects.filter(society=society)
        else:
            events = Event.objects.filter(
                society__membership__user=request.user
            ).distinct()

        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)
    
    
