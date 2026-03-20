from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
from .EventView import EventListCreateView, EventDetailView #M added

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
]

