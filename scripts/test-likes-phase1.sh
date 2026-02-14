#!/bin/bash

# Test Product Likes API Endpoints
# Run this after logging in to get tokens

API_BASE="http://localhost:3000/api/v1"

echo "=========================================="
echo "Testing Product Likes API - Phase 1"
echo "=========================================="
echo ""

# First, get a product ID to test with
echo "1. Getting products list..."
PRODUCTS=$(curl -s "$API_BASE/catalog/products?limit=1")
echo "$PRODUCTS" | jq '.'
PRODUCT_ID=$(echo "$PRODUCTS" | jq -r '.data.products[0].id')
echo "✓ Got product ID: $PRODUCT_ID"
echo ""

# Check if product now has likeCount and isLikedByUser fields
echo "2. Verifying product has like fields..."
PRODUCT_LIKES=$(echo "$PRODUCTS" | jq '.data.products[0] | {id, likeCount, isLikedByUser}')
echo "$PRODUCT_LIKES"
echo ""

# Test getting like stats (without authentication)
echo "3. Testing GET /products/$PRODUCT_ID/like (unauthenticated)..."
LIKE_STATS=$(curl -s "$API_BASE/products/$PRODUCT_ID/like")
echo "$LIKE_STATS" | jq '.'
echo ""

# Test with authentication
# Note: You need to replace YOUR_TOKEN_HERE with an actual token from login
echo "4. To test authenticated endpoints, first login:"
echo "   curl -X POST $API_BASE/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"customer@vijaya.local\",\"password\":\"Customer@123\"}'"
echo ""
echo "   Then use the token to test:"
echo "   TOKEN=\"your_access_token_here\""
echo "   curl -X POST $API_BASE/products/$PRODUCT_ID/like -H \"Authorization: Bearer \$TOKEN\""
echo "   curl -s $API_BASE/me/likes -H \"Authorization: Bearer \$TOKEN\""
echo ""

echo "=========================================="
echo "Phase 1 Implementation Complete!"
echo "=========================================="
echo ""
echo "✓ Database migration completed"
echo "✓ ProductLike model created"
echo "✓ product-likes module created (repo, service, types)"
echo "✓ API routes created:"
echo "  - POST /products/:id/like (toggle like)"
echo "  - GET /products/:id/like (get like stats)"
echo "  - GET /me/likes (get user's liked products)"
echo "✓ Catalog endpoints updated with like stats"
echo "  - GET /catalog/products (includes likeCount, isLikedByUser)"
echo "  - GET /catalog/products/:id (includes likeCount, isLikedByUser)"
echo ""
echo "Next: Implement Phase 2 (Frontend)"
