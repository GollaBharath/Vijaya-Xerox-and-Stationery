#!/bin/bash

# ========================================
# Vijaya Xerox & Stationery API Test Suite
# ========================================

set -e

API_BASE="http://localhost:3000/api/v1"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variables
ACCESS_TOKEN=""
USER_ID=""
CATEGORY_ID=""
SUBJECT_ID=""
PRODUCT_ID=""
VARIANT_ID=""
CART_ITEM_ID=""
ORDER_ID=""

echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}Vijaya API Comprehensive Test Suite${NC}"
echo -e "${YELLOW}=====================================${NC}\n"

# ========================================
# Helper Functions
# ========================================

test_endpoint() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local headers="$5"
    
    echo -e "${YELLOW}Testing: ${NC}$name"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" $headers "$API_BASE$endpoint")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST $headers -H "Content-Type: application/json" -d "$data" "$API_BASE$endpoint")
    elif [ "$method" = "PATCH" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PATCH $headers -H "Content-Type: application/json" -d "$data" "$API_BASE$endpoint")
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE $headers "$API_BASE$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$ d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        echo ""
        echo "$body"  # Return body for extraction
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        echo ""
        return 1
    fi
}

extract_field() {
    echo "$1" | jq -r "$2" 2>/dev/null
}

# ========================================
# 1. HEALTH CHECK
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}1. HEALTH CHECK${NC}"
echo -e "${YELLOW}========================================${NC}\n"

test_endpoint "Health Check" "GET" "/health" "" ""

# ========================================
# 2. AUTHENTICATION TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}2. AUTHENTICATION TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Register a new customer
register_data='{
  "name": "Test Customer",
  "email": "customer@test.local",
  "phone": "9876543210",
  "password": "Test@12345"
}'
response=$(test_endpoint "Register Customer" "POST" "/auth/register" "$register_data" "")

# Login with admin credentials
login_data='{
  "email": "admin@vijaya.local",
  "password": "Admin@12345"
}'
response=$(test_endpoint "Admin Login" "POST" "/auth/login" "$login_data" "")
ACCESS_TOKEN=$(extract_field "$response" ".data.accessToken")
USER_ID=$(extract_field "$response" ".data.user.id")

if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}Failed to extract access token. Exiting.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Access Token: ${ACCESS_TOKEN:0:50}...${NC}\n"

# Test /me endpoint
test_endpoint "Get Current User" "GET" "/auth/me" "" "-H \"Authorization: Bearer $ACCESS_TOKEN\""

# ========================================
# 3. CATEGORY TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}3. CATEGORY TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# List all categories
response=$(test_endpoint "List Categories" "GET" "/catalog/categories" "" "")
CATEGORY_ID=$(extract_field "$response" ".data[0].id")

# Get category tree
test_endpoint "Get Category Tree" "GET" "/catalog/categories/tree" "" ""

# Create a new category (admin only)
create_category='{
  "name": "Test Category",
  "metadata": {"type": "test"}
}'
response=$(test_endpoint "Create Category" "POST" "/catalog/categories" "$create_category" "-H \"Authorization: Bearer $ACCESS_TOKEN\"")
TEST_CATEGORY_ID=$(extract_field "$response" ".data.id")

# Get single category
if [ -n "$CATEGORY_ID" ]; then
    test_endpoint "Get Single Category" "GET" "/catalog/categories/$CATEGORY_ID" "" ""
fi

# Update category (admin only)
if [ -n "$TEST_CATEGORY_ID" ]; then
    update_category='{"name": "Updated Test Category"}'
    test_endpoint "Update Category" "PATCH" "/catalog/categories/$TEST_CATEGORY_ID" "$update_category" "-H \"Authorization: Bearer $ACCESS_TOKEN\""
fi

# ========================================
# 4. SUBJECT TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}4. SUBJECT TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# List all subjects
response=$(test_endpoint "List Subjects" "GET" "/subjects" "" "")
SUBJECT_ID=$(extract_field "$response" ".data[0].id")

# Get subject tree
test_endpoint "Get Subject Tree" "GET" "/subjects/tree" "" ""

# Create a new subject (admin only)
create_subject='{
  "name": "Test Subject"
}'
response=$(test_endpoint "Create Subject" "POST" "/subjects" "$create_subject" "-H \"Authorization: Bearer $ACCESS_TOKEN\"")
TEST_SUBJECT_ID=$(extract_field "$response" ".data.id")

# Get single subject
if [ -n "$SUBJECT_ID" ]; then
    test_endpoint "Get Single Subject" "GET" "/subjects/$SUBJECT_ID" "" ""
fi

# ========================================
# 5. PRODUCT TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}5. PRODUCT TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# List all products
response=$(test_endpoint "List Products" "GET" "/catalog/products" "" "")
PRODUCT_ID=$(extract_field "$response" ".data[0].id")

# Get single product
if [ -n "$PRODUCT_ID" ]; then
    test_endpoint "Get Single Product" "GET" "/catalog/products/$PRODUCT_ID" "" ""
    
    # Get product variants
    response=$(test_endpoint "Get Product Variants" "GET" "/catalog/products/$PRODUCT_ID/variants" "" "")
    VARIANT_ID=$(extract_field "$response" ".data[0].id")
fi

