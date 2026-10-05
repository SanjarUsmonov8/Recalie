from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name='Subject',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slug', models.SlugField(unique=True)),
                ('name', models.CharField(max_length=100)),
                ('subtitle', models.CharField(max_length=180)),
                ('icon', models.CharField(blank=True, max_length=50)),
                ('color_start', models.CharField(default='#2563EB', max_length=7)),
                ('color_end', models.CharField(default='#60A5FA', max_length=7)),
                ('cover_image_url', models.URLField(blank=True)),
                ('position', models.PositiveIntegerField(default=0)),
                ('is_published', models.BooleanField(default=True)),
            ],
            options={'ordering': ['position', 'name']},
        ),
        migrations.CreateModel(
            name='SubjectPart',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=160)),
                ('description', models.TextField()),
                ('position', models.PositiveIntegerField(default=0)),
                ('is_published', models.BooleanField(default=True)),
                ('subject', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='parts', to='catalog.subject')),
            ],
            options={'ordering': ['position', 'id']},
        ),
        migrations.CreateModel(
            name='ReviewBlock',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=180)),
                ('summary', models.TextField()),
                ('key_points', models.TextField(blank=True)),
                ('recall_prompts', models.TextField(blank=True)),
                ('estimated_minutes', models.PositiveSmallIntegerField(default=50)),
                ('position', models.PositiveIntegerField(default=0)),
                ('is_published', models.BooleanField(default=True)),
                ('part', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='review_blocks', to='catalog.subjectpart')),
            ],
            options={'ordering': ['position', 'id']},
        ),
    ]
