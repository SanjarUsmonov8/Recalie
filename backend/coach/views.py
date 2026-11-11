import hashlib
import hmac
import secrets

from django.conf import settings
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle, UserRateThrottle
from rest_framework.views import APIView

from .authentication import AiDeviceTokenAuthentication
from .models import AiDeviceSession
from .provider import CoachProviderError, generate_reply
from .serializers import CoachChatRequestSerializer, DeviceSessionRequestSerializer


class SessionCreateThrottle(AnonRateThrottle):
    rate = '5/day'


class CoachThrottle(UserRateThrottle):
    rate = '30/hour'


def _requires_https(request):
    return not settings.DEBUG and not request.is_secure()


class DeviceSessionView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]
    throttle_classes = [SessionCreateThrottle]

    def post(self, request):
        if _requires_https(request):
            return Response(
                {'detail': 'HTTPS is required for AI Coach.'},
                status=status.HTTP_426_UPGRADE_REQUIRED,
            )
        serializer = DeviceSessionRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        installation_id = str(serializer.validated_data['installation_id'])
        installation_hash = hmac.new(
            settings.SECRET_KEY.encode('utf-8'),
            installation_id.encode('utf-8'),
            hashlib.sha256,
        ).hexdigest()
        raw_token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(raw_token.encode('utf-8')).hexdigest()
        AiDeviceSession.objects.update_or_create(
            installation_hash=installation_hash,
            defaults={'token_hash': token_hash, 'is_active': True},
        )
        return Response({'token': raw_token}, status=status.HTTP_201_CREATED)


class CoachChatView(APIView):
    authentication_classes = [AiDeviceTokenAuthentication]
    permission_classes = [IsAuthenticated]
    throttle_classes = [CoachThrottle]

    def post(self, request):
        if _requires_https(request):
            return Response(
                {'detail': 'HTTPS is required for AI Coach.'},
                status=status.HTTP_426_UPGRADE_REQUIRED,
            )
        serializer = CoachChatRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            reply = generate_reply(
                serializer.validated_data['message'],
                serializer.validated_data.get('history', []),
            )
        except CoachProviderError as exc:
            return Response(
                {'detail': str(exc)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        return Response({'reply': reply})
