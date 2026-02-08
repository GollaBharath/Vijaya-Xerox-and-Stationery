# Upstash Redis Migration Summary

## Changes Made

This document summarizes the migration from local Docker Redis to Upstash serverless Redis.

### 1. Infrastructure Changes

#### docker-compose.yml

- ✅ Removed `postgres` service (moved to external)
- ✅ Removed `redis` service (moved to Upstash)
- ✅ Removed volume definitions for `postgres_data` and `redis_data`
- ✅ Updated API service to use environment variables for database connections
- ✅ Removed service health check dependencies

#### .env.example

- ✅ Updated `DATABASE_URL` with external PostgreSQL template
- ✅ Updated `REDIS_URL` with Upstash Redis template and instructions
- ✅ Added comments explaining Upstash format

### 2. Code Changes

#### apps/api/src/lib/redis.ts

- ✅ Added automatic Upstash detection (checks for `rediss://` protocol)
- ✅ Enabled TLS configuration for secure Upstash connections
- ✅ Maintained backward compatibility with standard Redis URLs
- ✅ No breaking changes to existing API

**Key improvements:**

```typescript
// Automatic Upstash detection
const isUpstash = env.REDIS_URL.startsWith("rediss://");

// TLS configuration for secure connections
socket: isUpstash
	? {
			tls: true,
			rejectUnauthorized: true,
		}
	: undefined;
```

### 3. Documentation Updates

#### New Documentation

- ✅ Created `docs/UPSTASH_REDIS_SETUP.md` - Comprehensive Upstash setup guide
- ✅ Created `scripts/test-redis.js` - Connection testing script

#### Updated Documentation

- ✅ `README.md` - Updated tech stack to reflect Upstash
- ✅ `docs/QUICKSTART.md` - Complete rewrite for external services
- ✅ `docs/ENVIRONMENT.md` - Updated Redis configuration examples

### 4. Testing Tools

#### scripts/test-redis.js

A comprehensive testing script that:

- ✅ Validates Redis URL format
- ✅ Detects Upstash connections (TLS)
- ✅ Tests PING, SET, GET, DEL commands
- ✅ Provides troubleshooting tips on failure
- ✅ Displays server information

**Usage:**

```bash
node scripts/test-redis.js
```

### 5. Code Compatibility

#### Unchanged Files (No Breaking Changes)

- ✅ `apps/api/src/lib/rate_limiter.ts` - Works without modification
- ✅ `apps/api/src/lib/env.ts` - No changes needed
- ✅ `apps/api/src/app/api/v1/catalog/categories/tree/route.ts` - Works as-is
- ✅ All other Redis consumers - No changes required

The migration maintains 100% backward compatibility with existing code.

## Configuration Requirements

### Environment Variables

**Before (Local):**

```env
REDIS_URL="redis://redis:6379"
```

**After (Upstash):**

```env
REDIS_URL="rediss://default:password@endpoint.upstash.io:6379"
```

### Key Differences

| Aspect         | Local Redis            | Upstash Redis      |
| -------------- | ---------------------- | ------------------ |
| Protocol       | `redis://`             | `rediss://` (TLS)  |
| Host           | `localhost` or `redis` | `*.upstash.io`     |
| Port           | 6379                   | 6379               |
| Authentication | Optional               | Required           |
| TLS/SSL        | No                     | Yes (automatic)    |
| Connection     | Single instance        | Global distributed |

## Migration Steps

1. **Sign up for Upstash** at [upstash.com](https://upstash.com/)
2. **Create Redis database** in Upstash console
3. **Copy connection URL** from dashboard
4. **Update .env file** with new REDIS_URL
5. **Test connection** with `node scripts/test-redis.js`
6. **Start API** with `npm run dev`

## Benefits

### Upstash Advantages

- ✅ **Serverless**: No infrastructure management
- ✅ **Global**: Low-latency worldwide
- ✅ **Scalable**: Automatic scaling
- ✅ **Secure**: TLS encryption by default
- ✅ **Cost-effective**: Pay-per-use, free tier available
- ✅ **Reliable**: Built-in durability and backups
- ✅ **Monitoring**: Dashboard with metrics

### Development Benefits

- ✅ No Docker containers to manage
- ✅ Faster startup times
- ✅ Consistent across all environments
- ✅ Easier to share with team (just share URL)
- ✅ Better for production deployments

## Rollback Plan

If you need to revert to local Redis:

1. **Start local Redis:**

   ```bash
   docker run -d -p 6379:6379 redis:7-alpine
   ```

2. **Update .env:**

   ```env
   REDIS_URL="redis://localhost:6379"
   ```

3. **Restart API:**
   ```bash
   cd apps/api
   npm run dev
   ```

The code automatically handles both local and Upstash Redis.

## Testing Checklist

- ✅ Redis connection establishes successfully
- ✅ Rate limiting works (test with multiple requests)
- ✅ Category tree caching works
- ✅ Cache expiration works correctly
- ✅ Error handling works when Redis is unavailable
- ✅ TLS connection is secure (no certificate errors)

## Performance Considerations

### Latency

- **Local Redis**: ~1-2ms
- **Upstash Redis**: ~50-150ms (depends on region)

**Mitigation:**

- Choose Upstash region closest to your API server
- Use appropriate cache TTLs
- Implement fail-open patterns (already done)

### Best Practices

1. Set reasonable TTL values (5-30 minutes for most data)
2. Don't cache data that changes frequently
3. Use Redis for hot data only
4. Monitor cache hit rates in Upstash dashboard
5. Set up alerts for connection issues

## Troubleshooting

### Common Issues

**1. Connection Timeout**

- Verify REDIS_URL is correct
- Check firewall/network settings
- Ensure Upstash database is active

**2. Authentication Failed**

- Copy complete URL from Upstash dashboard
- Don't manually construct the URL
- Check for special characters that need encoding

**3. TLS Certificate Error**

- Ensure URL starts with `rediss://` (double 's')
- Update Node.js to latest LTS version
- Check system SSL certificates

**4. Slow Performance**

- Choose Upstash region closer to API
- Review cache TTL settings
- Check Upstash dashboard for issues

## Support

- **Upstash Docs**: https://docs.upstash.com/redis
- **Upstash Discord**: https://upstash.com/discord
- **Test Script**: `node scripts/test-redis.js`
- **API Health**: http://localhost:3000/api/v1/health

## Verification

Run these commands to verify the migration:

```bash
# 1. Test Redis connection
node scripts/test-redis.js

# 2. Start API
cd apps/api
npm run dev

# 3. Check health endpoint
curl http://localhost:3000/api/v1/health

# 4. Test cached endpoint
curl http://localhost:3000/api/v1/catalog/categories/tree

# 5. Verify rate limiting
for i in {1..10}; do curl http://localhost:3000/api/v1/auth/login -X POST; done
```

Expected results:

- ✅ Redis test passes
- ✅ API starts without errors
- ✅ "Redis Client Connected" in logs
- ✅ Health check returns 200
- ✅ Categories load and cache works
- ✅ Rate limiting applies after 5 requests

## Next Steps

1. Review [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md) for detailed setup
2. Test all Redis-dependent features
3. Monitor Upstash dashboard for metrics
4. Set up alerts for connection issues
5. Configure backups in Upstash console

## Questions?

If you encounter any issues:

1. Run `node scripts/test-redis.js` for diagnostics
2. Check API logs for connection errors
3. Review Upstash dashboard for database status
4. Consult [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)
