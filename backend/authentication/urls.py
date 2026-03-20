from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .EventView import EventListCreateView, EventDetailView #M added
from .SocietyView import SocietyListView, SocietyDetailView, SocietyMembershipCheckView #M added

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('my-analytics/', AnalyticsView.as_view(), name="society-analytics"),
    path("society/<int:society_id>/events/", EventListCreateView.as_view(), name="society-events"), #M added
    path("event/<int:event_id>/delete/", EventDetailView.as_view(), name="event-detail"), #M added
    path("societies/", SocietyListView.as_view(), name="societies"),
    path("society/<int:society_id>/", SocietyDetailView.as_view(), name="society-detail"), #M added
    path("society/<int:society_id>/is-member/", SocietyMembershipCheckView.as_view(), name="is-member"), #M added
    path("change-password/", ChangePasswordView.as_view(), name="change-password"), #M added
]






