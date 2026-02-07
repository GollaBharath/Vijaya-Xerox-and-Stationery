# Phase 1 MVP - Development Checklist

**Target**: Production-ready MVP with Auth, Catalog, Cart, Orders, and Admin CRUD.

**NEW REQUIREMENTS**:

- **Product Media**: Stationery products have IMAGE uploads, Books have PDF uploads (preview)
- **Development Order**: Backend with media support → Admin App → Customer App

**Principles**:

- Follow the Architecture.md, Folder-structure.md, and Backend-Endpoints.md exactly
- Complete 1 task at a time, in order
- Do NOT skip tasks
- Commit after each major section
- Test before moving to next task
- All documentation goes in `/docs` directory only

---

## SECTION A: PROJECT INITIALIZATION

### A1. Create monorepo folder structure

- [✅] Acknowledge root directory: `./`
- [✅] Create subdirectories: `apps/`, `packages/`, `infrastructure/`, `docs/`, `scripts/`

### A2. Create root configuration files

- [✅] Create `.env.example` with all required env vars
- [✅] Create `docker-compose.yml` (basic structure)
- [✅] Create `README.md` with setup instructions
- [✅] Create `.gitignore` (Node, Flutter, common patterns)

---

## SECTION B: DATABASE & PRISMA SETUP

### B1. Initialize Next.js API project

- [✅] Create `/apps/api` folder
- [✅] Initialize Next.js project (with TypeScript)
- [✅] Install dependencies: `prisma`, `@prisma/client`, `jsonwebtoken`, `bcrypt`, `dotenv`
- [✅] Set up `tsconfig.json` and `next.config.js`

### B2. Configure Prisma

- [✅] Create `prisma/schema.prisma`
- [✅] Define PostgreSQL datasource
- [✅] Create `.env` file with `DATABASE_URL`

### B3. Define Prisma schema (all models from Architecture.md)

- [✅] Create `users` table with fields: id, name, phone, email, password_hash, role, created_at
- [✅] Create `categories` table with fields: id, name, parent_id, metadata (JSON), is_active, created_at
- [✅] Create `subjects` table with fields: id, name, parent_subject_id
- [✅] Create `products` table with fields: id, title, description, isbn, base_price, subject_id, is_active, created_at
- [✅] Create `product_variants` table with fields: id, product_id, variant_type (enum), price, stock, sku
- [✅] Create `product_categories` table (junction) with fields: product_id, category_id
- [✅] Create `orders` table with fields: id, user_id, status (enum), total_price, payment_status, address_snapshot, created_at
- [✅] Create `order_items` table with fields: id, order_id, product_variant_id, quantity, price_snapshot
- [✅] Create `store_settings` table with fields: key, value_json
- [✅] Create `cart_items` table with fields: id, user_id, product_variant_id, quantity, created_at

### B4. Create and run first migration

- [✅] Run `prisma migrate dev --name initial`
- [✅] Verify migration files created in `prisma/migrations/`

---

## SECTION C: BACKEND INFRASTRUCTURE & UTILS

### C1. Create lib utilities

- [✅] Create `src/lib/prisma.ts` (singleton Prisma client)
- [✅] Create `src/lib/env.ts` (validated env variables)
- [✅] Create `src/lib/redis.ts` (Redis client setup)
- [✅] Create `src/lib/logger.ts` (simple logger)
- [✅] Create `src/lib/rate_limiter.ts` (basic rate limiting)

### C2. Create global types

- [✅] Create `src/types/global.d.ts` with API response types
- [✅] Define common types: `ApiResponse<T>`, `ApiError`, `Pagination`

### C3. Create middleware

- [✅] Create `src/middleware/auth.middleware.ts` (JWT verification)
- [✅] Create `src/middleware/admin.middleware.ts` (admin role check)
- [✅] Create `src/middleware/error.middleware.ts` (error handler wrapper)

### C4. Create utility functions

- [✅] Create `src/utils/validators.ts` (email, phone, password validators)
- [✅] Create `src/utils/pagination.ts` (limit/offset logic)
- [✅] Create `src/utils/helpers.ts` (common helpers)

---

## SECTION D: BACKEND MODULES - AUTH

### D1. Create auth module structure

- [✅] Create `src/modules/auth/` folder
- [✅] Create `auth.types.ts` with: LoginRequest, LoginResponse, RegisterRequest, etc.
- [✅] Create `auth.validator.ts` with: validateLogin(), validateRegister()

### D2. Create auth repository

- [✅] Create `auth.repo.ts` with:
  - `findUserByEmail(email)`
  - `findUserById(id)`
  - `createUser(name, email, phone, password_hash, role)`
  - `updatePassword(userId, newHash)`

### D3. Create auth service

- [✅] Create `auth.service.ts` with:
  - `register(data)` - validate, hash password, create user, return token
  - `login(email, password)` - validate, verify password, return token
  - `verifyToken(token)` - JWT verification
  - `generateTokens(userId, role)` - access + refresh tokens

### D4. Create auth route handlers

- [✅] Create `src/app/api/v1/auth/register/route.ts` (POST)
  - Validate request
  - Call auth.service.register()
  - Return user + access token
- [✅] Create `src/app/api/v1/auth/login/route.ts` (POST)
  - Validate request
  - Call auth.service.login()
  - Return user + access token
