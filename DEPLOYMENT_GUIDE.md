# Fly.io Deployment Guide

## Prerequisites

1. **Add Payment Method**: Visit https://fly.io/dashboard/personal/billing and add a payment method
2. **Environment Variables**: Set up your `.env` file with these critical variables:

### Required Environment Variables

```env
# Database - Use Supabase or similar hosted PostgreSQL
DATABASE_URL="postgresql://user:password@host:port/database?schema=public"

# Redis - Use Upstash or similar hosted Redis
REDIS_URL="rediss://default:password@endpoint.upstash.io:6379"

# JWT Secrets
JWT_SECRET="your-secret-key-here"
JWT_REFRESH_SECRET="your-refresh-secret-here"

# API Configuration
NODE_ENV="production"
API_BASE_URL="https://vijaya-api.fly.dev"
CORS_ORIGINS="https://your-frontend-domain.com"

# File Upload
MAX_FILE_SIZE="10485760"

# Razorpay (if using payments)
RAZORPAY_KEY_ID="your_key_id"
RAZORPAY_KEY_SECRET="your_secret"
RAZORPAY_WEBHOOK_SECRET="your_webhook_secret"
```

## Deployment Steps

### Step 1: Set Environment Variables on Fly.io

```bash
cd apps/api
flyctl secrets set DATABASE_URL="your-database-url"
flyctl secrets set REDIS_URL="your-redis-url"
flyctl secrets set JWT_SECRET="your-jwt-secret"
flyctl secrets set JWT_REFRESH_SECRET="your-refresh-secret"
flyctl secrets set API_BASE_URL="https://vijaya-api.fly.dev"
```

### Step 2: Create and Deploy the App

```bash
cd apps/api

# If app doesn't exist, create it after adding payment method
flyctl launch --name vijaya-api --region sin

# Or if app already exists, deploy directly
flyctl deploy
```

### Step 3: Run Database Migrations

```bash
flyctl ssh console

# Inside the console, run:
npx prisma migrate deploy
npx prisma generate
exit
```

### Step 4: Verify Deployment

```bash
# Check app status
flyctl status

# Check logs
flyctl logs

# Test health endpoint
curl https://vijaya-api.fly.dev/api/health
```

## Storage Configuration

- **Uploads Directory**: `/app/uploads` (mounted persistent volume)
- **Images**: `/app/uploads/images/products`
- **PDFs**: `/app/uploads/pdfs/books`
- **Size**: 5GB allocated persistent storage

## Key Points

- **Database**: Must be external (Supabase, Neon, Railway, etc.)
- **Redis**: Must be external (Upstash recommended)
- **Uploads**: Uses Fly.io volumes for persistence
- **Scaling**: Set `min_machines_running = 0` to reduce costs when idle
- **Auto-restart**: Machines auto-start on HTTP request

## Troubleshooting

### Database Connection Errors
```bash
flyctl secrets set DATABASE_URL="new-url"
flyctl deploy --strategy rolling
```

### Out of Memory
```bash
# Increase machine size
flyctl machine update --memory 512 [machine-id]
```

### Upload Directory Issues
```bash
# Verify mount exists
flyctl ssh console
ls -la /app/uploads
exit
```

### View detailed logs
```bash
flyctl logs --recent 100
```

## Cost Considerations

- Free tier includes 3 shared-cpu-1x machines with 100GB egress
- Persistent storage: $0.10/GB per month
- At 5GB: ~$0.50/month for storage
- Ensure you have a payment method on file for costs above free tier

## Contact Support

If you encounter issues, visit https://community.fly.io/
