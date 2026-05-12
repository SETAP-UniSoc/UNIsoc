
from asyncio import events
from .tasks import send_join_event_email   # import the task function to send email asynchronously when a user joins an event
from rest_framework.authtoken.models import Token
from rest_framework import generics
from urllib3 import request
from .models import EventAttendance, User, Event, Society
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import PermissionDenied
from .serializer import UserSerializer, EventSerializer, SocietySerializer
from django.utils.timezone import now
from django.db.models import Count, Q
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.core.mail import send_mail
from django.utils import timezone
from datetime import timedelta
import re
from rest_framework.permissions import AllowAny
from .tasks import send_join_event_email
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

# SOCIETY & EVENT VIEWS
class SocietyListSearchView(APIView):
    permission_classes = [AllowAny]  

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
            "member_count": s.member_count,
            "description": s.description,
            "category": s.category,
        } for s in societies]

        return Response(data)
    
# ADMIN SOCIETY & EVENT MANAGEMENT VIEWS
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

# Admin can only delete events they created
class DeleteEventView(generics.DestroyAPIView):

    permission_classes = [IsAuthenticated]
    serializer_class = EventSerializer
    lookup_field = 'id'
    lookup_url_kwarg = 'event_id'


    def get_queryset(self):
        
        return Event.objects.filter(created_by=self.request.user)

# Admin can only update events they created
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

        if data.get("capacity_limit") in [0, "0", ""]:
            data["capacity_limit"] = None

        serializer = EventSerializer(data=data)

        if serializer.is_valid():
            event = serializer.save(
                society=society,
                created_by=request.user
            )

            send_event_confirmation(request.user, event)

            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)

class EventDetailView(generics.RetrieveAPIView):

    permission_classes = [IsAuthenticated]
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    lookup_field = 'id'

# Admin can only update events they created
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

# This view is used to show the 5 most recent events on the home page for both users and admins
class AllEventsView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):
        
        events = Event.objects.select_related("society").order_by('-id')[:5]
        serializer = EventSerializer(events, many=True)
        return Response(serializer.data)
    
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

        # check required fields
        if not old_password or not new_password:
            return Response(
                {"error": "Both old and new passwords are required"},
                status=400
            )

        # check old password
        if not user.check_password(old_password):
            return Response(
                {"error": "Old password is incorrect"},
                status=400
            )

        # optional password validation
        if len(new_password) < 8:
            return Response(
                {"error": "Password must be at least 8 characters long"},
                status=400
            )

        user.set_password(new_password)
        user.save()

        return Response(
            {"message": "Password changed successfully"},
            status=200
        )


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

# notification preferences view
class NotificationView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):
        
        user = request.user
        preferences = NotificationPreference.objects.filter(user=user)

        data = []
        for pref in preferences:
            data.append({
                "society": pref.society.name,
                "notify_new_events": pref.notify_new_events,
            })

        return Response(data)

    def post(self, request):
        
        user = request.user
        society_id = request.data.get("society_id")

        notify_new_events = str(request.data.get("event_notifications")).lower() == "true"

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
                "notify_new_events": notify_new_events
            }
        )

        return Response({
            "message": "Notification preferences updated",
            "society": society.name,
            "notify_new_events": pref.notify_new_events
        })

