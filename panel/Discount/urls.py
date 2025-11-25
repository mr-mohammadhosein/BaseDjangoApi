from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

dashboard_router = DefaultRouter()
dashboard_router.register(r'', views.StaffDiscountCodeViewSet, basename='staff-discount')

urlpatterns = [
    path('', include(dashboard_router.urls)),
]