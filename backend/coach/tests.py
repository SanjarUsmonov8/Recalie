import hashlib
from unittest.mock import patch

from django.test import SimpleTestCase, override_settings
from django.urls import reverse
from rest_framework.test import APITestCase

from .models import AiDeviceSession
from .provider import generate_reply


@override_settings(
    GEMINI_API_KEY='test-key',
    GEMINI_MODEL='gemini-test',
    GEMINI_TIMEOUT_SECONDS=5,
    GEMINI_MAX_OUTPUT_TOKENS=300,
    GEMINI_HISTORY_MESSAGE_LIMIT=20,
)
class CoachProviderTests(SimpleTestCase):
    @patch('coach.provider.request.urlopen')
    def test_builds_gemini_request_and_returns_text(self, mocked_urlopen):
        response = mocked_urlopen.return_value.__enter__.return_value
        response.read.return_value = (
            b'{"candidates":[{"content":{"parts":[{"text":"Use active recall."}]},'
            b'"finishReason":"STOP"}]}'
        )

        reply = generate_reply('How should I review?')

        self.assertEqual(reply, 'Use active recall.')
        sent_request = mocked_urlopen.call_args.args[0]
        self.assertNotIn('test-key', sent_request.full_url)
        self.assertEqual(sent_request.get_header('X-goog-api-key'), 'test-key')


@override_settings(DEBUG=True)
class CoachApiTests(APITestCase):
    def setUp(self):
        self.raw_token = 'test-device-token'
        self.session = AiDeviceSession.objects.create(
            installation_hash='a' * 64,
            token_hash=hashlib.sha256(self.raw_token.encode()).hexdigest(),
        )
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.raw_token}')

    @patch('coach.views.generate_reply', return_value='Start with one set.')
    def test_chat_endpoint_returns_reply(self, mocked_generate):
        response = self.client.post(
            reverse('coach-chat'),
            {'message': 'Help me begin.', 'history': []},
            format='json',
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['reply'], 'Start with one set.')
        mocked_generate.assert_called_once()

    def test_chat_requires_device_session(self):
        self.client.credentials()

        response = self.client.post(
            reverse('coach-chat'),
            {'message': 'Hello'},
            format='json',
        )

        self.assertEqual(response.status_code, 403)
