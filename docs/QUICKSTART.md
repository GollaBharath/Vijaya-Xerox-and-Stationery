# Quick Start Guide

## Prerequisites

- Node.js 18+ (for API development)
- Docker & Docker Compose (optional, only if you want to run the API in a container)
- Git
- **Upstash Account** for Redis (serverless, free tier available)
- **PostgreSQL Database** (external service like Supabase, Neon, or self-hosted)

## Setup

### 1. Set Up External Services

#### PostgreSQL Database

Set up a PostgreSQL database using one of these options:

- [Supabase](https://supabase.com/) (free tier)
- [Neon](https://neon.tech/) (free tier)
- [Railway](https://railway.app/)
- Self-hosted PostgreSQL

Get your connection URL (format: `postgresql://user:password@host:5432/database`)

#### Upstash Redis

1. Sign up at [Upstash](https://upstash.com/) (free tier available)
2. Create a new Redis database
3. Copy the connection URL (format: `rediss://default:password@endpoint.upstash.io:6379`)

📖 **Detailed instructions**: See [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)

### 2. Configure Environment Variables

```bash
# Copy the example to create your .env file
cp .env.example .env

# Edit .env and update values
nano .env
```

**Required configuration**:

```env
# PostgreSQL - Use your external database URL
DATABASE_URL="postgresql://user:password@host:5432/vijaya_bookstore?schema=public"

# Upstash Redis - Use your Upstash connection URL
REDIS_URL="rediss://default:your-password@your-endpoint.upstash.io:6379"

# JWT Secrets - Generate strong secrets
JWT_SECRET="your-super-secret-jwt-key"
JWT_REFRESH_SECRET="your-refresh-secret-key"
```

**Note**: `.env` is automatically git-ignored. Only `.env.example` is committed to version control.

### 3. Test Redis Connection (Optional)

```bash
# Test your Upstash Redis connection
node scripts/test-redis.js
```

This will verify your Redis configuration is working correctly.

## Starting the Application

### 4. Install Dependencies

```bash
cd apps/api

# Install dependencies
npm install
```

### 5. Set Up Database

```bash
cd apps/api

# Generate Prisma client
npx prisma generate

# Run database migrations
npx prisma migrate deploy

# (Optional) Seed database with initial data
npm run prisma:seed
```

### 6. Start the API Server

````bash
cd apps/api

# Development mode
npm run dev

# Production build
npm run build
Use your database provider's web interface or CLI tools:
- **Supabase**: Use their SQL Editor in the dashboard
- **Neon**: Use their SQL Editor or `psql` with connection string
- **Self-hosted**: `psql <YOUR_DATABASE_URL>`

### View Database Schema

```bash
cd apps/api

# Open Prisma Studio (visual database browser)
npx prisma studio
## Using Docker (Optional)

If you prefer to run the API in Docker:

```bash
# Start the API container
docker compose up -d api

# View logs
docker logs -f vijaya_api
````

**Note**: Even with Docker, you still need external PostgreSQL and Upstash Redis.

## Database Commands

### Access PostgreSQL

```bash
docker exec -it vijaya_postgres psql -U vijaya_user -d vijaya_bookstore
```

### View all tables

```bash
docker exec vijaya_postgres psql -U vijaya_user -d vijaya_bookstore -c "\dt"
```

### Run Prisma commands

```bash
cd apps/api

# View database schema
npx prisma studio

# Generate client
npx prisma generate

# Create new migration
npx prisma migrate dev --name migration_name

# Deploy migrations
npx prisma migrate deploy
```

## Important Paths

| Component       | Path                                 |
| --------------- | ------------------------------------ |
| API Project     | `/apps/api`                          |
| Database Schema | `/apps/api/prisma/schema.prisma`     |
| Migrations      | `/apps/api/prisma/migrations/`       |
| Config Files    | `.env.example`, `docker-compose.yml` |
| Docker Network  | `vijaya_network`                     |

## Environment Variables

A single `.env` file in the root directory is used for all configuration:

```bash
# Copy the template
cp .env.example .env

# This file is automatically git-ignored
# Customize values for your local environment
```

\*\*AlRedis connection issues

```bash
# Test your Redis connection
node scripts/test-redis.js

# Check logs for connection errors
cd apps/api
npm run dev
# Look for "Redis Client Connected" message
```

Common issues:

- **Wrong URL format**: Ensure it starts with `rediss://` (double 's')
- **Authentication failed**: Copy the complete URL from Upstash dashboard
- **Network timeout**: Check your firewall/network settings

### Database connection issues

````bash
# Test database connection
cd apps/api
npx prisma db pull
```for missing environment variables
cd apps/api
node -e "require('dotenv').config(); console.log(process.env.DATABASE_URL ? '✓ DATABASE_URL set' : '✗ DATABASE_URL missing'); console.log(process.env.REDIS_URL ? '✓ REDIS_URL set' : '✗ REDIS_URL missing');"

# Check API logs
npm run dev
````

### Testing the Setup

Run this comprehensive test:

```bash
# Test Redis
node scripts/test-redis.js

# Test API
curl http://localhost:3000/api/v1/health
```

## Important Resources

| Resource              | Link                                               |
| --------------------- | -------------------------------------------------- |
| Upstash Dashboard     | https://console.upstash.com/                       |
| Upstash Redis Setup   | [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md) |
| API Documentation     | [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) |
| Environment Variables | [ENVIRONMENT.md](./ENVIRONMENT.md)                 |

## Next Steps

- Review [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) for available endpoints
- Set up your external PostgreSQL database
- Configure Upstash Redis following [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)

```bash
# List all networks
docker network ls

# Check vijaya_network
docker network inspect vijaya_network
```

## Network Details

- **Network Name**: `vijaya_network`
- **Database Host**: `vijaya_postgres` (inside Docker network)
- **Database Host**: `localhost` or `127.0.0.1` (from host machine)

## Next Steps

Proceed to Section C: Backend Infrastructure & Utils
