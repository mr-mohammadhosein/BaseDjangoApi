from django.urls import path, include

urlpatterns = [
    path('tickets/', include('panel.Ticketing.urls')),
    path('notifications/', include('panel.Notification.urls')),
    path('users/', include('panel.User.urls')),
    path('feedbacks/', include('panel.Feedback.urls')),
    path('discounts/', include('panel.Discount.urls')),
]