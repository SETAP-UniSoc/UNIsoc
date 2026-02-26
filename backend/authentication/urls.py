from django.urls import path
from .loginAPIview import LoginView
from .RegisterView import RegisterView, LoginView


urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('api/register/', RegisterView.as_view()),
    path('api/login/', LoginView.as_view()),
]

