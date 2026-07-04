from django.urls import path

from .views import UserProfileUpdateView, UserProfileView

urlpatterns = [
    path("profile/", UserProfileView.as_view(), name="profile"),
    path("profile/update/", UserProfileUpdateView.as_view(), name="profile-update"),
]
