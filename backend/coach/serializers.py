from rest_framework import serializers


class DeviceSessionRequestSerializer(serializers.Serializer):
    installation_id = serializers.UUIDField()


class ChatHistoryMessageSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=('user', 'assistant'))
    content = serializers.CharField(max_length=4000, trim_whitespace=True)


class CoachChatRequestSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=4000, trim_whitespace=True)
    history = ChatHistoryMessageSerializer(many=True, required=False)

    def validate_history(self, value):
        if len(value) > 20:
            raise serializers.ValidationError('Keep at most 20 recent messages.')
        return value
