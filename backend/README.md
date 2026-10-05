# Recalie backend

This Django REST backend stores the shared Discover catalog: subjects, their main parts, and 45–60 minute review blocks. User-created recall calendars remain local in the Flutter app for now.

## Local setup

```powershell
cd backend
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item .env.example .env
```

For a quick local-only check, set `DJANGO_USE_SQLITE=True` in `.env`. Production uses PostgreSQL through the `POSTGRES_*` variables.

```powershell
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py createsuperuser
.\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

Endpoints:

- `GET /api/v1/health/`
- `GET /api/v1/catalog/subjects/`
- `GET /api/v1/catalog/subjects/{slug}/`
- `/admin/` for editing catalog content

## Deployment order

1. Build and test locally.
2. Commit and push the Recalie repository to GitHub.
3. Pull it onto the server into a separate directory such as `/opt/recalie`.
4. Create `/opt/recalie/backend/.env` directly on the server; never commit it.
5. Install requirements, create the PostgreSQL database/user, migrate, collect static files, and run Gunicorn behind Nginx.

Example Gunicorn command:

```bash
/opt/recalie/backend/.venv/bin/gunicorn --chdir /opt/recalie/backend --workers 3 --bind 127.0.0.1:8010 recalie_backend.wsgi:application
```
