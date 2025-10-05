# Deploying Doccano on Railway

This guide will help you deploy your Doccano application on Railway using your existing PostgreSQL database.

## Prerequisites

- Railway account
- Railway CLI installed (`npm install -g @railway/cli`)
- PostgreSQL database already deployed on Railway (which you have)

## Step 1: Prepare Your Project

1. Make sure you have the following files in your project root:
   - `Dockerfile.railway` (Railway-specific Dockerfile)
   - `railway.json` (Railway configuration)
   - `tools/railway.sh` (Railway startup script)

## Step 2: Set Up Environment Variables

You'll need to configure the following environment variables in your Railway project. Since you already have PostgreSQL deployed, you can use your existing database variables:

### Required Environment Variables

```bash
# Admin Configuration
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_secure_password
ADMIN_EMAIL=your_admin@email.com

# Django Configuration
SECRET_KEY=your_very_long_random_secret_key_here
DEBUG=False
DJANGO_SETTINGS_MODULE=config.settings.production

# Database Configuration (use your existing Railway PostgreSQL variables)
DATABASE_URL=your_existing_database_url_from_railway

# Application Configuration
PORT=8000
WORKERS=2
CELERY_WORKERS=1

# Security Configuration
ALLOWED_HOSTS=*
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

### Optional Environment Variables

```bash
# Email Configuration (if you want email functionality)
EMAIL_USE_TLS=True
EMAIL_HOST=smtp.gmail.com
EMAIL_HOST_USER=your_email@gmail.com
EMAIL_HOST_PASSWORD=your_app_password
EMAIL_PORT=587
DEFAULT_FROM_EMAIL=your_email@gmail.com

# File Upload Configuration
MAX_UPLOAD_SIZE=1073741824  # 1GB in bytes
ENABLE_FILE_TYPE_CHECK=False

# Google Analytics (optional)
GOOGLE_TRACKING_ID=your_ga_tracking_id

# Flower (Celery monitoring - optional)
FLOWER_BASIC_AUTH=username:password
```

## Step 3: Deploy Using Railway CLI

1. **Login to Railway:**

   ```bash
   railway login
   ```

2. **Initialize Railway project:**

   ```bash
   railway init
   ```

3. **Link to existing project (if you have one) or create new:**

   ```bash
   # To link to existing project
   railway link [project-id]

   # Or create new project
   railway init doccano-app
   ```

4. **Set environment variables:**

   ```bash
   # Set required variables
   railway variables set ADMIN_USERNAME=admin
   railway variables set ADMIN_PASSWORD=your_secure_password
   railway variables set ADMIN_EMAIL=admin@example.com
   railway variables set SECRET_KEY=your_very_long_random_secret_key
   railway variables set DEBUG=False
   railway variables set DJANGO_SETTINGS_MODULE=config.settings.production

   # Use your existing DATABASE_URL from PostgreSQL service
   railway variables set DATABASE_URL=your_existing_database_url

   # Application settings
   railway variables set PORT=8000
   railway variables set WORKERS=2
   railway variables set CELERY_WORKERS=1
   railway variables set ALLOWED_HOSTS=*
   railway variables set SESSION_COOKIE_SECURE=True
   railway variables set CSRF_COOKIE_SECURE=True
   ```

5. **Deploy the application:**
   ```bash
   railway up
   ```

## Step 4: Alternative Deployment via Railway Dashboard

1. **Go to Railway Dashboard:**

   - Visit [railway.app](https://railway.app)
   - Login to your account

2. **Create New Project:**

   - Click "New Project"
   - Choose "Deploy from GitHub repo"
   - Connect your GitHub repository

3. **Configure Environment Variables:**

   - Go to your project settings
   - Add all the environment variables listed above
   - Use your existing PostgreSQL `DATABASE_URL`

4. **Configure Build Settings:**
   - Railway should automatically detect the `railway.json` file
   - It will use `Dockerfile.railway` for building

## Step 5: Connect to Existing PostgreSQL Database

Since you already have PostgreSQL deployed on Railway with all the environment variables, you just need to:

1. **Use your existing DATABASE_URL:**

   ```bash
   # Your existing DATABASE_URL should work directly
   railway variables set DATABASE_URL=$DATABASE_PUBLIC_URL
   ```

2. **Or construct it from your existing variables:**
   ```bash
   # If needed, construct from individual variables
   DATABASE_URL=postgresql://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE
   ```

## Step 6: Verify Deployment

1. **Check deployment status:**

   ```bash
   railway status
   ```

2. **View logs:**

   ```bash
   railway logs
   ```

3. **Get your application URL:**
   ```bash
   railway domain
   ```

## Step 7: Post-Deployment Setup

1. **Access your application:**

   - Visit the Railway-provided URL
   - Login with your admin credentials

2. **Verify database connection:**
   - The application should automatically run migrations
   - Admin user should be created automatically

## Troubleshooting

### Common Issues:

1. **Database Connection Issues:**

   - Verify your `DATABASE_URL` is correct
   - Check if your PostgreSQL service is running
   - Ensure SSL settings are correct

2. **Static Files Not Loading:**

   - Check if `collectstatic` ran successfully in logs
   - Verify `STATIC_URL` and `STATIC_ROOT` settings

3. **Admin User Not Created:**

   - Check if all admin environment variables are set
   - Look for errors in the deployment logs

4. **Port Issues:**
   - Railway automatically sets the `PORT` variable
   - Make sure your application binds to `0.0.0.0:$PORT`

### Useful Commands:

```bash
# View environment variables
railway variables

# Connect to your app's shell
railway shell

# View real-time logs
railway logs --follow

# Restart your service
railway redeploy
```

## Environment Variables Summary

Here's a quick reference of the environment variables you need to set in Railway:

| Variable                 | Required | Description                  | Example                      |
| ------------------------ | -------- | ---------------------------- | ---------------------------- |
| `ADMIN_USERNAME`         | Yes      | Admin username               | `admin`                      |
| `ADMIN_PASSWORD`         | Yes      | Admin password               | `secure_password123`         |
| `ADMIN_EMAIL`            | Yes      | Admin email                  | `admin@example.com`          |
| `SECRET_KEY`             | Yes      | Django secret key            | `your-secret-key`            |
| `DATABASE_URL`           | Yes      | PostgreSQL connection string | Your existing Railway DB URL |
| `DEBUG`                  | No       | Debug mode                   | `False`                      |
| `DJANGO_SETTINGS_MODULE` | No       | Django settings              | `config.settings.production` |
| `PORT`                   | No       | Application port             | `8000` (Railway sets this)   |
| `WORKERS`                | No       | Gunicorn workers             | `2`                          |
| `CELERY_WORKERS`         | No       | Celery workers               | `1`                          |

## Next Steps

After successful deployment:

1. **Set up your domain** (if you have a custom domain)
2. **Configure email settings** for user notifications
3. **Set up monitoring** using Railway's built-in metrics
4. **Configure backups** for your PostgreSQL database
5. **Set up CI/CD** for automatic deployments

Your Doccano application should now be successfully deployed on Railway and connected to your existing PostgreSQL database!
