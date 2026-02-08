#!/bin/bash

# Quick API Test Script
API_BASE="http://localhost:3000/api/v1"

echo "=== Quick API Test ==="
echo ""

# 1. Health Check
echo "1. Health Check:"
curl -s "$API_BASE/health" | jq '.'
echo ""

# 2. Admin Login
echo "2. Admin Login:"
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"email":"admin@vijaya.local","password":"Admin@12345"}' \
  "$API_BASE/auth/login")
echo "$LOGIN_RESPONSE" | jq '.'

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.tokens.accessToken')
echo ""
echo "Token: ${TOKEN:0:50}..."
echo ""

# 3. Get Products
echo "3. List Products:"
curl -s "$API_BASE/catalog/products" | jq '.data[] | {id, title, basePrice}'
echo ""

# 4. Get Categories
echo "4. List Categories:"
curl -s "$API_BASE/catalog/categories" | jq '.data[] | {id, name}'
echo ""

# 5. Get Subjects
echo "5. List Subjects:"
curl -s "$API_BASE/subjects" | jq '.data[] | {id, name}'
echo ""

# 6. Admin Dashboard (with auth)
echo "6. Admin Dashboard:"
curl -s -H "Authorization: Bearer $TOKEN" "$API_BASE/admin/dashboard" | jq '.'
echo ""

echo "=== Test Complete ==="
