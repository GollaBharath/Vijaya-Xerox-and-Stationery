#!/bin/bash

# Test Firebase Login Integration
# This script tests the Firebase login endpoint

set -e

API_URL="${API_URL:-http://localhost:3000}"
ENDPOINT="/api/v1/auth/firebase-login"

echo "🧪 Testing Firebase Login Integration"
echo "======================================"
echo ""
echo "API URL: $API_URL"
echo "Endpoint: $ENDPOINT"
echo ""

# Test 1: Missing token
echo "Test 1: Missing ID token (should fail)"
echo "---------------------------------------"
RESPONSE=$(curl -s -X POST "$API_URL$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{}')
echo "Response: $RESPONSE"
echo ""

# Check if it returns an error
if echo "$RESPONSE" | grep -q "token is required"; then
  echo "✅ Test 1 passed: Correctly rejected missing token"
else
  echo "❌ Test 1 failed: Did not reject missing token"
fi
echo ""

# Test 2: Invalid token
echo "Test 2: Invalid ID token (should fail)"
echo "---------------------------------------"
RESPONSE=$(curl -s -X POST "$API_URL$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{"idToken": "invalid-token-123"}')
echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "Invalid"; then
  echo "✅ Test 2 passed: Correctly rejected invalid token"
else
  echo "❌ Test 2 failed: Did not reject invalid token properly"
fi
echo ""

echo "⚠️  Note: To fully test this endpoint, you need a valid Firebase ID token"
echo "   from a real authentication. Use the Flutter app to sign in with Google"
echo "   and the backend will automatically create the user in the database."
echo ""
echo "📱 Testing Steps:"
echo "   1. Open the Flutter app on your device/emulator"
echo "   2. Click 'Sign in with Google'"
echo "   3. Complete the Google sign-in flow"
echo "   4. Check the backend logs for user creation"
echo "   5. Try adding items to cart to verify user exists in DB"
echo ""
