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
from django.utils.timezone import now
from django.db.models import Count, Q
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from django.core.mail import send_mail
from django.utils import timezone
from datetime import timedelta

from .models import NotificationPreference, Society, Membership, Event




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
    
# class SocietyListView(generics.ListAPIView):
#     queryset = Society.objects.all().order_by('name')
#     serializer_class = SocietySerializer

class SocietyListSearchView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get("q", "").strip()

        societies = Society.objects.filter(is_active=True)

        if query:
            societies = societies.filter(name__icontains=query)

        societies = societies.annotate(
            active_member_count=Count(
                'membership',
                filter=Q(membership__left_at__isnull=True)
            )
        ).order_by('name')

        data = [{
            "id": s.id,
            "name": s.name,
            "category": s.category,
            "description": s.description,
            "member_count": s.active_member_count,  # ✅ fixed
        } for s in societies]

        return Response(data)

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
    serializer_class = EventSerializer
    lookup_field = 'id'

    def get_queryset(self):
        return Event.objects.filter(created_by=self.request.user)
        

# class CreateEventView(APIView):
#     permission_classes = [IsAuthenticated]

#     def post(self, request):

#         if request.user.role != "admin":
#             return Response({"error": "Admins only"}, status=403)

#         try:
#             society = Society.objects.get(admin=request.user)
#         except Society.DoesNotExist:
#             return Response({"error": "No society found"}, status=404)

#         data = request.data.copy()
#         data["society"] = society.id
#         data["created_by"] = request.user.id

#         serializer = EventSerializer(data=data)

#         if serializer.is_valid():
#             event = serializer.save()   # capture the event

#             send_event_confirmation(request.user, event)

#             return Response(serializer.data, status=201)

#         return Response(serializer.errors, status=400)


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
        # Set society automatically; don't pass created_by unless model has it
        data["society"] = society.id

        serializer = EventSerializer(data=data)

        if serializer.is_valid():
            event = serializer.save()  # society is already set
            # Send confirmation emails if needed
            send_event_confirmation(request.user, event)
            return Response(serializer.data, status=201)

        # Return serializer errors for debugging
        return Response(serializer.errors, status=400)

class ListEventsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from django.utils.timezone import now

        if request.user.role == "admin":
            society = Society.objects.get(admin=request.user)
            events = Event.objects.filter(
                society=society,
                start_time__gte=now()
            )
        else:
            events = Event.objects.filter(
                society__membership__user=request.user,
                start_time__gte=now()
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

class AllEventsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        events = Event.objects.all().order_by('-id')[:5]  

        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)

    # def get(self, request):
    #     events = Event.objects.all().order_by('-created_at')[:5]
    #     # events = Event.objects.filter(
    #     #     start_time__gte=now()   # ✅ ONLY FUTURE EVENTS
    #     # ).order_by('start_time')[:5]  # ✅ SOONEST FIRST

    #     serializer = EventSerializer(events, many=True)
    #     return Response(serializer.data)
    
class MyCreatedEventsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        events = Event.objects.filter(created_by=request.user).order_by('-created_at')
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)
    
class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        old_password = request.data.get("old_password")
        new_password = request.data.get("new_password")

        if not user.check_password(old_password):
            return Response({"error": "Old password is incorrect"}, status=400)

        user.set_password(new_password)
        user.save()
        return Response({"message": "Password changed successfully"})
    
class ChangeEmailView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        new_email = request.data.get("new_email")

        if not new_email:
            return Response({"error": "New email is required"}, status=400)

        if User.objects.filter(email=new_email).exists():
            return Response({"error": "Email already in use"}, status=400)

        user.email = new_email
        user.save()
        return Response({"message": "Email changed successfully"})
    
class User_ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
    
        return Response(serializer.data)    

    def post(self, request):
        user = request.user
        new_name = request.data.get("name")

        if not new_name:
            return Response({"error": "New name is required"}, status=400)

        user.name = new_name
        user.save()
        return Response({"message": "Name changed successfully"})

    
class NotificationView(APIView):
    permission_classes = [IsAuthenticated]

    # GET USER PREFERENCES
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

    # UPDATE PREFERENCES 
    def post(self, request):
        user = request.user
        society_id = request.data.get("society_id")

        # safer boolean handling
        event_notifications = str(request.data.get("event_notifications")).lower() == "true"

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
            "event_notifications": pref.event_notifications
        })



def send_event_confirmation(user, event):
    if not NotificationPreference.objects.filter(
        user=user,
        society=event.society,
        event_notifications=True
    ).exists():
        return

    send_mail(
        subject="Event Created Successfully",
        message=f"""
Your event "{event.title}" has been created successfully.

Date: {event.start_time}
Location: {event.location}
""",
        from_email=None,
        recipient_list=[user.email],
        fail_silently=False,
    )


def send_event_reminders():
    now = timezone.now()
    upcoming = now + timedelta(hours=24)

    events = Event.objects.filter(start_time__range=(now, upcoming))

    for event in events:
        admins = Membership.objects.filter(
            society=event.society,
            role="admin"
        )

        for member in admins:
            user = member.user

            if not NotificationPreference.objects.filter(
                user=user,
                society=event.society,
                event_notifications=True
            ).exists():
                continue

            send_mail(
                subject="Reminder: Event in 24 Hours",
                message=f"""
Reminder: "{event.title}" is in 24 hours.

Date: {event.start_time}
Location: {event.location}
""",
                from_email=None,
                recipient_list=[user.email],
                fail_silently=False,
            )
