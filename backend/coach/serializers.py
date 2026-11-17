import base64
import binascii

from rest_framework import serializers


class DeviceSessionRequestSerializer(serializers.Serializer):
    installation_id = serializers.UUIDField()


class ChatHistoryMessageSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=('user', 'assistant'))
    content = serializers.CharField(max_length=4000, trim_whitespace=True)


class CoachChatRequestSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=4000, trim_whitespace=True)
    history = ChatHistoryMessageSerializer(many=True, required=False)
    image_base64 = serializers.CharField(
        required=False,
        allow_blank=True,
        max_length=8_000_000,
        write_only=True,
    )
    image_mime_type = serializers.ChoiceField(
        choices=('image/jpeg', 'image/png', 'image/webp'),
        required=False,
        allow_blank=True,
        write_only=True,
    )

    def validate_history(self, value):
        if len(value) > 20:
            raise serializers.ValidationError('Keep at most 20 recent messages.')
        return value

    def validate(self, attrs):
        image_data = attrs.get('image_base64', '')
        image_mime_type = attrs.get('image_mime_type', '')
        if bool(image_data) != bool(image_mime_type):
            raise serializers.ValidationError(
                'Image data and image type must be provided together.'
            )
        if image_data:
            try:
                decoded = base64.b64decode(image_data, validate=True)
            except (ValueError, binascii.Error) as exc:
                raise serializers.ValidationError('The image data is invalid.') from exc
            if len(decoded) > 5 * 1024 * 1024:
                raise serializers.ValidationError('The image must be 5 MB or smaller.')
        return attrs
