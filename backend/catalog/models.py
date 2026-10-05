from django.db import models


class Subject(models.Model):
    slug = models.SlugField(unique=True)
    name = models.CharField(max_length=100)
    subtitle = models.CharField(max_length=180)
    icon = models.CharField(max_length=50, blank=True)
    color_start = models.CharField(max_length=7, default='#2563EB')
    color_end = models.CharField(max_length=7, default='#60A5FA')
    cover_image_url = models.URLField(blank=True)
    position = models.PositiveIntegerField(default=0)
    is_published = models.BooleanField(default=True)

    class Meta:
        ordering = ['position', 'name']

    def __str__(self):
        return self.name


class SubjectPart(models.Model):
    subject = models.ForeignKey(
        Subject,
        related_name='parts',
        on_delete=models.CASCADE,
    )
    title = models.CharField(max_length=160)
    description = models.TextField()
    position = models.PositiveIntegerField(default=0)
    is_published = models.BooleanField(default=True)

    class Meta:
        ordering = ['position', 'id']

    def __str__(self):
        return f'{self.subject.name}: {self.title}'


class ReviewBlock(models.Model):
    part = models.ForeignKey(
        SubjectPart,
        related_name='review_blocks',
        on_delete=models.CASCADE,
    )
    title = models.CharField(max_length=180)
    summary = models.TextField()
    key_points = models.TextField(blank=True)
    recall_prompts = models.TextField(blank=True)
    estimated_minutes = models.PositiveSmallIntegerField(default=50)
    position = models.PositiveIntegerField(default=0)
    is_published = models.BooleanField(default=True)

    class Meta:
        ordering = ['position', 'id']

    def __str__(self):
        return f'{self.part}: {self.title}'
