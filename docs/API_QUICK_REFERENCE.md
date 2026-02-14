# API Quick Reference for Android Development

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

### Register

```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "SecurePass123"
}
```

### Login

```http
POST /auth/login
Content-Type: application/json

{
  "email": "admin@vijaya.local",
  "password": "Admin@12345"
}
```

**Response**:

```json
{
  "success": true,
  "data": {
    "user": { ... },
    "tokens": {
      "accessToken": "eyJhbG...",
      "refreshToken": "eyJhbG...",
      "expiresIn": "7d"
    }
  }
}
```

### Get Current User

```http
GET /auth/me
Authorization: Bearer {accessToken}
```

## User Profile

### Get Profile

```http
GET /me/profile
Authorization: Bearer {accessToken}
```

**Response**:

```json
{
	"success": true,
	"data": {
		"user": {
			"id": "user_id",
			"name": "John Doe",
			"email": "john@example.com",
			"phone": "9876543210",
			"address": "123 Main St",
			"city": "Mumbai",
			"state": "Maharashtra",
			"pincode": "400001",
			"landmark": "Near City Mall",
			"createdAt": "2024-01-01T00:00:00.000Z",
			"updatedAt": "2024-01-01T00:00:00.000Z"
		}
	}
}
```

### Update Profile

```http
PATCH /me/profile
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "John Doe",
  "phone": "9876543210",
  "address": "123 Main St, Apt 4B",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001",
  "landmark": "Near City Mall"
}
```

**Note**: All fields are optional. You can update any combination of fields.
The pincode must be a 6-digit number. Phone must be a valid format.

**Response**:

```json
{
	"success": true,
	"data": {
		"user": {
			/* updated user object */
		}
	},
	"message": "Profile updated successfully"
}
```

## Catalog

### List Categories

```http
GET /catalog/categories?page=1&limit=20
```

### Category Tree (Hierarchical)

```http
GET /catalog/categories/tree
```

### List Products

```http
GET /catalog/products?page=1&limit=20
```

### Get Product Details

```http
GET /catalog/products/{productId}
```

### Get Product Variants

```http
GET /catalog/products/{productId}/variants
```

## Subjects

### List Subjects

```http
GET /subjects
```

### Subject Tree (Hierarchical)

```http
GET /subjects/tree
```

## Cart (Customer)

### View Cart

```http
GET /cart
Authorization: Bearer {customerToken}
```

### Add to Cart

```http
POST /cart
Authorization: Bearer {customerToken}
Content-Type: application/json

{
  "productVariantId": "variant_id_here",
  "quantity": 2
}
```

### Update Cart Item

```http
PATCH /cart/{cartItemId}
Authorization: Bearer {customerToken}
Content-Type: application/json

{
  "quantity": 3
}
```

### Remove from Cart

```http
DELETE /cart/{cartItemId}
Authorization: Bearer {customerToken}
```

### Clear Cart

```http
DELETE /cart/clear
Authorization: Bearer {customerToken}
```

## Orders (Customer)

### Create Order

```http
POST /orders
Authorization: Bearer {customerToken}
Content-Type: application/json

{
  "address": {
    "name": "John Doe",
    "phone": "9876543210",
    "address": "123 Main Street, Apt 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001",
    "landmark": "Near City Mall"
  }
}
```

**Important**:

- The `address` field is **optional** in the request
- If not provided, the system will automatically use the address from the user's profile (if available)
- If no address is provided and the user's profile doesn't have address information, the request will fail with an error
- **Recommendation**: Always update the user's profile with their default address first, then the checkout can be done without providing address every time

**Alternative - No address in request (uses profile)**:

```http
POST /orders
Authorization: Bearer {customerToken}
Content-Type: application/json

{}
```

This will work if the user has complete address information in their profile.

### List Orders

```http
GET /orders?page=1&limit=10
Authorization: Bearer {customerToken}
```

### Get Order Details

```http
GET /orders/{orderId}
Authorization: Bearer {customerToken}
```

### Cancel Order

```http
POST /orders/{orderId}/cancel
Authorization: Bearer {customerToken}
```

## Admin Endpoints

### Dashboard Stats

```http
GET /admin/dashboard
Authorization: Bearer {adminToken}
```

**Response**:

```json
{
  "success": true,
  "data": {
    "totalUsers": 100,
    "totalOrders": 50,
    "totalRevenue": 125000,
    "recentOrders": [...]
  }
}
```

### List All Users

```http
GET /admin/users?page=1&limit=20
Authorization: Bearer {adminToken}
```

### Get User by ID

```http
GET /admin/users/{userId}
Authorization: Bearer {adminToken}
```

### Update User

```http
PATCH /admin/users/{userId}
Authorization: Bearer {adminToken}
Content-Type: application/json

{
  "name": "Updated Name",
  "role": "ADMIN",
  "isActive": true
}
```

### Create Category

```http
POST /catalog/categories
Authorization: Bearer {adminToken}
Content-Type: application/json

{
  "name": "New Category",
  "parentId": null,
  "metadata": { "type": "books" }
}
```

### Create Product

```http
POST /catalog/products
Authorization: Bearer {adminToken}
Content-Type: application/json

{
  "title": "Product Name",
  "description": "Product description",
  "isbn": "9781234567890",
  "basePrice": 499,
  "subjectId": "subject_id_here",
  "categoryIds": ["cat_id_1", "cat_id_2"]
}
```

### Create Product Variant

```http
POST /catalog/products/{productId}/variants
Authorization: Bearer {adminToken}
Content-Type: application/json

{
  "variantType": "COLOR",
  "price": 599,
  "stock": 100,
  "sku": "PROD-001-COLOR"
}
```

### Get Store Settings

```http
GET /admin/settings
Authorization: Bearer {adminToken}
```

## Error Responses

### 401 Unauthorized

```json
{
	"success": false,
	"error": {
		"code": "UNAUTHORIZED",
		"message": "Authentication required"
	}
}
```

### 403 Forbidden

```json
{
	"success": false,
	"error": {
		"code": "FORBIDDEN",
		"message": "Admin access required"
	}
}
```

### 400 Validation Error

```json
{
	"success": false,
	"error": {
		"code": "VALIDATION_ERROR",
		"message": "Invalid email format",
		"field": "email"
	}
}
```

### 404 Not Found

```json
{
	"success": false,
	"error": {
		"code": "NOT_FOUND",
		"message": "Product not found"
	}
}
```

## Response Format

All successful responses follow this structure:

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

## Authentication Flow

1. **Register/Login** → Get `accessToken`
2. **Store token** in secure storage (Android SharedPreferences or Keystore)
3. **Include in headers** for all authenticated requests:
   ```
   Authorization: Bearer {accessToken}
   ```
4. **Handle 401** → Refresh token or redirect to login

## Testing Credentials

### Admin

- **Email**: `admin@vijaya.local`
- **Password**: `Admin@12345`

### Test Customer (if you registered during testing)

- **Email**: Check test output
- **Password**: `Test@12345`

## Notes

- All timestamps are in ISO 8601 format
- Pagination starts at page 1
- Default limit is 20 items per page
- JWT tokens expire in 7 days (configurable)
- Refresh tokens expire in 30 days (configurable)

---

**For detailed documentation, see**: `Agent-Context/BACKEND_REVIEW_REPORT.md`
