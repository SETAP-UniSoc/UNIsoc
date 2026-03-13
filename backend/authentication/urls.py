from django.urls import path
from .loginAPIview import LoginView
from .SocietyView import SocietyListView
urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
     path("societies/", SocietyListView.as_view(), name="societies"),
]

