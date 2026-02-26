from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),

]

