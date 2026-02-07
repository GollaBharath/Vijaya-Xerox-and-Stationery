# Quick Start Guide

## Prerequisites

- Docker & Docker Compose installed
- Node.js 18+ (for local development)
- Git

## Setup

### 1. Configure Environment Variables

```bash
# Copy the example to create your .env file
cp .env.example .env

# Edit .env and update values as needed
nano .env
```

**Note**: `.env` is automatically git-ignored. Only `.env.example` is committed to version control.

## Starting Everything

### 2. Start Docker Services

```bash
cd /home/dead/freelancing/Vijaya-Xerox-and-Stationery

# Start PostgreSQL and Redis
docker compose up -d postgres redis
```

### 3. Start the API Server

```bash
cd apps/api

# Install dependencies (if not done)
npm install

# Development mode
npm run dev

# Production build
npm run build
npm start
```

### 4. Access the API

- **Home**: http://localhost:3000/
- **Health Check**: http://localhost:3000/api/v1/health

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

**All services** (Docker Compose and Next.js API) read from this single `.env` file.

## Troubleshooting

### Database connection issues

```bash
# Check if postgres is running
docker ps | grep vijaya_postgres

# Check logs
docker logs vijaya_postgres

# Test connection
docker exec vijaya_postgres psql -U vijaya_user -d vijaya_bookstore -c "SELECT 1"
```

### API won't start

```bash
# Check if port 3000 is in use
sudo lsof -i :3000

# Check API logs
cd apps/api
npm run dev
```

### Network issues

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
