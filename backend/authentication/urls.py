from django.urls import path
<<<<<<< HEAD

<<<<<<< HEAD
from UNIsoc.backend.authentication import CalanderView
=======
from UNIsoc.backend.authentication.views import CustomerListView
>>>>>>> c58e0ce2a04e1a656a1de5f17a638a5d99df0022
=======
>>>>>>> 2f9f065 (made chages)
from .RegisterView import RegisterView
from .LoginView import LoginView
from .AnalyticsView import AnalyticsView
from .JoinSoc import JoinSocietyView
from .LeaveSoc import LeaveSocietyView
<<<<<<< HEAD
from .EventView import EventListCreateView #M added
from .SocietyView import SocietyListView, SocietyDetailView, SocietyMembershipCheckView #M added
from .ChangePasswordView import ChangePasswordView #M added
=======
from .SocietyDetailView import SocietyDetailView
<<<<<<< HEAD
<<<<<<< HEAD
from .views import CustomerListView
>>>>>>> c58e0ce2a04e1a656a1de5f17a638a5d99df0022
=======
>>>>>>> 2f9f065 (made chages)
=======
from .views import CustomerListCreateView
>>>>>>> 0ce5e3a (made urls correct)

urlpatterns = [
    path("login/", LoginView.as_view(), name="login"),
    path("user/register/", RegisterView.as_view(), name="register"),
    path("society/<int:society_id>/join/", JoinSocietyView.as_view(), name="join-society"),
    path("society/<int:society_id>/leave/", LeaveSocietyView.as_view(), name="leave-society"),
    path('my-analytics/', AnalyticsView.as_view(), name="society-analytics"),
<<<<<<< HEAD
    path("society/<int:society_id>/events/", EventListCreateView.as_view(), name="society-events"), #M added
    path("event/<int:event_id>/delete/", CalanderView.as_view(), name="event-detail"), #M added
    path("societies/", SocietyListView.as_view(), name="societies"),
    path("society/<int:society_id>/is-member/", SocietyMembershipCheckView.as_view(), name="is-member"), #M added
    path("change-password/", ChangePasswordView.as_view(), name="change-password"), #M added
=======
    path('societies/<int:society_id>/', SocietyDetailView.as_view(), name='society-detail'),
<<<<<<< HEAD
<<<<<<< HEAD
    path('customers/', CustomerListView.as_view(), name='customer-list-create'),
>>>>>>> c58e0ce2a04e1a656a1de5f17a638a5d99df0022
=======
>>>>>>> 2f9f065 (made chages)
=======
    path('customers/', CustomerListCreateView.as_view(), name='customer-list-create'),
>>>>>>> 0ce5e3a (made urls correct)
]






<<<<<<< HEAD
=======


>>>>>>> 2f9f065 (made chages)
