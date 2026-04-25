from django.urls import path 
from .serializer import EventSerializer
from .views import (
    AddEventView,
    AllEventsView,
    ChangeEmailView,
    JoinEventView,
    LeaveEventView, 
    SocietyEventView,
    DeleteEventView,
    MyCreatedEventsView,
    SocietyEventView, 
    SocietyListSearchView,
    SocietyMembershipCheckView, 
    UserListView,
    SocietyListSearchView,
    EventDetailView,
    UpdateEventView,
    ChangePasswordView,
    NotificationView,
    MyEventsView,
    RegisterView,
    LoginView,
    AnalyticsView,
    JoinSocietyView,
    LeaveSocietyView,
    SocietyDetailView,
    SocietyAdminDetailView,
    CheckEventAttendanceView,
    )


urlpatterns = [
    # path("api/", include("authentication.urls")),
    # Authentication
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    # Society management
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('societies/', SocietyListSearchView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
    path('societies/<int:society_id>/admin/', SocietyAdminDetailView.as_view(), name='society-admin-detail'),
    path('societies/<int:society_id>/admin/events/', SocietyAdminDetailView.as_view(), name='society-admin-events'),

    path('users/', UserListView.as_view(), name='user-list-create'),
    #path('societies/', SocietyListSearchView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/events/', SocietyEventView.as_view(), name='society-events'),
    path('societies/<int:society_id>/check-membership/', SocietyMembershipCheckView.as_view(), name='society-membership-check'),
    # Admin event management
    path('events/<int:event_id>/delete/', DeleteEventView.as_view(), name='delete-event'),
    path('events/', SocietyEventView.as_view(), name='event-list'),
    # path('events/create/', SocietyEventView.as_view(), name='create-event'),
    path('events/my/', MyEventsView.as_view(), name='my-events'),
    path('events/<int:event_id>/', EventDetailView.as_view(), name='event-detail'),
    path('events/<int:event_id>/update/', UpdateEventView.as_view(), name='update-event'),
    path('events/all/', AllEventsView.as_view(), name='all-events'),
    path('events/my/', MyCreatedEventsView.as_view(), name='my-events'),
    path('events/<int:event_id>/join/', JoinEventView.as_view(), name='join-event'),
    path('events/<int:event_id>/leave/', LeaveEventView.as_view(), name='leave-event'),
    path('events/<int:event_id>/attending/', CheckEventAttendanceView.as_view(), name='check-attending'),


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


  








