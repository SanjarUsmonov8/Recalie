from rest_framework import viewsets

from .models import Subject
from .serializers import SubjectDetailSerializer, SubjectListSerializer


class SubjectViewSet(viewsets.ReadOnlyModelViewSet):
    lookup_field = 'slug'

    def get_queryset(self):
        queryset = Subject.objects.filter(is_published=True)
        if self.action == 'retrieve':
            queryset = queryset.prefetch_related('parts__review_blocks')
        return queryset

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return SubjectDetailSerializer
        return SubjectListSerializer
