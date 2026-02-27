from django.urls import path
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView, JoinSocietyView

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("analytics/society/<int:society_id>/", AnalyticsView.as_view(), name="society-analytics"),

]