- [✅] Create `src/app/api/v1/auth/refresh/route.ts` (POST)
  - Refresh token validation
  - Return new access token
- [✅] Create `src/app/api/v1/auth/me/route.ts` (GET)
  - Requires auth middleware
  - Return current user

---

## SECTION E: BACKEND MODULES - CATALOG (CATEGORIES & PRODUCTS)

### E1. Create catalog module structure

- [✅] Create `src/modules/catalog/` folder
- [✅] Create `catalog.types.ts` with: Category, Product, ProductVariant types
- [✅] Create `catalog.validator.ts` with validation functions

### E2. Create category repository

- [✅] Create `category.repo.ts` with:
  - `findCategoryById(id)`
  - `findAllCategories(is_active)`
  - `createCategory(name, parent_id, metadata)`
  - `updateCategory(id, name, metadata, is_active)`
  - `deleteCategory(id)` (soft delete via is_active)
  - `getCategoryTree()` (hierarchical structure)

### E3. Create category route handlers

- [✅] Create `src/app/api/v1/catalog/categories/route.ts` (GET list, POST create - admin only)
- [✅] Create `src/app/api/v1/catalog/categories/[id]/route.ts` (GET, PATCH, DELETE - admin only)
- [✅] Create `src/app/api/v1/catalog/categories/tree/route.ts` (GET - category hierarchy with caching)

### E4. Create product repository

- [✅] Create `product.repo.ts` with:
  - `findProductById(id)`
  - `findProductsByCategory(categoryId, pagination)`
  - `findProductsBySubject(subjectId, pagination)`
  - `findAllProducts(pagination, filters)`
  - `createProduct(title, description, isbn, base_price, subject_id)`
  - `updateProduct(id, data)`
  - `deleteProduct(id)` (soft delete via is_active)
  - `getProductWithVariants(id)`

### E5. Create product variant repository

- [✅] Create `variant.repo.ts` with:
  - `findVariantById(id)`
  - `findVariantsByProduct(product_id)`
  - `createVariant(product_id, variant_type, price, stock, sku)`
  - `updateVariant(id, price, stock)`
  - `updateStock(variant_id, quantity_change)`
  - `checkStock(variant_id, quantity)`

### E6. Create product route handlers

- [✅] Create `src/app/api/v1/catalog/products/route.ts` (GET list, POST create - admin only)
- [✅] Create `src/app/api/v1/catalog/products/[id]/route.ts` (GET, PATCH, DELETE - admin only)
- [✅] Create `src/app/api/v1/catalog/products/[id]/variants/route.ts` (GET, POST - admin can POST)

---

## SECTION F: BACKEND MODULES - SUBJECTS

### F1. Create subjects module

- [✅] Create `src/modules/subjects/` folder
- [✅] Create `subjects.types.ts`
- [✅] Create `subjects.validator.ts`

### F2. Create subject repository

- [✅] Create `subjects.repo.ts` with:
  - `findSubjectById(id)`
  - `findAllSubjects()`
  - `createSubject(name, parent_subject_id)`
  - `updateSubject(id, name, parent_subject_id)`
  - `deleteSubject(id)`
  - `getSubjectTree()` (hierarchical structure)

### F3. Create subject route handlers

- [✅] Create `src/app/api/v1/subjects/route.ts` (GET list, POST create - admin only)
- [✅] Create `src/app/api/v1/subjects/[id]/route.ts` (GET, PATCH, DELETE - admin only)
- [✅] Create `src/app/api/v1/subjects/tree/route.ts` (GET - subject hierarchy)

---

## SECTION G: BACKEND MODULES - CART

### G1. Create cart module

- [✅] Create `src/modules/cart/` folder
- [✅] Create `cart.types.ts`
- [✅] Create `cart.validator.ts`

### G2. Create cart repository

- [✅] Create `cart.repo.ts` with:
  - `getCartByUserId(user_id)`
  - `getCartItems(user_id, pagination)`
  - `addToCart(user_id, product_variant_id, quantity)`
  - `updateCartItem(cart_item_id, quantity)`
  - `removeFromCart(cart_item_id)`
  - `clearCart(user_id)`
  - `getCartTotal(user_id)` (sum prices)

### G3. Create cart route handlers

- [✅] Create `src/app/api/v1/cart/route.ts` (GET cart, POST add item - auth required)
- [✅] Create `src/app/api/v1/cart/[itemId]/route.ts` (PATCH quantity, DELETE item - auth required)
- [✅] Create `src/app/api/v1/cart/clear/route.ts` (DELETE all - auth required)

---

## SECTION H: BACKEND MODULES - ORDERS

### H1. Create orders module

- [✅] Create `src/modules/orders/` folder
- [✅] Create `orders.types.ts`
- [✅] Create `orders.validator.ts`

### H2. Create order repository

- [✅] Create `orders.repo.ts` with:
  - `findOrderById(id)`
  - `findOrdersByUserId(user_id, pagination)`
  - `findAllOrders(pagination, filters)` - admin only
  - `createOrder(user_id, order_items, address_snapshot, total_price)`
  - `updateOrderStatus(id, status)`
  - `updatePaymentStatus(id, payment_status)`
  - `cancelOrder(id)`

### H3. Create order service

- [✅] Create `orders.service.ts` with:
  - `checkoutCart(user_id, address)` - validate cart, check stock, create order, clear cart
  - `getOrderDetails(orderId)` - fetch order with items and product details