# This function is used to send email notifications to users when a new event is created in a society they are a member of and have notifications enabled for that society. It is called from the AddEventView after an event is successfully created. The function retrieves all users who have notification preferences set to true for the society of the new event, and sends them an email with the event details.
def send_event_confirmation(admin_user, event):
    
    prefs = NotificationPreference.objects.filter(
        society=event.society,
        notify_new_events=True
    )

    recipient_emails = [pref.user.email for pref in prefs if pref.user.email]

    if not recipient_emails:
        return

    subject = f"New Event: {event.title}"
    message = f"""
    Hello,

    A new event has been created in your society: {event.society.name}

    Title: {event.title}
    Description: {event.description}
    Start: {event.start_time}
    End: {event.end_time}

    Please check the portal for more details.
    """

    send_mail(
        subject=subject,
        message=message,
        from_email="no-reply@yoursite.com",
        recipient_list=recipient_emails,
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
                notify_24hr_reminder=True
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

class SocietyAdminDetailView(APIView):

    permission_classes = [IsAuthenticated]

    # GET society details — used by both admin and user society page
    def get(self, request, society_id):
        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        return Response({
            "id": society.id,
            "name": society.name,
            "category": society.category,
            "description": society.description,
        })

    # PATCH update society description — admin only
    def patch(self, request, society_id):
        if request.user.role != "admin":
            return Response({"error": "Admin only"}, status=403)

        try:
            society = Society.objects.get(id=society_id, admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "Society not found or not your society"}, status=404)

        description = request.data.get("description")
        if description is not None:
            society.description = description
            society.save()

        return Response({
            "id": society.id,
            "name": society.name,
            "category": society.category,
            "description": society.description,
            "message": "Society updated successfully"
        })

# This view is used to check if a user is an active member of a society. It is called from the frontend when a user tries to access a society's page, to determine if they should be allowed in and what actions they can take (e.g. join event, see members-only content). The view checks if there is an active membership record for the user and society (i.e. joined_at is set and left_at is null) and returns a boolean result.
class SocietyMembershipCheckView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request, society_id):
        # Check active membership (not left)
        is_member = Membership.objects.filter(
            user=request.user,
            society_id=society_id,
            left_at__isnull=True
        ).exists()

        return Response({
            "society_id": society_id,
            "is_member": is_member
        }, status=status.HTTP_200_OK)
    
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