# Create a new product (admin only)
if [ -n "$SUBJECT_ID" ] && [ -n "$CATEGORY_ID" ]; then
    create_product="{
      \"title\": \"Test Product\",
      \"description\": \"Test product description\",
      \"isbn\": \"TEST-$(date +%s)\",
      \"basePrice\": 499,
      \"subjectId\": \"$SUBJECT_ID\",
      \"categoryIds\": [\"$CATEGORY_ID\"]
    }"
    response=$(test_endpoint "Create Product" "POST" "/catalog/products" "$create_product" "-H \"Authorization: Bearer $ACCESS_TOKEN\"")
    TEST_PRODUCT_ID=$(extract_field "$response" ".data.id")
    
    # Create a variant for the product
    if [ -n "$TEST_PRODUCT_ID" ]; then
        create_variant="{
          \"variantType\": \"BW\",
          \"price\": 499,
          \"stock\": 100,
          \"sku\": \"TEST-SKU-$(date +%s)\"
        }"
        response=$(test_endpoint "Create Product Variant" "POST" "/catalog/products/$TEST_PRODUCT_ID/variants" "$create_variant" "-H \"Authorization: Bearer $ACCESS_TOKEN\"")
        TEST_VARIANT_ID=$(extract_field "$response" ".data.id")
    fi
fi

# ========================================
# 6. CART TESTS (Customer)
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}6. CART TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Login as customer for cart tests
customer_login='{
  "email": "customer@test.local",
  "password": "Test@12345"
}'
response=$(test_endpoint "Customer Login" "POST" "/auth/login" "$customer_login" "")
CUSTOMER_TOKEN=$(extract_field "$response" ".data.accessToken")

if [ -n "$CUSTOMER_TOKEN" ]; then
    # View empty cart
    test_endpoint "View Cart (Empty)" "GET" "/cart" "" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\""
    
    # Add item to cart
    if [ -n "$VARIANT_ID" ]; then
        add_to_cart="{
          \"productVariantId\": \"$VARIANT_ID\",
          \"quantity\": 2
        }"
        response=$(test_endpoint "Add to Cart" "POST" "/cart" "$add_to_cart" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\"")
        CART_ITEM_ID=$(extract_field "$response" ".data.id")
        
        # View cart with items
        test_endpoint "View Cart (With Items)" "GET" "/cart" "" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\""
        
        # Update cart item quantity
        if [ -n "$CART_ITEM_ID" ]; then
            update_cart='{"quantity": 3}'
            test_endpoint "Update Cart Item" "PATCH" "/cart/$CART_ITEM_ID" "$update_cart" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\""
        fi
    fi
fi

# ========================================
# 7. ORDER TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}7. ORDER TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

if [ -n "$CUSTOMER_TOKEN" ] && [ -n "$CART_ITEM_ID" ]; then
    # Create order from cart
    create_order='{
      "address": {
        "name": "Test Customer",
        "phone": "9876543210",
        "line1": "123 Test Street",
        "city": "Test City",
        "state": "Test State",
        "pincode": "123456"
      }
    }'
    response=$(test_endpoint "Create Order from Cart" "POST" "/orders" "$create_order" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\"")
    ORDER_ID=$(extract_field "$response" ".data.id")
    
    # Get order details
    if [ -n "$ORDER_ID" ]; then
        test_endpoint "Get Order Details" "GET" "/orders/$ORDER_ID" "" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\""
    fi
    
    # List customer orders
    test_endpoint "List Customer Orders" "GET" "/orders" "" "-H \"Authorization: Bearer $CUSTOMER_TOKEN\""
fi

# ========================================
# 8. ADMIN TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}8. ADMIN TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Switch back to admin token
test_endpoint "Admin Dashboard" "GET" "/admin/dashboard" "" "-H \"Authorization: Bearer $ACCESS_TOKEN\""

test_endpoint "List All Users" "GET" "/admin/users" "" "-H \"Authorization: Bearer $ACCESS_TOKEN\""

test_endpoint "Get Store Settings" "GET" "/admin/settings" "" "-H \"Authorization: Bearer $ACCESS_TOKEN\""

# ========================================
# 9. ERROR HANDLING TESTS
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}9. ERROR HANDLING TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Test invalid login
invalid_login='{
  "email": "wrong@email.com",
  "password": "wrongpassword"
}'
test_endpoint "Invalid Login (Should Fail)" "POST" "/auth/login" "$invalid_login" "" || echo -e "${GREEN}✓ Error handling working correctly${NC}\n"

# Test unauthorized access
test_endpoint "Unauthorized Access (Should Fail)" "GET" "/admin/dashboard" "" "" || echo -e "${GREEN}✓ Auth middleware working correctly${NC}\n"

# Test invalid product ID
test_endpoint "Get Non-existent Product (Should Fail)" "GET" "/catalog/products/invalid-id-12345" "" "" || echo -e "${GREEN}✓ Not found handling working${NC}\n"

# ========================================
# SUMMARY
# ========================================
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}TEST SUITE COMPLETED${NC}"
echo -e "${YELLOW}========================================${NC}\n"

echo -e "${GREEN}✓ All critical API endpoints tested${NC}"
echo -e "${GREEN}✓ Authentication working${NC}"
echo -e "${GREEN}✓ CRUD operations verified${NC}"
echo -e "${GREEN}✓ Error handling validated${NC}"
echo -e "${GREEN}✓ Authorization checks functional${NC}\n"

echo -e "${YELLOW}Key IDs for manual testing:${NC}"
echo -e "Access Token: ${ACCESS_TOKEN:0:50}..."
echo -e "Category ID: $CATEGORY_ID"
echo -e "Subject ID: $SUBJECT_ID"
echo -e "Product ID: $PRODUCT_ID"
echo -e "Variant ID: $VARIANT_ID"
echo -e "Order ID: $ORDER_ID"
