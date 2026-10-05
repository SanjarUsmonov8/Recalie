from rest_framework import serializers

from .models import ReviewBlock, Subject, SubjectPart


def split_lines(value):
    return [line.strip().lstrip('•- ').strip() for line in value.splitlines() if line.strip()]


class ReviewBlockSerializer(serializers.ModelSerializer):
    key_points = serializers.SerializerMethodField()
    recall_prompts = serializers.SerializerMethodField()

    class Meta:
        model = ReviewBlock
        fields = (
            'id',
            'title',
            'summary',
            'key_points',
            'recall_prompts',
            'estimated_minutes',
        )

    def get_key_points(self, obj):
        return split_lines(obj.key_points)

    def get_recall_prompts(self, obj):
        return split_lines(obj.recall_prompts)


class SubjectPartSerializer(serializers.ModelSerializer):
    review_blocks = serializers.SerializerMethodField()

    class Meta:
        model = SubjectPart
        fields = ('id', 'title', 'description', 'review_blocks')

    def get_review_blocks(self, obj):
        blocks = obj.review_blocks.filter(is_published=True)
        return ReviewBlockSerializer(blocks, many=True).data


class SubjectListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = (
            'slug',
            'name',
            'subtitle',
            'icon',
            'color_start',
            'color_end',
            'cover_image_url',
        )


class SubjectDetailSerializer(SubjectListSerializer):
    parts = serializers.SerializerMethodField()

    class Meta(SubjectListSerializer.Meta):
        fields = SubjectListSerializer.Meta.fields + ('parts',)

    def get_parts(self, obj):
        parts = obj.parts.filter(is_published=True)
        return SubjectPartSerializer(parts, many=True).data
