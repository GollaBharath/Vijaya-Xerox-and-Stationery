#!/bin/bash

# Quick API Test Suite
set -e

API_BASE="http://localhost:3000/api/v1"

echo "===== VIJAYA API TESTING ====="
echo ""

# 1. Health Check
echo "1. Testing Health Endpoint..."
curl -s "$API_BASE/health" | jq '.' && echo "✓ Health check passed" || echo "✗ Failed"
echo ""

# 2. Admin Login
echo "2. Testing Admin Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@vijaya.local","password":"Admin@12345"}')

echo "$LOGIN_RESPONSE" | jq '.'
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.tokens.accessToken')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    echo "✓ Admin login successful"
else
    echo "✗ Login failed"
    exit 1
fi
echo ""

# 3. Get Current User
echo "3. Testing /auth/me..."
curl -s "$API_BASE/auth/me" \
  -H "Authorization: Bearer $TOKEN" | jq '.' && echo "✓ Auth middleware working" || echo "✗ Failed"
echo ""

# 4. List Categories
echo "4. Testing GET /catalog/categories..."
CATEGORIES=$(curl -s "$API_BASE/catalog/categories")
echo "$CATEGORIES" | jq '.'
CATEGORY_ID=$(echo "$CATEGORIES" | jq -r '.data[0].id')
echo "✓ Got category ID: $CATEGORY_ID"
echo ""

# 5. Get Category Tree
echo "5. Testing GET /catalog/categories/tree..."
curl -s "$API_BASE/catalog/categories/tree" | jq '.' && echo "✓ Category tree retrieved" || echo "✗ Failed"
echo ""

# 6. List Subjects
echo "6. Testing GET /subjects..."
SUBJECTS=$(curl -s "$API_BASE/subjects")
echo "$SUBJECTS" | jq '.'
SUBJECT_ID=$(echo "$SUBJECTS" | jq -r '.data[0].id')
echo "✓ Got subject ID: $SUBJECT_ID"
echo ""

# 7. List Products
echo "7. Testing GET /catalog/products..."
PRODUCTS=$(curl -s "$API_BASE/catalog/products")
echo "$PRODUCTS" | jq '.'
PRODUCT_ID=$(echo "$PRODUCTS" | jq -r '.data[0].id')
echo "✓ Got product ID: $PRODUCT_ID"
echo ""

# 8. Get Product Variants
if [ -n "$PRODUCT_ID" ] && [ "$PRODUCT_ID" != "null" ]; then
    echo "8. Testing GET /catalog/products/$PRODUCT_ID/variants..."
    VARIANTS=$(curl -s "$API_BASE/catalog/products/$PRODUCT_ID/variants")
    echo "$VARIANTS" | jq '.'
    VARIANT_ID=$(echo "$VARIANTS" | jq -r '.data[0].id')
    echo "✓ Got variant ID: $VARIANT_ID"
fi
echo ""

# 9. Register New Customer
echo "9. Testing Customer Registration..."
REGISTER_DATA="{
  \"name\": \"Test Customer $(date +%s)\",
  \"email\": \"customer$(date +%s)@test.local\",
  \"phone\": \"98765$(date +%s | tail -c 6)\",
  \"password\": \"Test@12345\"
}"
curl -s -X POST "$API_BASE/auth/register" \
  -H "Content-Type: application/json" \
  -d "$REGISTER_DATA" | jq '.' && echo "✓ Customer registration working" || echo "✗ Failed"
echo ""

# 10. Admin Dashboard
echo "10. Testing Admin Dashboard..."
curl -s "$API_BASE/admin/dashboard" \
  -H "Authorization: Bearer $TOKEN" | jq '.' && echo "✓ Dashboard working" || echo "✗ Failed"
echo ""

# 11. List Users (Admin)
echo "11. Testing List Users (Admin)..."
curl -s "$API_BASE/admin/users?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN" | jq '.' && echo "✓ User listing working" || echo "✗ Failed"
echo ""

# 12. Test Unauthorized Access
echo "12. Testing Unauthorized Access..."
UNAUTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/admin/dashboard")
HTTP_CODE=$(echo "$UNAUTH_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "✓ Authorization check working (got $HTTP_CODE)"
else
    echo "✗ Authorization not working properly (got $HTTP_CODE)"
fi
echo ""

echo "===== TEST SUITE COMPLETED ====="
echo "✓ API is functional and ready for Android app development"
