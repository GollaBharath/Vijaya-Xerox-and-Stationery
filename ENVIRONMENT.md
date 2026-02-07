# Environment Variables Configuration

## Overview

This project uses a **single global `.env` file** in the root directory for all configuration. This approach ensures consistency and simplicity across all services.

## File Structure

```
Vijaya-Xerox-and-Stationery/
├── .env                 ← Active configuration (GIT-IGNORED) ✓
├── .env.example         ← Template for new developers (TRACKED)
├── .gitignore           ← Includes .env and .env.docker
├── docker-compose.yml   ← Reads from .env automatically
└── apps/
    └── api/
        ├── package.json ← Next.js reads parent .env automatically
        └── prisma/
            └── schema.prisma
```

## Setup Instructions

### 1. Initial Setup

```bash
# Copy the example template
cp .env.example .env

# Edit with your values
nano .env  # or your preferred editor
```

### 2. What Gets Ignored

Git automatically ignores these files:

- `.env` - Your local configuration (NEVER committed)
- `.env.docker` - Docker-specific overrides (if used)
- `.env.local` - Local development overrides
- `.env.*.local` - Environment-specific local files

### 3. What Gets Tracked

These files ARE committed to version control:

- `.env.example` - Template for all environment variables
- Other configuration files in version control

## Environment Variables

### Database Configuration

```env
DATABASE_URL="postgresql://vijaya_user:vijaya_password@vijaya_postgres:5432/vijaya_bookstore"
```

### Redis Configuration

```env
REDIS_URL="redis://localhost:6379"
REDIS_PASSWORD=""
```

### JWT Configuration

```env
JWT_SECRET="your-secret-key"
JWT_EXPIRY="7d"
JWT_REFRESH_EXPIRY="30d"
```

### API Configuration

```env
NODE_ENV="development"
PORT=3000
API_BASE_URL="http://localhost:3000"
CORS_ORIGINS="http://localhost:3001,http://localhost:8080"
```

### Docker Compose

```env
COMPOSE_PROJECT_NAME="vijaya"
```

## How Each Service Reads the Env

### Docker Compose

Docker Compose automatically loads `.env` file from the current directory:

```bash
docker compose up  # Automatically uses .env
```

### Next.js API

Next.js automatically loads environment variables from:

1. `.env.local` (if it exists)
2. `.env` in the current directory (apps/api/)
3. `.env` in parent directories (root)

Since we don't create `.env` in `apps/api/`, Next.js loads from the root `.env`.

### Prisma

Prisma reads from the same `.env` file via the `DATABASE_URL` variable.

## Development Workflow

### First Time Setup

```bash
cd Vijaya-Xerox-and-Stationery
cp .env.example .env

# Edit .env with your database credentials
# For Docker: use vijaya_postgres as host
# For local: use localhost

docker compose up -d postgres redis
cd apps/api && npm install && npm run dev
```

### For Team Members

```bash
# New team member clones the repo
git clone <repo>

# Copy template
cp .env.example .env

# Edit .env with team's shared configuration
# (database host, secrets, API keys, etc.)

docker compose up -d postgres redis
cd apps/api && npm install && npm run dev
```

## Security Best Practices

1. **Never commit `.env`** - Git ignores it automatically
2. **Commit `.env.example`** - With placeholder values
3. **Share secrets securely** - Use secure channels (Slack, 1Password, etc.)
4. **Rotate secrets regularly** - Especially `JWT_SECRET` and API keys
5. **Use strong defaults** - The provided `.env.example` has security in mind

## Production Deployment

For production:

```bash
# Use secure values (from CI/CD, secrets manager, etc.)
export DATABASE_URL="prod-database-url"
export JWT_SECRET="production-secret-key"
export RAZORPAY_KEY_ID="prod-key"
export RAZORPAY_KEY_SECRET="prod-secret"

docker compose -f docker-compose.prod.yml up
```

## Troubleshooting

### Environment Variables Not Loading

1. **Check file exists**:

   ```bash
   ls -la .env
   ```

2. **Verify content**:

   ```bash
   cat .env | head -20
   ```

3. **Restart services**:

   ```bash
   docker compose down
   docker compose up -d postgres redis
   ```

4. **For Next.js**:
   ```bash
   cd apps/api
   rm -rf .next  # Clear cache
   npm run dev
   ```

### Port Already in Use

If Docker complains about ports:

```bash
# Kill existing containers
docker compose down

# Start fresh
docker compose up -d postgres redis
```

### Database Connection Fails

Check `DATABASE_URL` format:

```bash
# Should work in Docker
DATABASE_URL="postgresql://vijaya_user:vijaya_password@vijaya_postgres:5432/vijaya_bookstore"

# For local PostgreSQL
DATABASE_URL="postgresql://vijaya_user:vijaya_password@localhost:5432/vijaya_bookstore"
```

## Environment Variables Reference

See `.env.example` for the complete list of all available environment variables and their descriptions.

---

**Last Updated**: February 7, 2026  
**Status**: Single Global .env Configuration ✓
