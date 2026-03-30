from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-5qg1k1+-nhdb3$784lw&+$+)ud*f@8&g(on(6fac6qx2^*dz1v'

DEBUG = True

ALLOWED_HOSTS = ["*"]


# =========================================================
# APPS
# =========================================================

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_crontab',

    'rest_framework',
    'rest_framework.authtoken',

    'corsheaders',

    'authentication.apps.AuthenticationConfig',
]

CRONJOBS = [
    ('*/10 * * * *', 'authentication.views.send_event_reminders'),
]

# =========================================================
# MIDDLEWARE (FIXED ORDER)
# =========================================================

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',   # ✅ moved up (important)
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]


# =========================================================
# URLS / TEMPLATES
# =========================================================

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'


# =========================================================
# DATABASE
# =========================================================

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'unisoc_db',
        'USER': 'unisoc_user',
        'PASSWORD': 'strongpassword',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}


# =========================================================
# AUTH USER
# =========================================================

AUTH_USER_MODEL = 'authentication.User'


# =========================================================
# PASSWORD VALIDATION
# =========================================================

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]


# =========================================================
# INTERNATIONAL
# =========================================================

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True


# =========================================================
# STATIC
# =========================================================

STATIC_URL = 'static/'


# =========================================================
# CORS
# =========================================================

CORS_ALLOW_ALL_ORIGINS = True


# =========================================================
# REST FRAMEWORK
# =========================================================

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
}


# =========================================================
# 🚨 EMAIL CONFIG (CRITICAL ADDITION)
# =========================================================

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True

# ⚠️ CHANGE THESE
EMAIL_HOST_USER = 'your_email@gmail.com'
EMAIL_HOST_PASSWORD = 'your_app_password'

DEFAULT_FROM_EMAIL = EMAIL_HOST_USER