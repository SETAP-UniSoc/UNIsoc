from django.urls import path
from .loginAPIview import LoginView
from .RegisterView import RegisterView, LoginView


urlpatterns = [
    path("signup/", RegisterView.as_view(), name="signup"),
    path("login/", LoginView.as_view(), name="login"),
]