### H4. Create order route handlers

- [✅] Create `src/app/api/v1/orders/route.ts` (GET list - auth required, POST create - auth required)
- [✅] Create `src/app/api/v1/orders/[id]/route.ts` (GET order details - auth required)
- [✅] Create `src/app/api/v1/orders/[id]/cancel/route.ts` (POST cancel - auth required)

---

## SECTION I: BACKEND MODULES - STORE SETTINGS

### I1. Create settings module

- [✅] Create `src/modules/settings/` folder
- [✅] Create `settings.types.ts`

### I2. Create settings repository

- [✅] Create `settings.repo.ts` with:
  - `getSetting(key)`
  - `getAllSettings()`
  - `setSetting(key, value_json)`
  - `deleteSetting(key)`

### I3. Create settings route handlers

- [✅] Create `src/app/api/v1/admin/settings/route.ts` (GET, POST - admin only)

---

## SECTION J: BACKEND MODULES - ADMIN ENDPOINTS

### J1. Create admin users endpoint

- [✅] Create `src/app/api/v1/admin/users/route.ts` (GET all users - admin only)
- [✅] Create `src/app/api/v1/admin/users/[id]/route.ts` (GET, PATCH, DELETE - admin only)

### J2. Create admin dashboard endpoint

- [✅] Create `src/app/api/v1/admin/dashboard/route.ts` (GET stats - admin only)
  - Total users, total orders, total revenue, recent orders

---

## SECTION K: BACKEND HEALTH & UTILITY ENDPOINTS

### K1. Create health endpoint

- [✅] Create `src/app/api/v1/health/route.ts` (GET - returns 200 OK)

### K2. Create seed script

- [✅] Create `prisma/seed.ts` with:
  - Create admin user
  - Create sample categories (Medical, Stationery, etc.)
  - Create sample subjects (Anatomy, etc.)
  - Create sample products
  - Create sample product variants
- [✅] Add seed command to `package.json`

---

## SECTION L: BACKEND - FILE UPLOAD SUPPORT (IMAGES & PDFs)

### L1. Set up file storage infrastructure

- [✅] Install dependencies: `multer` or Next.js built-in file handling, `sharp` for image processing
- [✅] Create `/uploads` directory in project root with subdirectories:
  - `/uploads/images/products/` - for stationery product images
  - `/uploads/pdfs/books/` - for book preview PDFs
- [✅] Add `/uploads` to `.gitignore`
- [✅] Create `src/lib/file_storage.ts` with:
  - `saveFile(file, directory, filename)` - save uploaded file
  - `deleteFile(filepath)` - delete file
  - `validateImage(file)` - validate image type, size (max 5MB)
  - `validatePDF(file)` - validate PDF type, size (max 10MB)
  - `generateFilename(originalName)` - unique filename generator

### L2. Update Prisma schema for file fields

- [✅] Add fields to `Product` model:
  - `imageUrl` (String?) - for stationery products
  - `pdfUrl` (String?) - for book products
  - `fileType` (enum: IMAGE, PDF, NONE) - to distinguish product types
- [✅] Create and run migration: `prisma migrate dev --name add_product_files`
- [✅] Update seed.ts to include sample image/pdf URLs

### L3. Update product repository for file operations

- [✅] Update `product.repo.ts`:
  - Modify `createProduct()` to accept `imageUrl`, `pdfUrl`, `fileType`
  - Modify `updateProduct()` to handle file URL updates
  - Add `deleteProductFiles(productId)` - delete associated files when product deleted

### L4. Create file upload endpoints

- [✅] Create `src/app/api/v1/catalog/products/upload-image/route.ts` (POST - admin only)
  - Accept multipart/form-data with image file
  - Validate image (type, size)
  - Save to `/uploads/images/products/`
  - Return file URL
- [✅] Create `src/app/api/v1/catalog/products/upload-pdf/route.ts` (POST - admin only)
  - Accept multipart/form-data with PDF file
  - Validate PDF (type, size)
  - Save to `/uploads/pdfs/books/`
  - Return file URL
- [✅] Create `src/app/api/v1/catalog/products/[id]/files/route.ts` (DELETE - admin only)
  - Delete product files from filesystem
  - Clear file URLs from database

### L5. Update product endpoints to serve files

- [✅] Update product GET endpoints to include file URLs in response
- [✅] Create `src/app/api/v1/files/images/[...path]/route.ts` (GET - public)
  - Serve images from `/uploads/images/`
  - Add caching headers
- [✅] Create `src/app/api/v1/files/pdfs/[...path]/route.ts` (GET - public)
  - Serve PDFs from `/uploads/pdfs/`
  - Add content-disposition for preview

### L6. Update catalog validators and types

- [✅] Update `catalog.types.ts`:
  - Add `imageUrl`, `pdfUrl`, `fileType` to Product type
  - Add `FileUploadRequest` type
- [✅] Update `catalog.validator.ts`:
  - Add `validateFileUpload(file, fileType)`
  - Add file type validation rules

### L7. Test file upload functionality

- [✅] Test image upload for stationery products
- [✅] Test PDF upload for book products
- [✅] Test file retrieval endpoints
- [✅] Test file deletion on product delete
- [✅] Test file size/type validation
- [✅] Test duplicate filename handling

---

## SECTION M: FLUTTER SHARED PACKAGE ✅ COMPLETED

