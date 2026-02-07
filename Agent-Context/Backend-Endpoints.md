# Backend API Endpoints

**Base URL**: `/api/v1`

All endpoints are versioned under `/api/v1` to support future API versions without breaking existing clients.

---

## 1. Authentication Endpoints

### POST /auth/register

**Description**: Register a new user (customer by default)  
**Auth Required**: No  
**Request Body**:

```json
{
	"name": "John Doe",
	"email": "john@example.com",
	"phone": "9876543210",
	"password": "SecurePass123"
}
```

**Response**: User object + JWT tokens

### POST /auth/login

**Description**: Authenticate user and receive tokens  
**Auth Required**: No  
**Request Body**:

```json
{
	"email": "admin@vijaya.local",
	"password": "Admin@12345"
}
```

**Response**: User object + access token + refresh token

### GET /auth/me

**Description**: Get current authenticated user details  
**Auth Required**: Yes (Bearer token)  
**Response**: User object

### POST /auth/refresh

**Description**: Refresh access token using refresh token  
**Auth Required**: Yes (Refresh token)  
**Response**: New access token

---

## 2. Catalog Endpoints

### GET /catalog/categories

**Description**: List all categories with pagination  
**Auth Required**: No  
**Query Params**: `?page=1&limit=20`  
**Response**: Array of categories + pagination metadata

### GET /catalog/categories/tree

**Description**: Get hierarchical category tree  
**Auth Required**: No  
**Caching**: Redis cached for performance  
**Response**: Nested category tree structure

### GET /catalog/categories/:id

**Description**: Get single category by ID  
**Auth Required**: No  
**Response**: Category object

### POST /catalog/categories

**Description**: Create new category (admin only)  
**Auth Required**: Yes (Admin)  
**Request Body**:

```json
{
	"name": "New Category",
	"parentId": "parent_id_or_null",
	"metadata": { "type": "books" }
}
```

### PATCH /catalog/categories/:id

**Description**: Update category (admin only)  
**Auth Required**: Yes (Admin)  
**Request Body**: Partial category fields

### DELETE /catalog/categories/:id

**Description**: Soft delete category (admin only)  
**Auth Required**: Yes (Admin)

---

## 3. Product Endpoints

### GET /catalog/products

**Description**: List all products with pagination and filters  
**Auth Required**: No  
**Query Params**:

- `page=1&limit=20` (pagination)
- `search=keyword` (search in title/description)
- `categoryId=xyz` (filter by category)
- `subjectId=xyz` (filter by subject)
- `isActive=true` (filter active/inactive)

### GET /catalog/products/:id

**Description**: Get single product with full details  
**Auth Required**: No  
**Response**: Product with variants, categories, and subject

### POST /catalog/products

**Description**: Create new product (admin only)  
**Auth Required**: Yes (Admin)  
**Request Body**:

```json
{
	"title": "Product Name",
	"description": "Product description",
	"isbn": "9781234567890",
	"basePrice": 499,
	"subjectId": "subject_id_here",
	"categoryIds": ["cat_id_1", "cat_id_2"]
}
```

### PATCH /catalog/products/:id

**Description**: Update product (admin only)  
**Auth Required**: Yes (Admin)

### DELETE /catalog/products/:id

**Description**: Soft delete product (admin only)  
**Auth Required**: Yes (Admin)

---

## 4. Product Variant Endpoints

### GET /catalog/products/:id/variants

**Description**: Get all variants for a product  
**Auth Required**: No  
**Response**: Array of product variants (COLOR/BW)

### POST /catalog/products/:id/variants

**Description**: Create product variant (admin only)  
**Auth Required**: Yes (Admin)  
**Request Body**:

```json
{
	"variantType": "COLOR",
	"price": 599,
	"stock": 100,
	"sku": "PROD-001-COLOR"
}
```

### PATCH /catalog/products/:productId/variants/:variantId

**Description**: Update variant stock and price (admin only)  
**Auth Required**: Yes (Admin)

---

## 5. Subject Endpoints

### GET /subjects

**Description**: List all subjects  
**Auth Required**: No  
**Response**: Array of subjects

### GET /subjects/tree

**Description**: Get hierarchical subject tree  
**Auth Required**: No  
**Response**: Nested subject tree structure

### GET /subjects/:id

**Description**: Get single subject by ID  
**Auth Required**: No

### POST /subjects

**Description**: Create new subject (admin only)  
**Auth Required**: Yes (Admin)  
**Request Body**:

```json
{
	"name": "Subject Name",
	"parentSubjectId": "parent_id_or_null"
}
```

### PATCH /subjects/:id

**Description**: Update subject (admin only)  
**Auth Required**: Yes (Admin)

### DELETE /subjects/:id

**Description**: Delete subject (admin only)  
**Auth Required**: Yes (Admin)

---

## 6. Cart Endpoints

### GET /cart

**Description**: View current user's cart  
**Auth Required**: Yes (Customer/Admin)  
**Response**: Array of cart items with product details

