# Upstash Redis Setup Guide

This application is configured to work with **Upstash Redis**, a serverless Redis service that's perfect for modern cloud applications.

## Why Upstash?

- **Serverless**: Pay only for what you use, no idle costs
- **Global**: Low-latency access from anywhere
- **Durable**: Data persistence with automatic backups
- **Compatible**: Works with standard Redis protocol
- **Secure**: TLS encryption by default

## Setup Steps

### 1. Create an Upstash Account

1. Go to [https://upstash.com/](https://upstash.com/)
2. Sign up for a free account
3. Verify your email

### 2. Create a Redis Database

1. In the Upstash Console, click **"Create Database"**
2. Choose your configuration:
   - **Name**: `vijaya-redis` (or any name you prefer)
   - **Region**: Select the region closest to your application
   - **Type**: Choose based on your needs:
     - **Regional**: Single region, lower latency
     - **Global**: Multi-region, highest availability
3. Click **"Create"**

### 3. Get Your Connection URL

1. After creating the database, click on it to view details
2. In the **"REST API"** section, you'll see:
   - **Endpoint** (this is your Redis URL)
   - **Password** (already included in the URL)
3. Copy the **Redis URL** which looks like:
   ```
   rediss://default:AbCdEf123456@worthy-phoenix-12345.upstash.io:6379
   ```

### 4. Configure Your Application

1. Open your `.env` file (create it from `.env.example` if it doesn't exist)
2. Update the `REDIS_URL` variable:
   ```env
   REDIS_URL="rediss://default:YOUR_PASSWORD@your-endpoint.upstash.io:6379"
   ```
3. Save the file

## Configuration Details

### Connection Format

Upstash Redis URLs use the `rediss://` protocol (note the double 's' for secure):

```
rediss://default:<password>@<endpoint>.upstash.io:<port>
```

Components:

- **Protocol**: `rediss://` (TLS-encrypted)
- **Username**: `default` (Upstash default user)
- **Password**: Your database password
- **Endpoint**: Your specific Upstash endpoint
- **Port**: Usually `6379`

### TLS/SSL

The application automatically detects Upstash URLs (starting with `rediss://`) and enables TLS configuration. This ensures:

- Encrypted data in transit
- Secure authentication
- Protection against man-in-the-middle attacks

## Features Used

This application uses Redis for:

1. **Rate Limiting**: Prevent abuse by limiting requests per user/IP
2. **Caching**: Store frequently accessed data (e.g., category tree)
3. **Session Storage**: Manage user sessions efficiently

## Testing the Connection

After configuration, start your application:

```bash
cd apps/api
npm run dev
```

Watch the logs for:

```
✓ Redis Client Connected
```

If you see this message, your Upstash Redis is properly configured!

## Troubleshooting

### Connection Failed

**Error**: "Redis Client Error: connect ECONNREFUSED"

**Solution**:

- Verify your `REDIS_URL` is correct
- Check that the URL starts with `rediss://` (not `redis://`)
- Ensure your password doesn't contain special characters that need URL encoding

### Authentication Failed

**Error**: "WRONGPASS invalid username-password pair"

**Solution**:

- Copy the complete URL from Upstash dashboard (includes password)
- Don't manually construct the URL - use the one provided by Upstash
- If password contains special characters, they should be URL-encoded

### TLS Certificate Error

**Error**: "unable to verify the first certificate"

**Solution**:

- Ensure you're using `rediss://` protocol (with double 's')
- Update Node.js to the latest LTS version
- Check your network/firewall settings

## Monitoring & Management

### Upstash Console

Access your Upstash Console to:

- View real-time metrics (commands/sec, data size, connections)
- Monitor memory usage
- Set up alerts
- View command logs
- Manage access tokens

### Performance Optimization

1. **Use Caching Wisely**: Set appropriate TTL values
2. **Batch Operations**: Use pipelines for multiple commands
3. **Monitor Keys**: Regularly check key count and sizes
4. **Set Expiration**: Always set TTL to prevent memory bloat

## Migration from Local Redis

If you're migrating from a local Redis instance:

1. **Data Export** (from local):

   ```bash
   redis-cli --rdb dump.rdb
   ```

2. **Data Import** (to Upstash):
   - Use Upstash CLI or REST API
   - Or rebuild cache naturally as the app runs

3. **Update Environment**:

   ```bash
   # Old (local)
   REDIS_URL="redis://localhost:6379"

   # New (Upstash)
   REDIS_URL="rediss://default:password@endpoint.upstash.io:6379"
   ```

4. **Test Thoroughly**: Ensure all Redis operations work correctly

## Cost Optimization

Upstash offers:

- **Free Tier**: 10,000 commands/day
- **Pay-as-you-go**: Beyond free tier
- **No Idle Costs**: Only pay for actual usage

Tips to optimize:

- Set appropriate cache TTLs
- Use Redis for hot data only
- Monitor usage in Upstash Console
- Clean up expired keys regularly

## Support

- **Upstash Documentation**: https://docs.upstash.com/redis
- **Upstash Discord**: https://upstash.com/discord
- **GitHub Issues**: Report bugs in this repository

## Additional Resources

- [Upstash Redis Documentation](https://docs.upstash.com/redis)
- [Redis Commands Reference](https://redis.io/commands)
- [Node Redis Client](https://github.com/redis/node-redis)