### M1. Create shared package structure

- [✅] Create `/packages/flutter_shared` folder
- [✅] Initialize Flutter package with `pubspec.yaml`

### M2. Create models

- [✅] Create `lib/models/user.dart` (User model with role)
- [✅] Create `lib/models/category.dart` (Category with parent_id)
- [✅] Create `lib/models/subject.dart` (Subject with parent_subject_id)
- [✅] Create `lib/models/product.dart` (Product model with imageUrl, pdfUrl, fileType)
- [✅] Create `lib/models/product_variant.dart` (ProductVariant model)
- [✅] Create `lib/models/order.dart` (Order model)
- [✅] Create `lib/models/cart_item.dart` (CartItem model)
- [✅] All models with: `toJson()`, `fromJson()`, `copyWith()`, equality operators

### M3. Create API client

- [✅] Create `lib/api/api_client.dart` with:
  - GET/POST/PATCH/DELETE methods
  - Token management from TokenManager
  - Comprehensive error handling (401, 403, 404, 422, 500+)
  - Custom exceptions (UnauthorizedException, ValidationException, etc)
  - Multipart upload support for file uploads
- [✅] Create `lib/api/endpoints.dart` with all API endpoint constants

### M4. Create auth service

- [✅] Create `lib/auth/token_manager.dart` with:
  - Save/load tokens using SharedPreferences
  - Store user ID and role
  - Clear tokens on logout
  - Check login/admin status
- [✅] Create `lib/auth/auth_service.dart` with:
  - `login(email, password)` - returns User
  - `register(name, email, phone, password)` - returns User
  - `logout()` - clears tokens
  - `getCurrentUser()` - fetches from API
  - `refreshToken()` - refresh access token
  - `isLoggedIn()` / `isAdmin()` - status checks

### M5. Create validators

- [✅] Create `lib/utils/validators.dart` with:
  - `validateEmail()` - email format validation
  - `validatePassword()` - min 8 chars, uppercase, number
  - `validatePhone()` - 10-15 digits
  - `validateName()` - min 2 characters
  - `validateQuantity()` - positive integer, max 999
  - `validateImageFile()` - JPEG/PNG/WebP, max 5MB
  - `validatePdfFile()` - PDF format, max 10MB
  - `validateAddress()`, `validateCity()`, `validatePostalCode()`
  - Boolean helpers: `isValidEmail()`, `isStrongPassword()`, `isValidPhone()`

### M6. Create formatters

- [✅] Create `lib/utils/formatters.dart` with:
  - `formatPrice()` - ₹ currency with comma separators
  - `formatDate()` - "15 Jan 2025"
  - `formatDateTime()` - "15 Jan 2025 at 3:45 PM"
  - `formatTime()` - "3:45 PM"
  - `formatRelativeTime()` - "2 days ago", "Just now"
  - `formatPhone()` - "+91 9876 5432 10"
  - `formatFileSize()` - "2.5 MB"
  - `formatOrderStatus()` / `formatPaymentStatus()` - readable status
  - `formatFileType()` - "📷 Image", "📄 PDF"
  - Additional: `truncate()`, `capitalizeWords()`, `formatNumber()`, `formatRating()`, `formatPercentage()`

### M7. Create index & documentation

- [✅] Create `lib/flutter_shared.dart` - exports all public APIs
- [✅] Create `README.md` - complete usage guide for both apps

---

## SECTION N: ADMIN APP - SETUP & CORE

### N1. Initialize Flutter admin app

- [ ] Create `/apps/admin_app` folder
- [ ] Initialize Flutter app with `flutter create`
- [ ] Configure `pubspec.yaml` with dependencies:
  - `provider`, `http`, `intl`, `shared_preferences`, `file_picker`, `image_picker`
  - Add `flutter_shared` as local package dependency

### N2. Create core config

- [ ] Create `lib/core/config/env.dart` (API base URL from env)
- [ ] Create `lib/core/config/constants.dart` (app constants)
- [ ] Create `lib/core/config/api_config.dart` (API configuration)

### N3. Create core theme

- [ ] Create `lib/core/theme/app_theme.dart` (light/dark theme)
- [ ] Create `lib/core/theme/colors.dart` (color palette)
- [ ] Create `lib/core/theme/typography.dart` (text styles)

### N4. Create error handling

- [ ] Create `lib/core/errors/app_exceptions.dart` (custom exceptions)
- [ ] Create `lib/core/errors/error_mapper.dart` (map API errors to UI messages)

### N5. Create extensions & utilities

- [ ] Create `lib/core/utils/extensions.dart` (String, DateTime extensions)
- [ ] Create `lib/core/utils/formatters.dart` (copy from shared)
- [ ] Create `lib/core/utils/validators.dart` (copy from shared)

### N6. Create routing

- [ ] Create `lib/routing/route_names.dart` (all route names)
- [ ] Create `lib/routing/app_router.dart` (GoRouter or Navigator 2.0 setup)
  - Routes: login, dashboard, categories, subjects, products, orders, users, settings

---

## SECTION O: ADMIN APP - AUTH FEATURE

### O1. Create auth feature structure

- [ ] Create `lib/features/auth/` folder with: models/, providers/, screens/, widgets/

### O2. Create admin auth providers

