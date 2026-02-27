from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .analytics import JoinSocietyView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),

]


