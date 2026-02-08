# ✅ Upstash Redis Migration Checklist

Use this checklist to verify your Upstash Redis setup is complete and working.

## Pre-Migration

- [ ] Read [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)
- [ ] Create Upstash account at [upstash.com](https://upstash.com/)
- [ ] Have access to external PostgreSQL database

## Upstash Setup

- [ ] Create new Redis database in Upstash console
- [ ] Choose appropriate region (closest to your API server)
- [ ] Copy connection URL from Upstash dashboard
- [ ] Verify URL format: `rediss://default:password@endpoint.upstash.io:6379`

## Configuration

- [ ] Copy `.env.example` to `.env` if not already done
- [ ] Update `REDIS_URL` in `.env` with Upstash URL
- [ ] Update `DATABASE_URL` in `.env` with PostgreSQL URL
- [ ] Verify all other required environment variables are set
- [ ] Save and close `.env` file

## Testing

- [ ] Run Redis connection test: `node scripts/test-redis.js`
- [ ] Verify "Connection successful" message appears
- [ ] Check that PING, SET, GET, DEL commands work
- [ ] Install dependencies: `cd apps/api && npm install`
- [ ] Start API server: `npm run dev`
- [ ] Look for "Redis Client Connected" in console logs

## Functionality Testing

- [ ] Test health endpoint: `curl http://localhost:3000/api/v1/health`
- [ ] Test category tree (caching): `curl http://localhost:3000/api/v1/catalog/categories/tree`
- [ ] Call category tree again, verify faster response (cached)
- [ ] Test rate limiting: Make 10+ rapid requests to `/api/v1/auth/login`
- [ ] Verify rate limiting blocks after threshold

## Monitoring

- [ ] Open Upstash dashboard
- [ ] Check "Commands" metric is increasing
- [ ] Verify "Memory Used" shows data
- [ ] Check "Connections" shows active connection
- [ ] Review any error logs in dashboard

## Documentation Review

- [ ] Read through [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)
- [ ] Review [QUICKSTART.md](./QUICKSTART.md) for updated setup steps
- [ ] Check [UPSTASH_MIGRATION_SUMMARY.md](./UPSTASH_MIGRATION_SUMMARY.md)
- [ ] Update team documentation if needed

## Production Considerations

- [ ] Set up monitoring alerts in Upstash
- [ ] Configure backup schedule in Upstash console
- [ ] Document Upstash credentials in secure location
- [ ] Add Upstash URL to CI/CD pipeline secrets
- [ ] Test failover behavior (what happens if Redis is down?)
- [ ] Review cache TTL values for production workload
- [ ] Monitor costs in Upstash billing dashboard

## Optional Optimizations

- [ ] Review cache hit rates in Upstash dashboard
- [ ] Adjust TTL values based on usage patterns
- [ ] Add more caching to frequently accessed endpoints
- [ ] Set up Redis key expiration monitoring
- [ ] Configure memory eviction policy in Upstash
- [ ] Add Redis performance metrics to application monitoring

## Troubleshooting (If Issues Occur)

- [ ] Verify REDIS_URL starts with `rediss://` (double 's')
- [ ] Check Upstash dashboard for database status
- [ ] Run `node scripts/test-redis.js` for diagnostics
- [ ] Review API logs for connection errors
- [ ] Test network connectivity to Upstash endpoint
- [ ] Verify no firewall blocking port 6379
- [ ] Check Node.js version (should be 18+)
- [ ] Ensure TLS certificates are up to date

## Rollback (If Needed)

- [ ] Start local Redis: `docker run -d -p 6379:6379 redis:7-alpine`
- [ ] Update `REDIS_URL` to `redis://localhost:6379`
- [ ] Restart API server
- [ ] Verify functionality restored

## Completion

- [ ] All tests passing ✅
- [ ] API running without errors ✅
- [ ] Redis client connected ✅
- [ ] Caching working ✅
- [ ] Rate limiting working ✅
- [ ] Team notified of changes ✅
- [ ] Documentation updated ✅

---

## Quick Test Commands

```bash
# Test Redis connection
node scripts/test-redis.js

# Start API
cd apps/api && npm run dev

# Health check
curl http://localhost:3000/api/v1/health

# Test caching
curl http://localhost:3000/api/v1/catalog/categories/tree

# Test rate limiting (run multiple times)
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"test"}';
  echo "";
done
```

## Support

- **Upstash Docs**: https://docs.upstash.com/redis
- **Test Script**: `node scripts/test-redis.js`
- **Setup Guide**: [UPSTASH_REDIS_SETUP.md](./UPSTASH_REDIS_SETUP.md)
- **Migration Summary**: [UPSTASH_MIGRATION_SUMMARY.md](./UPSTASH_MIGRATION_SUMMARY.md)

---

**Migration Date**: ********\_********

**Verified By**: ********\_********

**Issues Encountered**: ********\_********

**Resolution**: ********\_********
