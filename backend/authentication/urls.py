from django.urls import path

from backend.authentication import IsMemberView #include
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .SocietyDetailView import SocietyDetailView
from .serializer import EventSerializer
from .views import (
    AllEventsView,
    ChangeEmailView, 
    SocietyEventView,
    DeleteEventView,
    MyCreatedEventsView,
    SocietyEventView, 
    SocietyListSearchView,
    MySocietiesView,
    UserListView,
    SocietyListSearchView,
    EventDetailView,
    UpdateEventView,
    ChangePasswordView,
    NotificationView,
    MyEventsView)


urlpatterns = [
    # path("api/", include("authentication.urls")),
    # Authentication
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('societies/', SocietyListSearchView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
    path('users/', UserListView.as_view(), name='user-list-create'),
    path("my-societies/", MySocietiesView.as_view(), name="my-societies"),
    #path('societies/', SocietyListSearchView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/events/', SocietyEventView.as_view(), name='society-events'),

    # Admin event management
    path('events/<int:id>/delete/', DeleteEventView.as_view(), name='delete-event'),
    path('events/', SocietyEventView.as_view(), name='event-list'),
    # path('events/create/', SocietyEventView.as_view(), name='create-event'),
    path('events/my/', MyEventsView.as_view(), name='my-events'),
    path('events/<int:id>/', EventDetailView.as_view(), name='event-detail'),
    path('events/<int:id>/update/', UpdateEventView.as_view(), name='update-event'),
    path('events/all/', AllEventsView.as_view(), name='all-events'),
    path('events/my/', MyCreatedEventsView.as_view(), name='my-events'),
    path('societies/<int:society_id>/events/', IsMemberView.as_view(), name='society-events'),

    # Analytics
    path("my-analytics/", AnalyticsView.as_view(), name="analytics"),
    # Users 
    path('users/', UserListView.as_view(), name='user-list-create'),
    # search and filter societies
    path("search/", SocietyListSearchView.as_view(), name="society-search"),
    # chnage password 
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    # change email
    path('change-email/', ChangeEmailView.as_view(), name='change-email'),
    
    path('notifications/', NotificationView.as_view(), name='notifications'),
    ]


  

##smth gtuivgl