- [ ] Create `lib/features/auth/providers/auth_provider.dart` with:
  - `login(email, password)`
  - `logout()`
  - `currentUser` getter
  - `isAuthenticated` getter
  - `isAdmin` getter - verify role is ADMIN

### O3. Create admin login screen

- [ ] Create `lib/features/auth/screens/login_screen.dart` with:
  - Email & password text fields
  - Login button
  - Admin role verification after login
  - Error display

### O4. Create splash screen

- [ ] Create `lib/features/auth/screens/splash_screen.dart` with:
  - Check if user is logged in and is admin
  - Redirect to dashboard or login

---

## SECTION P: ADMIN APP - DASHBOARD

### P1. Create dashboard feature

- [ ] Create `lib/features/dashboard/` folder with: providers/, screens/, widgets/
- [ ] Create dashboard provider with:
  - `fetchDashboardStats()`
  - Stats: total users, total orders, total revenue, recent orders
- [ ] Create dashboard screen showing key metrics and navigation cards

---

## SECTION Q: ADMIN APP - CATEGORY MANAGEMENT

### Q1. Create category management feature

- [ ] Create `lib/features/category_management/` folder with: models/, providers/, screens/, widgets/

### Q2. Create category provider

- [ ] `fetchCategories()`
- [ ] `createCategory(name, parent_id, metadata)`
- [ ] `updateCategory(id, name, parent_id, metadata)`
- [ ] `deleteCategory(id)`
- [ ] `categories` getter (hierarchical tree view)

### Q3. Create category screens

- [ ] `categories_list_screen.dart` - tree view with CRUD buttons
- [ ] `category_form_screen.dart` - add/edit form
- [ ] `category_detail_screen.dart` - view single category

---

## SECTION R: ADMIN APP - SUBJECT MANAGEMENT

### R1. Create subject management feature

- [ ] Create `lib/features/subject_management/` folder

### R2. Create subject provider & screens

- [ ] Same structure as category management
- [ ] `fetchSubjects()`, `createSubject()`, `updateSubject()`, `deleteSubject()`
- [ ] Tree view display, add/edit forms

---

## SECTION S: ADMIN APP - PRODUCT MANAGEMENT (WITH FILE UPLOADS)

### S1. Create product management feature

- [ ] Create `lib/features/product_management/` folder

### S2. Create product provider

- [ ] `fetchProducts(pagination, filters)`
- [ ] `createProduct(title, description, isbn, base_price, subject_id, fileType)`
- [ ] `updateProduct(id, data)`
- [ ] `deleteProduct(id)`
- [ ] `uploadProductImage(productId, imageFile)` - upload stationery image
- [ ] `uploadProductPDF(productId, pdfFile)` - upload book preview PDF
- [ ] `deleteProductFiles(productId)` - remove files
- [ ] `products` getter with pagination

### S3. Create product variant provider

- [ ] `createVariant(product_id, variant_type, price, stock, sku)`
- [ ] `updateVariant(id, price, stock)`
- [ ] `deleteVariant(id)`

### S4. Create product screens

- [ ] `products_list_screen.dart` - paginated list with CRUD buttons, show file type badges
- [ ] `product_form_screen.dart` - add/edit product with:
  - File type selector (Image for Stationery, PDF for Books, None)
  - Image picker for stationery products
  - PDF picker for book products
  - Image/PDF preview display
  - Upload button with progress indicator
- [ ] `product_detail_screen.dart` - view with variants and file preview
- [ ] `variant_form_screen.dart` - add/edit variant

### S5. Create file upload widgets

- [ ] Create `lib/features/product_management/widgets/image_picker_widget.dart`
  - File picker integration for images
  - Image preview
  - Upload button
- [ ] Create `lib/features/product_management/widgets/pdf_picker_widget.dart`
  - File picker integration for PDFs
  - PDF name display
  - Upload button

---

## SECTION T: ADMIN APP - ORDER MANAGEMENT

### T1. Create order management feature

- [ ] Create `lib/features/order_management/` folder

### T2. Create order provider

- [ ] `fetchAllOrders(pagination, filters)`
- [ ] `fetchOrderDetails(id)`
- [ ] `updateOrderStatus(id, status)`
- [ ] `cancelOrder(id)`

### T3. Create order screens

- [ ] `orders_list_screen.dart` - table/list with filters (status, date)
- [ ] `order_detail_screen.dart` - full order info with status update button

---

## SECTION U: ADMIN APP - USER MANAGEMENT

### U1. Create user management feature

- [ ] Create `lib/features/user_management/` folder

### U2. Create user provider

- [ ] `fetchAllUsers(pagination)`
- [ ] `fetchUserDetails(id)`
- [ ] `updateUser(id, data)`
- [ ] `deleteUser(id)`

### U3. Create user screens

- [ ] `users_list_screen.dart` - paginated user list
- [ ] `user_detail_screen.dart` - view/edit user

---

## SECTION V: ADMIN APP - SETTINGS

### V1. Create settings feature

- [ ] Create `lib/features/settings/` folder

### V2. Create settings provider

- [ ] `fetchSettings()`
- [ ] `updateSetting(key, value)`
- [ ] `settings` getter

### V3. Create settings screen

- [ ] `settings_screen.dart` with:
  - allow_cod toggle
  - max_order_quantity input
  - show_out_of_stock toggle
  - Save button

---

## SECTION W: ADMIN APP - MAIN & ROUTING

### W1. Create main.dart & routing

