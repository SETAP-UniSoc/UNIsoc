from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .SocietyDetailView import SocietyDetailView
from .views import UserListView, SocietyListView
from .views import AddEventView, DeleteEventView
from .views import CreateEventView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('my-analytics/', AnalyticsView.as_view(), name="society-analytics"),
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
    path('users/', UserListView.as_view(), name='user-list-create'),
    path('societies/', SocietyListView.as_view(), name='society-list-create'),
    path('societies/<int:society_id>/events/', AddEventView.as_view(), name='society-events'),
    path('event/<int:event_id>/delete/', DeleteEventView.as_view(), name='delete-event'),
    path('events/', CreateEventView.as_view(), name='event-list'),
    path('events/create/', CreateEventView.as_view(), name='create-event'),
]










