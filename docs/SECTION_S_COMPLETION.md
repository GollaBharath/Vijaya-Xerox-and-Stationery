# Section S: Admin App - Product Management (with File Uploads)

**Status**: ✅ COMPLETED

## Overview

Section S implements the complete product management feature for the Admin App with support for file uploads (images for stationery products, PDFs for books).

## Completed Tasks

### S1: Product Management Feature Structure ✅

Created the following folder structure:

- `lib/features/product_management/`
  - `providers/` - State management
  - `screens/` - UI screens
  - `widgets/` - Reusable components

### S2: Product Provider ✅

**File**: `lib/features/product_management/providers/product_provider.dart`

**Features**:

- `fetchProducts()` - Paginated product listing with filters
- `fetchProductDetails()` - Get single product with variants
- `createProduct()` - Create new product with file type selector
- `updateProduct()` - Update existing product
- `deleteProduct()` - Soft delete via is_active flag
- `uploadProductImage()` - Upload stationery product images (JPEG, PNG, WebP, max 5MB)
- `uploadProductPDF()` - Upload book preview PDFs (max 10MB)
- `deleteProductFiles()` - Remove uploaded files
- `loadMoreProducts()` - Pagination support
- Comprehensive state management (loading, error, pagination)

**State Properties**:

- `products` - List of products
- `selectedProduct` - Current product detail
- `isLoading` - Loading state
- `error` - Error messages
- `currentPage`, `totalPages`, `hasMore` - Pagination metadata

### S3: Product Variant Provider ✅

**File**: `lib/features/product_management/providers/variant_provider.dart`

**Features**:

- `fetchVariants()` - Get variants for a product
- `createVariant()` - Add new variant (color, B&W, size, etc.)
- `updateVariant()` - Modify variant details (price, stock, sku)
- `deleteVariant()` - Remove variant
- `selectVariant()` - Select variant for detail view

**Variant Properties**:

- `variantType` - Type of variant (e.g., "Color Print", "Hardcover")
- `price` - Variant-specific price
- `stock` - Available quantity
- `sku` - Optional stock keeping unit

### S4: Product Screens ✅

#### 4.1 Products List Screen

**File**: `lib/features/product_management/screens/products_list_screen.dart`

**Features**:

- Paginated list view with infinite scroll
- Pull-to-refresh support
- Filter by active status
- File type badges (📷 for images, 📄 for PDF)
- CRUD operations (View, Edit, Delete)
- Floating action button for adding new products
- Empty state and error state handling

**UI Elements**:

- Product card with title, description, price
- Status indicators (Active/Inactive)
- File type badges
- Action menu (View, Edit, Delete)
- AppBar with filter options

#### 4.2 Product Form Screen

**File**: `lib/features/product_management/screens/product_form_screen.dart`

**Features**:

- Create or edit products
- Form validation
- File type selector (Image, PDF, None)
- Conditional file picker widgets based on file type
- Active status toggle
- Image/PDF upload with progress
- Comprehensive error handling

**Form Fields**:

- Title (required, min 3 characters)
- Description (required, min 10 characters)
- ISBN (optional, for books)
- Base Price (required, must be > 0)
- Subject ID (required)
- File Type Selector (segmented button)
- Active Status Toggle

#### 4.3 Product Detail Screen

**File**: `lib/features/product_management/screens/product_detail_screen.dart`

**Features**:

- Display product information
- Show file preview (image or PDF)
- Manage variants with inline CRUD
- Edit product button
- Delete product confirmation
- Comprehensive product information display

**Content Sections**:

- Product header with status badge
- Description
- Pricing, ISBN, subject info
- File type indicator
- Creation timestamp
- File preview (image viewer or PDF link)
- Variants list with actions

### S5: Variant Form Screen ✅

**File**: `lib/features/product_management/screens/variant_form_screen.dart`

**Features**:

- Create or edit product variants
- Form validation
- Helper examples for variant types
- Supports optional SKU

**Form Fields**:

- Variant Type (required, e.g., "Color Print", "Hardcover")
- Price (required, must be > 0)
- Stock Quantity (required, non-negative)
- SKU (optional)

**Help Section**: Examples of variant types for different product categories

### S6: File Upload Widgets ✅

#### 6.1 Image Picker Widget

**File**: `lib/features/product_management/widgets/image_picker_widget.dart`

**Features**:

- Pick image from gallery or camera
- Image preview in grid
- File size validation (max 5MB)
- File type validation (JPEG, PNG, WebP)
- Change/remove image functionality
- Clear visual feedback

**Supported Formats**: JPEG, PNG, WebP
**Max Size**: 5MB

#### 6.2 PDF Picker Widget

**File**: `lib/features/product_management/widgets/pdf_picker_widget.dart`

**Features**:

- Pick PDF files
- PDF preview with icon and details
- File size display and formatting
- File size validation (max 10MB)
- Change/remove PDF functionality
- Information about PDF usage

**Supported Format**: PDF only
**Max Size**: 10MB

## API Integration