- [ ] Admin app main.dart with routing
- [ ] Role-based navigation (admin check)
- [ ] Protected routes
- [ ] Bottom navigation or drawer navigation

---

## SECTION X: CUSTOMER APP - SETUP & CORE

### X1. Initialize Flutter customer app

- [ ] Create `/apps/customer_app` folder
- [ ] Initialize Flutter app with `flutter create`
- [ ] Configure `pubspec.yaml` with dependencies:
  - `provider`, `http`, `intl`, `shared_preferences`, `razorpay_flutter`, `cached_network_image`
  - Add `flutter_shared` as local package dependency

### X2. Create core config

- [ ] Create `lib/core/config/env.dart` (API base URL from env)
- [ ] Create `lib/core/config/env.dart` (API base URL from env)
- [ ] Create `lib/core/config/constants.dart` (app constants)
- [ ] Create `lib/core/config/api_config.dart` (API configuration)

### X3. Create core theme

- [ ] Create `lib/core/theme/app_theme.dart` (light/dark theme)
- [ ] Create `lib/core/theme/colors.dart` (color palette)
- [ ] Create `lib/core/theme/typography.dart` (text styles)

### X4. Create error handling

- [ ] Create `lib/core/errors/app_exceptions.dart` (custom exceptions)
- [ ] Create `lib/core/errors/error_mapper.dart` (map API errors to UI messages)

### X5. Create extensions & utilities

- [ ] Create `lib/core/utils/extensions.dart` (String, DateTime extensions)
- [ ] Create `lib/core/utils/formatters.dart` (copy from shared)
- [ ] Create `lib/core/utils/validators.dart` (copy from shared)

### X6. Create routing

- [ ] Create `lib/routing/route_names.dart` (all route names)
- [ ] Create `lib/routing/app_router.dart` (GoRouter or Navigator 2.0 setup)
  - Routes: splash, login, register, catalog, cart, checkout, orders, profile

---

## SECTION Y: CUSTOMER APP - AUTH FEATURE

### Y1. Create auth feature structure

- [ ] Create `lib/features/auth/` folder with: models/, providers/, screens/, widgets/

### Y2. Create auth providers

- [ ] Create `lib/features/auth/providers/auth_provider.dart` with:
  - `login(email, password)`
  - `register(name, email, phone, password)`
  - `logout()`
  - `currentUser` getter
  - `isAuthenticated` getter

### Y3. Create login screen

- [ ] Create `lib/features/auth/screens/login_screen.dart` with:
  - Email & password text fields
  - Login button
  - Register link
  - Error display

### Y4. Create register screen

- [ ] Create `lib/features/auth/screens/register_screen.dart` with:
  - Name, email, phone, password fields
  - Register button
  - Login link
  - Validation feedback

### Y5. Create splash screen

- [ ] Create `lib/features/auth/screens/splash_screen.dart` with:
  - Check if user is logged in
  - Redirect to home or login

---

## SECTION Z: CUSTOMER APP - CATALOG FEATURE (WITH FILE DISPLAY)

### Z1. Create catalog feature structure

- [ ] Create `lib/features/catalog/` folder with: models/, providers/, screens/, widgets/

### Z2. Create catalog providers

- [ ] Create `lib/features/catalog/providers/category_provider.dart` with:
  - `fetchCategories()`
  - `categories` getter (with caching)
  - Error state handling
- [ ] Create `lib/features/catalog/providers/subject_provider.dart` with:
  - `fetchSubjects()`
  - `subjects` getter (hierarchical)
- [ ] Create `lib/features/catalog/providers/product_provider.dart` with:
  - `fetchProducts(categoryId, subjectId, pagination)`
  - `fetchProductDetails(id)`
  - `searchProducts(query)`
  - `products` getter with pagination

### Z3. Create catalog screens

- [ ] Create `lib/features/catalog/screens/catalog_screen.dart` with:
  - Category/Subject filter chips
  - Product grid list with images (for stationery)
  - PDF badge indicator (for books)
  - Pull-to-refresh
- [ ] Create `lib/features/catalog/screens/product_detail_screen.dart` with:
  - Product image display (for stationery) with zoom
  - PDF viewer/download button (for books)
  - Product title, description
  - Variant selector (color/B&W)
  - Price display
  - Stock status
  - Add to cart button

### Z4. Create catalog widgets

- [ ] Create `lib/features/catalog/widgets/product_card.dart` - with image or PDF badge
- [ ] Create `lib/features/catalog/widgets/category_chip.dart`
- [ ] Create `lib/features/catalog/widgets/variant_selector.dart`
- [ ] Create `lib/features/catalog/widgets/pdf_viewer_widget.dart` - for book preview

---

## SECTION AA: CUSTOMER APP - CART FEATURE

### AA1. Create cart feature structure

- [ ] Create `lib/features/cart/` folder with: models/, providers/, screens/, widgets/

### AA2. Create cart provider

- [ ] Create `lib/features/cart/providers/cart_provider.dart` with:
  - `addToCart(productVariantId, quantity)`
  - `removeFromCart(itemId)`
  - `updateQuantity(itemId, quantity)`
  - `clearCart()`
  - `cartItems` getter
  - `cartTotal` getter
  - Sync with backend on auth

### AA3. Create cart screen