class RegisterView(APIView):
    
    def post(self, request):   
       
        first_name = request.data.get("first_name")
        last_name = request.data.get("last_name")
        email = request.data.get("email")
        up_number = request.data.get("up_number")
        password = request.data.get("password")
        confirm_password = request.data.get("confirm_password")

        # Check required fields
        if not all([first_name, last_name, email, up_number, password, confirm_password]):
            return Response(
                {"error": "All fields are required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Password match
        if password != confirm_password:
            return Response(
                {"error": "Passwords do not match"},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Password strength
        if len(password) < 8:
            return Response(
                {"error": "Password must be at least 8 characters long"},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not re.search(r"[A-Z]", password):
            return Response(
                {"error": "Password must contain at least one uppercase letter"},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not re.search(r"[0-9]", password):
            return Response(
                {"error": "Password must contain at least one number"},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            return Response(
                {"error": "Password must contain at least one special character"},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Normalize UP number
        up_number = up_number.lower()
        if not up_number.startswith("up"):
            up_number = f"up{up_number}"
        # Check duplicates
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email already exists"}, status=400)

        if User.objects.filter(up_number=up_number).exists():
            return Response({"error": "UP number already exists"}, status=400)
        # Create user
        user = User.objects.create_user(
            first_name=first_name,
            last_name=last_name,
            email=email,
            up_number=up_number,
            password=password
        )
        return Response(
            {"message": "User registered successfully"},
            status=status.HTTP_201_CREATED
        )

class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        up_number = request.data.get("up_number")
        password = request.data.get("password")
        selected_society_id = request.data.get("society_id")  # 👈 NEW

        if not password:
            return Response({"error": "Password required"}, status=400)

        try:
            if email:
                user = User.objects.get(email__iexact=email)
            elif up_number:
                up_number = up_number.lower()
                if not up_number.startswith("up"):
                    up_number = f"up{up_number}"
                user = User.objects.get(up_number__iexact=up_number)
            else:
                return Response({"error": "Email or UP number required"}, status=400)

            if user.check_password(password):
                token, _ = Token.objects.get_or_create(user=user)

                society_id = None
                society_name = None

                # admin validation: if user is admin, they must select their society and it must match the one in the database
                if user.role == "admin":
                    try:
                        society = Society.objects.get(admin=user)
                        society_id = society.id
                        society_name = society.name

                        
                        if str(society_id) != str(selected_society_id):
                            return Response(
                                {"error": "Invalid society selection"},
                                status=403
                            )

                    except Society.DoesNotExist:
                        return Response(
                            {"error": "Admin has no assigned society"},
                            status=400
                        )

                return Response({
                    "token": token.key,
                    "role": user.role,
                    "email": user.email,
                    "up_number": user.up_number,
                    "society_id": society_id,
                    "society_name": society_name
                })

        except User.DoesNotExist:
            pass

        return Response({"error": "Invalid credentials"}, status=401)
    
class LeaveSocietyView(APIView):
    
    permission_classes = [IsAuthenticated]

    def post(self, request, society_id):
        user = request.user

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response(
                {"error": "Society not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        try:
            membership = Membership.objects.get(
                user=user,
                society=society,
                left_at__isnull=True
                
            )
        except Membership.DoesNotExist:
            return Response(
                {"error": "You are not an active member"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        membership.left_at = timezone.now()
        membership.save()

        return Response(
            {"message": "Successfully left society"},
            status=status.HTTP_200_OK,
        )

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


class JoinSocietyView(APIView):
   
    permission_classes = [IsAuthenticated]

    def post(self, request, society_id):
        user = request.user

        try:
            society = Society.objects.get(id=society_id)
        except Society.DoesNotExist:
            return Response(
                {"error": "Society not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        membership, created = Membership.objects.get_or_create(
            user=user,
            society=society
        )

        if created:
            return Response(
                {"message": "Joined successfully"},
                status=status.HTTP_201_CREATED
            )

        if membership.left_at is None:
            return Response({"message": "Already joined"}, status=200)

        # Rejoining
        membership.left_at = None
        membership.joined_at = timezone.now()
        membership.save()

        return Response({"message": "Rejoined successfully"}, status=200)
            

class JoinEventView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, event_id):

        try:
            event = Event.objects.get(id=event_id)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=404)

        if event.start_time < timezone.now():
            return Response({"error": "Event has already passed"}, status=400)

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

        # SEND EMAIL (ASYNC WITH CELERY)
        send_join_event_email.delay(
            user_email=request.user.email,
            event_title=event.title,
            society_name=event.society.name,
            start_time=str(event.start_time),
            location=event.location,
            description=event.description
        )

        attendee_count = EventAttendance.objects.filter(
            event=event,
            left_at__isnull=True
        ).count()

        return Response({
            "message": "Joined event",
            "attendee_count": attendee_count
        })
    
class AnalyticsView(APIView):
    
    permission_classes = [IsAuthenticated]

    def get(self, request):

        if request.user.role != "admin":
            return Response({"error": "Admins only"}, status=403)

        period = request.query_params.get("period", "week")

        try:
            society = Society.objects.get(admin=request.user)
        except Society.DoesNotExist:
            return Response({"error": "Society not found"}, status=404)

        now = timezone.now()

        # Decide grouping & range
        if period == "week":
            days_range = 7
            delta = timedelta(days=1)
            label_format = "%a"  # Mon Tue Wed
        elif period == "month":
            days_range = 30
            delta = timedelta(days=1)
            label_format = "%d %b"
        elif period == "6months":
            days_range = 26
            delta = timedelta(weeks=1)
            label_format = "Week %W"
        elif period == "year":
            days_range = 12
            delta = timedelta(days=30)
            label_format = "%b"
        else:
            return Response({"error": "Invalid period"}, status=400)

        start_date = now - (delta * days_range)

        labels = []
        totals = []

        current_date = start_date

        for _ in range(days_range):

            total = Membership.objects.filter(
                society=society,
                joined_at__lte=current_date
            ).filter(
                Q(left_at__isnull=True) | Q(left_at__gt=current_date)
            ).count()

            labels.append(current_date.strftime(label_format))
            totals.append(total)

            current_date += delta

        society = Society.objects.get(admin=request.user) # gets admis society
        total_events = society.events.count() # total events in that society
        events_stats = society.events.annotate(
            attendee_count = Count(
                "eventattendance",
                filter = Q(eventattendance__left_at__isnull=True)
            )
        ).values("title", "attendee_count")

        #most popular event
        most_popular = society.events.annotate(
            attendee_count = Count(
                "eventattendance",
                filter = Q(eventattendance__left_at__isnull=True)
            )
        ).order_by("-attendee_count").values("title", "attendee_count").first()

        live_count = Membership.objects.filter(
            society=society,
            left_at__isnull=True
        ).count()

        return Response({
            "labels": labels,
            "totals": totals,
            "live_count": live_count,
            "total_events": total_events,
            "events_stats": list(events_stats),
            "most_popular": most_popular,
            "event_attendance": list(events_stats)
        })

class CheckEventAttendanceView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request, event_id):
        try:
            event = Event.objects.get(id=event_id)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=404)

        total_registered = EventAttendance.objects.filter(event=event).count()

        active_attendees = EventAttendance.objects.filter(
            event=event,
            left_at__isnull=True
        ).count()

        left_attendees = EventAttendance.objects.filter(
            event=event,
            left_at__isnull=False
        ).count()

        return Response({
            "event_id": event.id,
            "title": event.title,
            "location": event.location,
            "start_time": event.start_time,
            "is_attending": EventAttendance.objects.filter(
                event=event,
                user=request.user,
                left_at__isnull=True
            ).exists(),
            "total_registered": total_registered,
            "active_attendees": active_attendees,
            "left_attendees": left_attendees
        })
        
class UserProfileView(APIView): 
    
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def patch(self, request):
        user = request.user
        data = request.data

        if "first_name" in request.data:
            user.first_name = request.data["first_name"]

        if "last_name" in request.data:
            user.last_name = request.data["last_name"]

        if "email" in data:
            if User.objects.filter(email=data["email"]).exclude(id=user.id).exists():
                return Response({"error": "Email already in use"}, status=400)
            user.email = data["email"]

        if "up_number" in data:
            user.up_number = data["up_number"]

        user.save()

        return Response({
            "message": "Profile updated successfully",
            "user": UserSerializer(user).data
        }, status=status.HTTP_200_OK)
    
class MySocietiesView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):
        memberships = Membership.objects.filter(
            user=request.user,
            left_at__isnull=True
        ).select_related("society")

        societies = []
        for m in memberships:
            s = m.society
            societies.append({
                "id": s.id,
                "name": s.name,
                "category": s.category,
                "description": s.description,
            })

        return Response(societies)
    
class CheckUserView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get("email")
        role = request.data.get("role")
       
        try:
            user = User.objects.get(email=email)
            # Verify the role matches
            if user.role != role:
                return Response({"error": f"No {role} account found with this email"}, status=404)
           
            return Response({
                "user_id": user.id,
                "role": user.role,
            }, status=200)
        except User.DoesNotExist:
            return Response({"error": "Email not found"}, status=404)

class VerifyUpNumberView(APIView): 
    permission_classes = [AllowAny]

    def post(self, request):
        user_id = request.data.get("user_id")
        up_number = request.data.get("up_number")
        try:
            user = User.objects.get(id=user_id)
            # Normalize UP number
            input_up = up_number.lower()
            if not input_up.startswith("up"):
                input_up = f"up{input_up}"
           
            if user.up_number == input_up:
                return Response({"message": "Verified"}, status=200)
            return Response({"error": "Invalid UP number"}, status=400)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

class ResetPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        user_id = request.data.get("user_id")
        new_password = request.data.get("new_password")
       
        try:
            user = User.objects.get(id=user_id)
            user.set_password(new_password)
            user.save()
            return Response({"message": "Password reset successfully"}, status=200)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)
