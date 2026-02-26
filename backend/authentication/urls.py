from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView

urlpatterns = [
    path("admin/login/", LoginView.as_view(), name="admin-login"),
    path("user/login/", LoginView.as_view(), name="user-login"),
    path("user/register/", RegisterView.as_view(), name="user-register"),
]

