from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .SocietyDetailView import SocietyDetailView
from .serializer import EventSerializer
from .views import (
    AddEventView, 
    CreateEventView, 
    DeleteEventView,
    SocietyEventView, 
    SocietyListView, 
    UserListView,
    SocietyListView, 
    EventDetailView,
    UpdateEventView,
    MyEventsView)



urlpatterns = [
    # Authentication
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    # Society management
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
    path('users/', UserListView.as_view(), name='user-list-create'),
    path('societies/', SocietyListView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/events/', SocietyEventView.as_view(), name='society-events'),
    # Admin event management
    path('event/<int:event_id>/delete/', DeleteEventView.as_view(), name='delete-event'),
    path('events/', CreateEventView.as_view(), name='event-list'),
    path('events/create/', CreateEventView.as_view(), name='create-event'),
    path('events/my/', MyEventsView.as_view()),
    path('events/<int:id>/', EventDetailView.as_view()),
    path('events/<int:id>/update/', UpdateEventView.as_view()),

    # Analytics
    path("analytics/", AnalyticsView.as_view(), name="analytics"),
    # Users 
    path('users/', UserListView.as_view(), name='user-list-create'),
    # search and filter societies
    path('societies/search/', SocietyListView.as_view(), name='society-search'),
    ]











