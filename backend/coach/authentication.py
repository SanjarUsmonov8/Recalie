import hashlib

from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from .models import AiDeviceSession


class AiDevicePrincipal:
    def __init__(self, session):
        self.pk = session.pk
        self.session = session
        self.is_authenticated = True


class AiDeviceTokenAuthentication(BaseAuthentication):
    keyword = 'Bearer'

    def authenticate(self, request):
        header = request.headers.get('Authorization', '')
        prefix, separator, token = header.partition(' ')
        if not separator or prefix != self.keyword or not token:
            return None
        token_hash = hashlib.sha256(token.encode('utf-8')).hexdigest()
        try:
            session = AiDeviceSession.objects.get(
                token_hash=token_hash,
                is_active=True,
            )
        except AiDeviceSession.DoesNotExist as exc:
            raise AuthenticationFailed('The AI device session is invalid.') from exc
        session.save(update_fields=('last_used_at',))
        return AiDevicePrincipal(session), session
