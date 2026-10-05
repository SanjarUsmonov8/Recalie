from django.contrib import admin

from .models import ReviewBlock, Subject, SubjectPart


class SubjectPartInline(admin.TabularInline):
    model = SubjectPart
    extra = 0
    fields = ('title', 'description', 'position', 'is_published')


@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'position', 'is_published')
    list_editable = ('position', 'is_published')
    prepopulated_fields = {'slug': ('name',)}
    inlines = (SubjectPartInline,)


@admin.register(SubjectPart)
class SubjectPartAdmin(admin.ModelAdmin):
    list_display = ('title', 'subject', 'position', 'is_published')
    list_filter = ('subject', 'is_published')
    list_editable = ('position', 'is_published')


@admin.register(ReviewBlock)
class ReviewBlockAdmin(admin.ModelAdmin):
    list_display = ('title', 'part', 'estimated_minutes', 'position', 'is_published')
    list_filter = ('part__subject', 'is_published')
    list_editable = ('position', 'is_published')