### POST /cart

**Description**: Add item to cart  
**Auth Required**: Yes (Customer/Admin)  
**Request Body**:

```json
{
	"productVariantId": "variant_id_here",
	"quantity": 2
}
```

### PATCH /cart/:itemId

**Description**: Update cart item quantity  
**Auth Required**: Yes (Customer/Admin)  
**Request Body**:

```json
{
	"quantity": 3
}
```

### DELETE /cart/:itemId

**Description**: Remove item from cart  
**Auth Required**: Yes (Customer/Admin)

### DELETE /cart/clear

**Description**: Clear entire cart  
**Auth Required**: Yes (Customer/Admin)

---

## 7. Order Endpoints

### GET /orders

**Description**: List current user's orders  
**Auth Required**: Yes (Customer/Admin)  
**Query Params**: `?page=1&limit=10`  
**Response**: Array of orders + pagination

### POST /orders

**Description**: Create order from cart (checkout)  
**Auth Required**: Yes (Customer/Admin)  
**Request Body**:

```json
{
	"address": {
		"name": "John Doe",
		"phone": "9876543210",
		"line1": "123 Main Street",
		"city": "Mumbai",
		"state": "Maharashtra",
		"pincode": "400001"
	}
}
```

**Process**:

1. Validates cart items
2. Checks stock availability
3. Creates order + order items
4. Decrements stock
5. Clears cart
6. Returns order details

### GET /orders/:id

**Description**: Get order details  
**Auth Required**: Yes (Customer/Admin)  
**Response**: Order with items, products, and variants

### POST /orders/:id/cancel

**Description**: Cancel order  
**Auth Required**: Yes (Customer/Admin)  
**Restrictions**: Cannot cancel delivered orders

---

## 8. Admin - Dashboard

### GET /admin/dashboard

**Description**: Get admin dashboard statistics  
**Auth Required**: Yes (Admin only)  
**Response**:

```json
{
  "totalUsers": 100,
  "totalOrders": 50,
  "totalRevenue": 125000,
  "recentOrders": [...]
}
```

---

## 9. Admin - User Management

### GET /admin/users

**Description**: List all users  
**Auth Required**: Yes (Admin only)  
**Query Params**: `?page=1&limit=20`

### GET /admin/users/:id

**Description**: Get user by ID  
**Auth Required**: Yes (Admin only)

### PATCH /admin/users/:id

**Description**: Update user details  
**Auth Required**: Yes (Admin only)  
**Request Body**:

```json
{
	"name": "Updated Name",
	"email": "new@email.com",
	"phone": "9876543210",
	"role": "ADMIN",
	"isActive": true,
	"password": "NewPassword123" // optional
}
```

### DELETE /admin/users/:id

**Description**: Deactivate user (soft delete)  
**Auth Required**: Yes (Admin only)

---

## 10. Admin - Settings

### GET /admin/settings

**Description**: Get all store settings  
**Auth Required**: Yes (Admin only)  
**Response**: Key-value pairs of settings

### POST /admin/settings

**Description**: Update store settings  
**Auth Required**: Yes (Admin only)  
**Request Body**:

```json
{
	"key": "allow_cod",
	"valueJson": { "enabled": true }
}
```

---

## 11. Health Check

### GET /health

**Description**: API health check endpoint  
**Auth Required**: No  
**Response**:

```json
{
	"status": "ok",
	"message": "API is running",
	"timestamp": "2026-02-07T10:00:00.000Z"
}
```

---

## Response Formats

### Success Response

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message",
  "pagination": {  // Only for paginated endpoints
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

### Error Response

```json
{
	"success": false,
	"error": {
		"code": "ERROR_CODE",
		"message": "Human-readable error message",
		"field": "fieldName", // For validation errors
		"details": {} // Optional additional context
	}
}
```

---

## Error Codes

- `UNAUTHORIZED` (401) - Authentication required or token invalid
- `FORBIDDEN` (403) - Insufficient permissions
- `NOT_FOUND` (404) - Resource not found
- `VALIDATION_ERROR` (400) - Invalid input data
- `BAD_REQUEST` (400) - Malformed request
- `INTERNAL_SERVER_ERROR` (500) - Server error
- `INSUFFICIENT_STOCK` (400) - Not enough stock for order
- `RATE_LIMIT_EXCEEDED` (429) - Too many requests

---

## Authentication

All authenticated endpoints require the following header:

```
Authorization: Bearer {accessToken}
```

Tokens expire after 7 days (configurable). Use the refresh endpoint to get a new access token.

---

## Rate Limiting

- **Auth endpoints**: 5 requests per 15 minutes per IP
- **API endpoints**: 100 requests per 1 minute per IP

Rate limiting gracefully fails open if Redis is unavailable.

---

## Testing Credentials

**Admin Account**:

- Email: `admin@vijaya.local`
- Password: `Admin@12345`

---

**Note**: This file is referenced in Architecture.md, checklist.md, and Folder-structure.md for complete API documentation.