- [ ] Create `lib/features/cart/screens/cart_screen.dart` with:
  - List of cart items with quantity controls
  - Product images/PDF badges
  - Remove item button
  - Cart total
  - Checkout button
  - Empty state message

### AA4. Create cart widgets

- [ ] Create `lib/features/cart/widgets/cart_item_card.dart`
- [ ] Create `lib/features/cart/widgets/quantity_selector.dart`

---

## SECTION AB: CUSTOMER APP - CHECKOUT FEATURE

### AB1. Create checkout feature structure

- [ ] Create `lib/features/checkout/` folder with: models/, providers/, screens/, widgets/

### AB2. Create checkout provider

- [ ] Create `lib/features/checkout/providers/checkout_provider.dart` with:
  - `placeOrder(address)`
  - `validateAddress(address)`
  - `getPaymentLink(orderId)`
  - Order creation & payment handling

### AB3. Create address form screen

- [ ] Create `lib/features/checkout/screens/address_screen.dart` with:
  - Address fields (street, city, postal, phone)
  - Validation
  - Continue button

### AB4. Create order confirmation screen

- [ ] Create `lib/features/checkout/screens/confirmation_screen.dart` with:
  - Order ID
  - Items summary
  - Total price
  - Estimated delivery date
  - Continue shopping button

---

## SECTION AC: CUSTOMER APP - ORDERS FEATURE

### AC1. Create orders feature structure

- [ ] Create `lib/features/orders/` folder with: models/, providers/, screens/, widgets/

### AC2. Create orders provider

- [ ] Create `lib/features/orders/providers/orders_provider.dart` with:
  - `fetchUserOrders(pagination)`
  - `fetchOrderDetails(orderId)`
  - `orders` getter
  - `currentOrder` getter

### AC3. Create orders list screen

- [ ] Create `lib/features/orders/screens/orders_list_screen.dart` with:
  - List of user orders with status
  - Tap to view details
  - Filter by status (optional)

### AC4. Create order details screen

- [ ] Create `lib/features/orders/screens/order_detail_screen.dart` with:
  - Order ID, date, status
  - List of items with images/PDF badges
  - Delivery address
  - Total price
  - Cancel button (if status allows)

---

## SECTION AD: CUSTOMER APP - PROFILE FEATURE

### AD1. Create profile feature

- [ ] Create `lib/features/profile/` folder with: screens/, widgets/

### AD2. Create profile screen

- [ ] Create `lib/features/profile/screens/profile_screen.dart` with:
  - Display user info (name, email, phone)
  - Edit profile button (optional for MVP)
  - Orders button
  - Logout button

---

## SECTION AE: CUSTOMER APP - MAIN & ROUTING

### AE1. Create main.dart

- [ ] Set up app initialization
- [ ] Set up Provider for state management
- [ ] Set up routing (GoRouter or Navigator 2.0)
- [ ] Set up theme provider
- [ ] Set up error handling

### AE2. Create app widget

- [ ] Create main MaterialApp/CupertinoApp
- [ ] Configure theme
- [ ] Configure routes
- [ ] Home route

---

## SECTION AF: BACKEND TESTING

### AF1. Create test files

- [ ] Create `tests/unit/` folder
- [ ] Create `tests/integration/` folder
- [ ] Add tests for: auth, catalog, orders, file uploads
- [ ] Test file upload validation
- [ ] Test file retrieval
- [ ] Test file deletion

### AF2. Run tests

- [ ] All tests should pass
- [ ] Update `package.json` test script

---

## SECTION AG: DOCKER & DEPLOYMENT PREP

### AG1. Create Dockerfiles

- [ ] Create `infrastructure/docker/api.Dockerfile` for Next.js API
- [ ] Create `infrastructure/docker/postgres.Dockerfile` for database init
- [ ] Create `infrastructure/docker/nginx.Dockerfile` for reverse proxy (optional for MVP)

### AG2. Configure docker-compose.yml

- [ ] Add PostgreSQL service
- [ ] Add Redis service (optional, can cache later)
- [ ] Add Next.js API service
- [ ] Add Nginx service (optional)
- [ ] Add volumes for persistence (including /uploads)
- [ ] Add environment variables

### AG3. Create scripts

- [ ] `scripts/dev.sh` - starts docker-compose + watches Flutter apps
- [ ] `scripts/deploy.sh` - build & push images (placeholder)
- [ ] `scripts/migrate.sh` - run Prisma migrations in container
- [ ] `scripts/seed.sh` - seed database in container

### AG4. Create database backup script

- [ ] `infrastructure/backup/backup.sh` - daily PostgreSQL dump
- [ ] Test backup restore process

---

## SECTION AH: DOCUMENTATION

### AH1. Create deployment docs

- [ ] Create `docs/deployment.md` with:
  - How to run locally (docker-compose)
  - How to run in production
  - Environment variables
  - Database setup
  - File upload configuration
  - Backup/restore procedures

### AH2. Create API documentation

- [ ] Create `docs/api-spec.md` or use Swagger/OpenAPI (optional for MVP, but recommended)
  - List all endpoints including file upload endpoints
  - Request/response examples
  - Error codes

### AH3. Update root README.md

- [ ] Architecture overview
- [ ] Quick start (docker-compose up)
- [ ] Folder structure explanation
- [ ] File upload guidelines
- [ ] Contributing guidelines

---

## SECTION AI: FINAL TESTING & VALIDATION

### AI1. Manual testing - Auth