### Endpoints Used

All endpoints are defined in `flutter_shared/lib/api/endpoints.dart`:

```dart
static const String products = '/api/v1/catalog/products';
static const String variants = '/api/v1/catalog/variants';
static String productVariants(String productId) => '$products/$productId/variants';
static String productFiles(String id) => '$products/$id/files';
```

### API Operations

**Products**:

- `GET /api/v1/catalog/products` - List products
- `POST /api/v1/catalog/products` - Create product
- `GET /api/v1/catalog/products/{id}` - Get product details
- `PATCH /api/v1/catalog/products/{id}` - Update product
- `DELETE /api/v1/catalog/products/{id}` - Delete product
- `POST /api/v1/catalog/products/{id}/upload` - Upload image/PDF
- `DELETE /api/v1/catalog/products/{id}/files` - Delete files

**Variants**:

- `GET /api/v1/catalog/products/{productId}/variants` - List variants
- `POST /api/v1/catalog/products/{productId}/variants` - Create variant
- `PATCH /api/v1/catalog/variants/{id}` - Update variant
- `DELETE /api/v1/catalog/variants/{id}` - Delete variant

## State Management

The feature uses **Provider** package for state management:

- `ProductProvider` - Manages product list, CRUD, file uploads
- `VariantProvider` - Manages product variants

Both providers follow the same pattern:

- `ChangeNotifier` base class
- Loading/Error states
- Proper cleanup and state updates
- Notify listeners after state changes

## Navigation

Routes are integrated with the Admin App router:

- `/products` → ProductsListScreen
- `/products/form` → ProductFormScreen (create/edit)
- `/products/{id}` → ProductDetailScreen
- `/products/{id}/variant/form` → VariantFormScreen

## File Upload Flow

### Image Upload (Stationery)

1. Select file type as "Image"
2. Use ImagePickerWidget to pick image
3. Validate: format (JPEG/PNG/WebP), size (≤5MB)
4. Upload via `uploadProductImage()`
5. Display uploaded image in preview
6. Update product with imageUrl

### PDF Upload (Books)

1. Select file type as "PDF"
2. Use PdfPickerWidget to pick PDF
3. Validate: format (PDF only), size (≤10MB)
4. Upload via `uploadProductPDF()`
5. Display PDF name and link
6. Update product with pdfUrl

## Validation Rules

### Product Form

- **Title**: Required, minimum 3 characters
- **Description**: Required, minimum 10 characters
- **Base Price**: Required, must be greater than 0
- **Subject ID**: Required, valid subject ID
- **ISBN**: Optional (for books)
- **File Type**: Must be selected (Image, PDF, or None)

### Image Upload

- **Format**: JPEG, PNG, WebP only
- **Size**: Maximum 5MB
- **Source**: Gallery or Camera

### PDF Upload

- **Format**: PDF only
- **Size**: Maximum 10MB
- **Source**: File picker

### Variant Form

- **Variant Type**: Required (e.g., "Color", "Hardcover")
- **Price**: Required, must be greater than 0
- **Stock**: Required, non-negative integer (0 or more)
- **SKU**: Optional, for inventory management

## Error Handling

- Network errors with user-friendly messages
- Validation errors with specific feedback
- File upload errors (size, format, network)
- Retry mechanisms where appropriate
- Error state display with recovery options

## Testing Checklist

- [x] Create product with image
- [x] Create product with PDF
- [x] Create product with no file
- [x] Update product and change file
- [x] Upload image with validation
- [x] Upload PDF with validation
- [x] Delete product files
- [x] Delete products
- [x] List products with pagination
- [x] View product details
- [x] Create/edit/delete variants
- [x] Filter products by status
- [x] Handle errors gracefully

## Dependencies

Required packages (already in pubspec.yaml):

- `provider: ^6.1.0` - State management
- `http: ^1.1.0` - HTTP requests
- `image_picker: ^1.0.0` - Image selection
- `file_picker: ^8.0.0` - File selection
- `flutter_shared` - Shared models and utilities

## Future Enhancements

Potential improvements for future phases:

1. Batch product import/export (CSV)
2. Advanced image editing before upload
3. Product templates for variants
4. Variant preset management
5. Product duplication feature
6. Bulk operations (edit, delete)
7. Product analytics dashboard
8. SEO optimization fields
9. Product recommendations based on history
10. Discount/pricing rules per variant

## Code Quality

- Follows Dart/Flutter style guidelines
- Proper error handling and validation
- Clear separation of concerns
- Reusable widget components
- Comprehensive state management
- Type-safe API interactions
- Null safety throughout

## Summary

Section S successfully implements a complete product management system for the Admin App with professional-grade file upload capabilities. The implementation includes:

✅ Product CRUD operations
✅ Variant management
✅ Image and PDF file uploads
✅ Comprehensive validation
✅ Pagination and filtering
✅ User-friendly UI with proper feedback
✅ Error handling and recovery
✅ Provider-based state management

All components are production-ready and follow best practices for Flutter development.
