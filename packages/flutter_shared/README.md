# Flutter Shared Package

Shared models, utilities, and services for E-Commerce Flutter applications (Admin and Customer apps).

## Structure

```
lib/
├── models/                  # Data models
│   ├── user.dart           # User model
│   ├── category.dart       # Category model
│   ├── subject.dart        # Subject model
│   ├── product.dart        # Product model
│   ├── product_variant.dart # Product variant model
│   ├── cart_item.dart      # Cart item model
│   └── order.dart          # Order and OrderItem models
├── api/                     # API communication
│   ├── api_client.dart     # HTTP client with auth
│   └── endpoints.dart      # API endpoint constants
├── auth/                    # Authentication
│   ├── token_manager.dart  # JWT token storage/retrieval
│   └── auth_service.dart   # Login, register, logout
└── utils/                   # Utilities
    ├── validators.dart     # Form and file validators
    └── formatters.dart     # Display formatters
```

## Usage

### Models

All models support:

- `toJson()` / `fromJson()` - Serialization
- `copyWith()` - Create modified copies
- Equality operators for comparison

```dart
import 'package:flutter_shared/models/product.dart';

// From API response
final product = Product.fromJson(apiResponse);

// Modify product
final updated = product.copyWith(title: 'New Title');

// Convert to JSON
final json = updated.toJson();
```

### API Client

```dart
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/auth/token_manager.dart';

// Initialize token manager first
final tokenManager = TokenManager();
await tokenManager.initialize();

// Create API client
final apiClient = ApiClient(
  baseUrl: 'http://localhost:3000',
  tokenManager: tokenManager,
);

// Make requests
final products = await apiClient.get('/api/v1/catalog/products');
final createdProduct = await apiClient.post(
  '/api/v1/catalog/products',
  body: {'title': 'Book', 'price': 100},
);

// File upload
final response = await apiClient.multipartPost(
  '/api/v1/catalog/products/upload-image',
  fields: {'product_id': '123'},
  files: {'file': imageBytes},
);
```

### Authentication

```dart
import 'package:flutter_shared/auth/auth_service.dart';

final authService = AuthService(
  apiClient: apiClient,
  tokenManager: tokenManager,
);

// Login
final user = await authService.login(
  email: 'user@example.com',
  password: 'Password123',
);

// Register
final newUser = await authService.register(
  name: 'John Doe',
  email: 'john@example.com',
  phone: '9876543210',
  password: 'Password123',
);

// Get current user
final currentUser = await authService.getCurrentUser();

// Check login status
final isLoggedIn = await authService.isLoggedIn();
final isAdmin = await authService.isAdmin();

// Logout
await authService.logout();
```

### Validators

```dart
import 'package:flutter_shared/utils/validators.dart';

// In form fields
String? emailError = Validators.validateEmail(email);
String? passwordError = Validators.validatePassword(password);
String? phoneError = Validators.validatePhone(phone);

// Check file uploads
String? imageError = Validators.validateImageFile(
  filename: 'photo.jpg',
  fileSizeBytes: fileSize,
);

String? pdfError = Validators.validatePdfFile(
  filename: 'book.pdf',
  fileSizeBytes: fileSize,
);

// Boolean checks
if (Validators.isValidEmail(email)) {
  // Email is valid
}
```

### Formatters

```dart
import 'package:flutter_shared/utils/formatters.dart';

// Price formatting
String priceText = Formatters.formatPrice(150.50); // "₹150.50"

// Date formatting
String dateText = Formatters.formatDate(DateTime.now()); // "15 Jan 2025"
String timeText = Formatters.formatTime(DateTime.now()); // "3:45 PM"
String relativeText = Formatters.formatRelativeTime(pastDate); // "2 hours ago"

// Phone formatting
String phoneText = Formatters.formatPhone('9876543210'); // "+91 9876 5432 10"

// File size formatting
String sizeText = Formatters.formatFileSize(5242880); // "5.00 MB"

// Order status
String statusText = Formatters.formatOrderStatus('DELIVERED'); // "Delivered"

// File type
String typeText = Formatters.formatFileType('IMAGE'); // "📷 Image"
```

## Models Reference

### User

- `id: String`
- `name: String`
- `email: String`
- `phone: String`
- `role: String` (ADMIN or CUSTOMER)
- `createdAt: DateTime`

**Getters:** `isAdmin`, `isCustomer`

### Product

- `id: String`
- `title: String`
- `description: String`
- `isbn: String?`
- `basePrice: double`
- `subjectId: String`
- `imageUrl: String?` (for stationery)
- `pdfUrl: String?` (for books)
- `fileType: String` (IMAGE, PDF, or NONE)
- `isActive: bool`
- `createdAt: DateTime`
- `variants: List<ProductVariant>?`

**Getters:** `isStationery`, `isBook`, `hasFiles`, `displayPrice`

### ProductVariant

- `id: String`
- `productId: String`
- `variantType: String`
- `price: double`
- `stock: int`
- `sku: String`

**Getters:** `isInStock`

### Order

- `id: String`
- `userId: String`
- `status: String` (PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED)
- `totalPrice: double`
- `paymentStatus: String` (PENDING, PAID, FAILED)
- `addressSnapshot: Map?`
- `createdAt: DateTime`
- `items: List<OrderItem>?`

**Getters:** `isDelivered`, `isCancelled`, `isPaid`

## Dependencies

- `flutter`: SDK
- `http`: ^1.1.0 - HTTP client
- `intl`: ^0.19.0 - Internationalization (for formatting)
- `shared_preferences`: ^2.2.0 - Local storage for tokens

## Version

0.1.0 - Initial MVP release