- [ ] Register new customer account ✓
- [ ] Login with credentials ✓
- [ ] Logout ✓
- [ ] Admin login ✓
- [ ] Token refresh ✓

### AI2. Manual testing - Catalog (Customer)

- [ ] View all categories ✓
- [ ] Filter products by category ✓
- [ ] Filter products by subject ✓
- [ ] View product details (with image for stationery) ✓
- [ ] View book preview (PDF) ✓
- [ ] View product variants ✓

### AI3. Manual testing - Cart (Customer)

- [ ] Add product to cart ✓
- [ ] Update quantity ✓
- [ ] Remove from cart ✓
- [ ] View cart total ✓
- [ ] Clear cart ✓

### AI4. Manual testing - Checkout (Customer)

- [ ] Enter delivery address ✓
- [ ] Place order ✓
- [ ] Verify order in database ✓
- [ ] View order in customer app ✓

### AI5. Manual testing - Orders (Customer)

- [ ] View user orders list ✓
- [ ] View order details ✓
- [ ] Cancel order (if applicable) ✓

### AI6. Manual testing - Admin

- [ ] Login to admin app ✓
- [ ] View dashboard stats ✓
- [ ] Create category ✓
- [ ] Edit category ✓
- [ ] Delete category ✓
- [ ] Create subject ✓
- [ ] Edit subject ✓
- [ ] Create product (stationery with image) ✓
- [ ] Create product (book with PDF) ✓
- [ ] Upload product image ✓
- [ ] Upload book PDF ✓
- [ ] View uploaded files ✓
- [ ] Edit product ✓
- [ ] Delete product (verify files deleted) ✓
- [ ] Create variant ✓
- [ ] Update variant (price/stock) ✓
- [ ] View all orders ✓
- [ ] Update order status ✓
- [ ] View all users ✓
- [ ] Update store settings ✓

### AI7. API integration testing

- [ ] Test all endpoints with Postman/Insomnia ✓
- [ ] Test file upload endpoints ✓
- [ ] Test file retrieval endpoints ✓
- [ ] Verify error responses ✓
- [ ] Verify auth middleware works ✓
- [ ] Verify admin middleware works ✓
- [ ] Test file size/type validation ✓

### AI8. Performance & edge cases

- [ ] Test with empty categories/products ✓
- [ ] Test with large product lists (pagination) ✓
- [ ] Test out-of-stock handling ✓
- [ ] Test network error handling in apps ✓
- [ ] Test large file uploads ✓
- [ ] Test invalid file types ✓

---

## SECTION AJ: FINAL CHECKLIST - GO LIVE

### AJ1. Security review

- [ ] Change all default passwords ✓
- [ ] Verify env secrets are NOT in git ✓
- [ ] Enable HTTPS in Nginx ✓
- [ ] Rate limiting configured ✓
- [ ] CORS configured for frontend domains ✓
- [ ] File upload security (size limits, type validation) ✓
- [ ] Secure file serving (prevent directory traversal) ✓

### AJ2. Data & backups

- [ ] Database backup script runs ✓
- [ ] File uploads backup configured ✓
- [ ] Restore process tested ✓
- [ ] Backup location is off-machine ✓
- [ ] Data migration plan if needed ✓

### AJ3. Monitoring & logs

- [ ] Container health checks configured ✓
- [ ] Log rotation enabled ✓
- [ ] Uptime monitoring configured ✓
- [ ] Error alerting configured (optional) ✓
- [ ] File storage monitoring (disk space) ✓

### AJ4. Release checklist

- [ ] All tests passing ✓
- [ ] Code reviewed ✓
- [ ] Documentation complete ✓
- [ ] Git tags created for release ✓
- [ ] Changelog updated ✓

### AJ5. Soft launch

- [ ] Deploy to staging ✓
- [ ] Test all critical user flows ✓
- [ ] Test file uploads in staging ✓
- [ ] Verify database integrity ✓
- [ ] Monitor for 24 hours ✓

### AJ6. Production launch

- [ ] Deploy to production ✓
- [ ] Verify all endpoints respond ✓
- [ ] Smoke test critical flows ✓
- [ ] Test file uploads in production ✓
- [ ] Monitor error logs ✓
- [ ] Announce to users ✓

---

## NOTES FOR AGENT

1. **Do NOT skip sections** - follow order exactly
2. **Test after each section** - don't accumulate bugs
3. **Commit regularly** - after each major section (A, B, C, etc.)
4. **Ask for clarification** if requirements are ambiguous
5. **Report blockers immediately** - don't guess
6. **Keep supervisor updated** - status after each section
7. **Use exact naming** - follow Architecture.md & Folder-structure.md
8. **Database migrations** - always create & test migrations
9. **Environment variables** - document all required vars
10. **Error handling** - every API should have proper error responses
11. **File uploads** - validate file types and sizes strictly
12. **File storage** - ensure /uploads directory has proper permissions

---

**PRIORITY ORDER FOR DEVELOPMENT**:

1. ✅ Backend infrastructure (Sections A-K) - COMPLETED
2. 🎯 **NEXT: File upload support (Section L)** - START HERE
3. Flutter shared package (Section M)
4. Admin app (Sections N-W) - Build this BEFORE customer app
5. Customer app (Sections X-AE)
6. Testing, Docker, Documentation, Go-live (Sections AF-AJ)

---
