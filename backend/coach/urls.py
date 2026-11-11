from django.urls import path

from .views import CoachChatView, DeviceSessionView


urlpatterns = [
    path('session/', DeviceSessionView.as_view(), name='coach-session'),
    path('chat/', CoachChatView.as_view(), name='coach-chat'),
]
