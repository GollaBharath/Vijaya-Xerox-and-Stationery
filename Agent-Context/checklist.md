# Phase 1 MVP - Development Checklist

**Target**: Production-ready MVP with Auth, Catalog, Cart, Orders, and Admin CRUD.

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

## SECTION L: FLUTTER SHARED PACKAGE

### L1. Create shared package structure

- [ ] Create `/packages/flutter_shared` folder
- [ ] Initialize Flutter package with `pubspec.yaml`

### L2. Create models

- [ ] Create `lib/models/user.dart` (User model with role)
- [ ] Create `lib/models/category.dart` (Category with parent_id)
- [ ] Create `lib/models/subject.dart` (Subject with parent_subject_id)
- [ ] Create `lib/models/product.dart` (Product model)
- [ ] Create `lib/models/product_variant.dart` (ProductVariant model)
- [ ] Create `lib/models/order.dart` (Order model)
- [ ] Create `lib/models/cart_item.dart` (CartItem model)
- [ ] All models should have: `toJson()`, `fromJson()`, `copyWith()`

### L3. Create API client

- [ ] Create `lib/api/api_client.dart` with:
  - `POST/GET/PATCH/DELETE` methods
  - Token management (access token from local storage)
  - Error handling
  - Request/response interceptors
- [ ] Create `lib/api/endpoints.dart` with all API endpoint constants

### L4. Create auth service

- [ ] Create `lib/auth/token_manager.dart` with:
  - Save/load tokens from local storage
  - Clear tokens on logout
- [ ] Create `lib/auth/auth_service.dart` with:
  - `login(email, password)`
  - `register(name, email, phone, password)`
  - `logout()`
  - `getCurrentUser()`
  - `refreshToken()`

### L5. Create validators

- [ ] Create `lib/utils/validators.dart` with:
  - `validateEmail(email)`
  - `validatePassword(password)`
  - `validatePhone(phone)`
  - `validateProductQuantity(qty)`

### L6. Create formatters

- [ ] Create `lib/utils/formatters.dart` with:
  - `formatPrice(price)`
  - `formatDate(date)`
  - `formatPhone(phone)`

---

## SECTION M: CUSTOMER APP - SETUP & CORE

### M1. Initialize Flutter customer app

- [ ] Create `/apps/customer_app` folder
- [ ] Initialize Flutter app with `flutter create`
- [ ] Configure `pubspec.yaml` with dependencies:
  - `provider`, `http`, `intl`, `shared_preferences`, `razorpay_flutter`
  - Add `flutter_shared` as local package dependency

### M2. Create core config

- [ ] Create `lib/core/config/env.dart` (API base URL from env)
- [ ] Create `lib/core/config/constants.dart` (app constants)
- [ ] Create `lib/core/config/api_config.dart` (API configuration)

### M3. Create core theme

- [ ] Create `lib/core/theme/app_theme.dart` (light/dark theme)
- [ ] Create `lib/core/theme/colors.dart` (color palette)
- [ ] Create `lib/core/theme/typography.dart` (text styles)

### M4. Create error handling

- [ ] Create `lib/core/errors/app_exceptions.dart` (custom exceptions)
- [ ] Create `lib/core/errors/error_mapper.dart` (map API errors to UI messages)

### M5. Create extensions & utilities

- [ ] Create `lib/core/utils/extensions.dart` (String, DateTime extensions)
- [ ] Create `lib/core/utils/formatters.dart` (copy from shared)
- [ ] Create `lib/core/utils/validators.dart` (copy from shared)

### M6. Create routing

- [ ] Create `lib/routing/route_names.dart` (all route names)
- [ ] Create `lib/routing/app_router.dart` (GoRouter or Navigator 2.0 setup)
  - Routes: splash, login, register, catalog, cart, checkout, orders, profile

---

## SECTION N: CUSTOMER APP - AUTH FEATURE

### N1. Create auth feature structure

- [ ] Create `lib/features/auth/` folder with: models/, providers/, screens/, widgets/

### N2. Create auth providers

- [ ] Create `lib/features/auth/providers/auth_provider.dart` with:
  - `login(email, password)`
  - `register(name, email, phone, password)`
  - `logout()`
  - `currentUser` getter
  - `isAuthenticated` getter

### N3. Create login screen

- [ ] Create `lib/features/auth/screens/login_screen.dart` with:
  - Email & password text fields
  - Login button
  - Register link
  - Error display

### N4. Create register screen

- [ ] Create `lib/features/auth/screens/register_screen.dart` with:
  - Name, email, phone, password fields
  - Register button
  - Login link
  - Validation feedback

### N5. Create splash screen

- [ ] Create `lib/features/auth/screens/splash_screen.dart` with:
  - Check if user is logged in
  - Redirect to home or login

---

## SECTION O: CUSTOMER APP - CATALOG FEATURE

### O1. Create catalog feature structure

- [ ] Create `lib/features/catalog/` folder with: models/, providers/, screens/, widgets/

### O2. Create catalog providers

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

### O3. Create catalog screens

- [ ] Create `lib/features/catalog/screens/catalog_screen.dart` with:
  - Category/Subject filter chips
  - Product grid list
  - Pull-to-refresh
- [ ] Create `lib/features/catalog/screens/product_detail_screen.dart` with:
  - Product image, title, description
  - Variant selector (color/B&W)
  - Price display
  - Stock status
  - Add to cart button

### O4. Create catalog widgets

- [ ] Create `lib/features/catalog/widgets/product_card.dart`
- [ ] Create `lib/features/catalog/widgets/category_chip.dart`
- [ ] Create `lib/features/catalog/widgets/variant_selector.dart`

---

## SECTION P: CUSTOMER APP - CART FEATURE

### P1. Create cart feature structure

- [ ] Create `lib/features/cart/` folder with: models/, providers/, screens/, widgets/

### P2. Create cart provider

- [ ] Create `lib/features/cart/providers/cart_provider.dart` with:
  - `addToCart(productVariantId, quantity)`
  - `removeFromCart(itemId)`
  - `updateQuantity(itemId, quantity)`
  - `clearCart()`
  - `cartItems` getter
  - `cartTotal` getter
  - Sync with backend on auth

### P3. Create cart screen

- [ ] Create `lib/features/cart/screens/cart_screen.dart` with:
  - List of cart items with quantity controls
  - Remove item button
  - Cart total
  - Checkout button
  - Empty state message

### P4. Create cart widgets

- [ ] Create `lib/features/cart/widgets/cart_item_card.dart`
- [ ] Create `lib/features/cart/widgets/quantity_selector.dart`

---

## SECTION Q: CUSTOMER APP - CHECKOUT FEATURE

### Q1. Create checkout feature structure

- [ ] Create `lib/features/checkout/` folder with: models/, providers/, screens/, widgets/

### Q2. Create checkout provider

- [ ] Create `lib/features/checkout/providers/checkout_provider.dart` with:
  - `placeOrder(address)`
  - `validateAddress(address)`
  - `getPaymentLink(orderId)`
  - Order creation & payment handling

### Q3. Create address form screen

- [ ] Create `lib/features/checkout/screens/address_screen.dart` with:
  - Address fields (street, city, postal, phone)
  - Validation
  - Continue button

### Q4. Create order confirmation screen

- [ ] Create `lib/features/checkout/screens/confirmation_screen.dart` with:
  - Order ID
  - Items summary
  - Total price
  - Estimated delivery date
  - Continue shopping button

---

## SECTION R: CUSTOMER APP - ORDERS FEATURE

### R1. Create orders feature structure

- [ ] Create `lib/features/orders/` folder with: models/, providers/, screens/, widgets/

### R2. Create orders provider

- [ ] Create `lib/features/orders/providers/orders_provider.dart` with:
  - `fetchUserOrders(pagination)`
  - `fetchOrderDetails(orderId)`
  - `orders` getter
  - `currentOrder` getter

### R3. Create orders list screen

- [ ] Create `lib/features/orders/screens/orders_list_screen.dart` with:
  - List of user orders with status
  - Tap to view details
  - Filter by status (optional)

### R4. Create order details screen

- [ ] Create `lib/features/orders/screens/order_detail_screen.dart` with:
  - Order ID, date, status
  - List of items
  - Delivery address
  - Total price
  - Cancel button (if status allows)

---

## SECTION S: CUSTOMER APP - PROFILE FEATURE

### S1. Create profile feature

- [ ] Create `lib/features/profile/` folder with: screens/, widgets/

### S2. Create profile screen

- [ ] Create `lib/features/profile/screens/profile_screen.dart` with:
  - Display user info (name, email, phone)
  - Edit profile button (optional for MVP)
  - Orders button
  - Logout button

---

## SECTION T: CUSTOMER APP - MAIN & ROUTING

### T1. Create main.dart

- [ ] Set up app initialization
- [ ] Set up Provider for state management
- [ ] Set up routing (GoRouter or Navigator 2.0)
- [ ] Set up theme provider
- [ ] Set up error handling

### T2. Create app widget

- [ ] Create main MaterialApp/CupertinoApp
- [ ] Configure theme
- [ ] Configure routes
- [ ] Home route

---

## SECTION U: ADMIN APP - SETUP & CORE

### U1. Initialize Flutter admin app

- [ ] Create `/apps/admin_app` folder
- [ ] Initialize Flutter app
- [ ] Configure `pubspec.yaml` (same core as customer app)
- [ ] Add `flutter_shared` dependency

### U2. Create core structure (same as customer app)

- [ ] Copy core/, routing/, theme from customer app structure

---

## SECTION V: ADMIN APP - AUTH FEATURE

### V1. Create admin auth

- [ ] Create auth feature
- [ ] Create admin login screen (same as customer, but role check)
- [ ] Verify user is admin role before allowing access

---

## SECTION W: ADMIN APP - DASHBOARD

### W1. Create dashboard feature

- [ ] Create `lib/features/dashboard/` folder
- [ ] Create dashboard provider with:
  - `fetchDashboardStats()`
  - Stats: total users, total orders, total revenue, recent orders
- [ ] Create dashboard screen showing key metrics

---

## SECTION X: ADMIN APP - CATEGORY MANAGEMENT

### X1. Create category management feature

- [ ] Create `lib/features/category_management/` folder with: models/, providers/, screens/, widgets/

### X2. Create category provider

- [ ] `fetchCategories()`
- [ ] `createCategory(name, parent_id, metadata)`
- [ ] `updateCategory(id, name, parent_id, metadata)`
- [ ] `deleteCategory(id)`
- [ ] `categories` getter (hierarchical tree view)

### X3. Create category screens

- [ ] `categories_list_screen.dart` - tree view with CRUD buttons
- [ ] `category_form_screen.dart` - add/edit form
- [ ] `category_detail_screen.dart` - view single category

---

## SECTION Y: ADMIN APP - SUBJECT MANAGEMENT

### Y1. Create subject management feature

- [ ] Create `lib/features/subject_management/` folder

### Y2. Create subject provider & screens

- [ ] Same structure as category management
- [ ] `fetchSubjects()`, `createSubject()`, `updateSubject()`, `deleteSubject()`
- [ ] Tree view display, add/edit forms

---

## SECTION Z: ADMIN APP - PRODUCT MANAGEMENT

### Z1. Create product management feature

- [ ] Create `lib/features/product_management/` folder

### Z2. Create product provider

- [ ] `fetchProducts(pagination, filters)`
- [ ] `createProduct(title, description, isbn, base_price, subject_id)`
- [ ] `updateProduct(id, data)`
- [ ] `deleteProduct(id)`
- [ ] `products` getter with pagination

### Z3. Create product variant provider

- [ ] `createVariant(product_id, variant_type, price, stock, sku)`
- [ ] `updateVariant(id, price, stock)`
- [ ] `deleteVariant(id)`

### Z4. Create product screens

- [ ] `products_list_screen.dart` - paginated list with CRUD buttons
- [ ] `product_form_screen.dart` - add/edit product
- [ ] `product_detail_screen.dart` - view with variants
- [ ] `variant_form_screen.dart` - add/edit variant

---

## SECTION AA: ADMIN APP - ORDER MANAGEMENT

### AA1. Create order management feature

- [ ] Create `lib/features/order_management/` folder

### AA2. Create order provider

- [ ] `fetchAllOrders(pagination, filters)`
- [ ] `fetchOrderDetails(id)`
- [ ] `updateOrderStatus(id, status)`
- [ ] `cancelOrder(id)`

### AA3. Create order screens

- [ ] `orders_list_screen.dart` - table/list with filters (status, date)
- [ ] `order_detail_screen.dart` - full order info with status update button

---

## SECTION AB: ADMIN APP - USER MANAGEMENT

### AB1. Create user management feature

- [ ] Create `lib/features/user_management/` folder

### AB2. Create user provider

- [ ] `fetchAllUsers(pagination)`
- [ ] `fetchUserDetails(id)`
- [ ] `updateUser(id, data)`
- [ ] `deleteUser(id)`

### AB3. Create user screens

- [ ] `users_list_screen.dart` - paginated user list
- [ ] `user_detail_screen.dart` - view/edit user

---

## SECTION AC: ADMIN APP - SETTINGS

### AC1. Create settings feature

- [ ] Create `lib/features/settings/` folder

### AC2. Create settings provider

- [ ] `fetchSettings()`
- [ ] `updateSetting(key, value)`
- [ ] `settings` getter

### AC3. Create settings screen

- [ ] `settings_screen.dart` with:
  - allow_cod toggle
  - max_order_quantity input
  - show_out_of_stock toggle
  - Save button

---

## SECTION AD: ADMIN APP - MAIN & ROUTING

### AD1. Create main.dart & routing

- [ ] Admin app main.dart with routing
- [ ] Role-based navigation (admin check)
- [ ] Protected routes

---

## SECTION AE: BACKEND TESTING

### AE1. Create test files

- [ ] Create `tests/unit/` folder
- [ ] Create `tests/integration/` folder
- [ ] Add basic tests for: auth, catalog, orders (at least 1 happy path per module)

### AE2. Run tests

- [ ] All tests should pass
- [ ] Update `package.json` test script

---

## SECTION AF: DOCKER & DEPLOYMENT PREP

### AF1. Create Dockerfiles

- [ ] Create `infrastructure/docker/api.Dockerfile` for Next.js API
- [ ] Create `infrastructure/docker/postgres.Dockerfile` for database init
- [ ] Create `infrastructure/docker/nginx.Dockerfile` for reverse proxy (optional for MVP)

### AF2. Configure docker-compose.yml

- [ ] Add PostgreSQL service
- [ ] Add Redis service (optional, can cache later)
- [ ] Add Next.js API service
- [ ] Add Nginx service (optional)
- [ ] Add volumes for persistence
- [ ] Add environment variables

### AF3. Create scripts

- [ ] `scripts/dev.sh` - starts docker-compose + watches Flutter apps
- [ ] `scripts/deploy.sh` - build & push images (placeholder)
- [ ] `scripts/migrate.sh` - run Prisma migrations in container
- [ ] `scripts/seed.sh` - seed database in container

### AF4. Create database backup script

- [ ] `infrastructure/backup/backup.sh` - daily PostgreSQL dump
- [ ] Test backup restore process

---

## SECTION AG: DOCUMENTATION

### AG1. Create deployment docs

- [ ] Create `docs/deployment.md` with:
  - How to run locally (docker-compose)
  - How to run in production
  - Environment variables
  - Database setup
  - Backup/restore procedures

### AG2. Create API documentation

- [ ] Create `docs/api-spec.md` or use Swagger/OpenAPI (optional for MVP, but recommended)
  - List all endpoints
  - Request/response examples
  - Error codes

### AG3. Update root README.md

- [ ] Architecture overview
- [ ] Quick start (docker-compose up)
- [ ] Folder structure explanation
- [ ] Contributing guidelines

---

## SECTION AH: FINAL TESTING & VALIDATION

### AH1. Manual testing - Auth

- [ ] Register new customer account ✓
- [ ] Login with credentials ✓
- [ ] Logout ✓
- [ ] Admin login ✓
- [ ] Token refresh ✓

### AH2. Manual testing - Catalog (Customer)

- [ ] View all categories ✓
- [ ] Filter products by category ✓
- [ ] Filter products by subject ✓
- [ ] View product details ✓
- [ ] View product variants ✓

### AH3. Manual testing - Cart (Customer)

- [ ] Add product to cart ✓
- [ ] Update quantity ✓
- [ ] Remove from cart ✓
- [ ] View cart total ✓
- [ ] Clear cart ✓

### AH4. Manual testing - Checkout (Customer)

- [ ] Enter delivery address ✓
- [ ] Place order ✓
- [ ] Verify order in database ✓
- [ ] View order in customer app ✓

### AH5. Manual testing - Orders (Customer)

- [ ] View user orders list ✓
- [ ] View order details ✓
- [ ] Cancel order (if applicable) ✓

### AH6. Manual testing - Admin

- [ ] Login to admin app ✓
- [ ] View dashboard stats ✓
- [ ] Create category ✓
- [ ] Edit category ✓
- [ ] Delete category ✓
- [ ] Create subject ✓
- [ ] Edit subject ✓
- [ ] Create product ✓
- [ ] Edit product ✓
- [ ] Create variant ✓
- [ ] Update variant (price/stock) ✓
- [ ] View all orders ✓
- [ ] Update order status ✓
- [ ] View all users ✓
- [ ] Update store settings ✓

### AH7. API integration testing

- [ ] Test all endpoints with Postman/Insomnia ✓
- [ ] Verify error responses ✓
- [ ] Verify auth middleware works ✓
- [ ] Verify admin middleware works ✓

### AH8. Performance & edge cases

- [ ] Test with empty categories/products ✓
- [ ] Test with large product lists (pagination) ✓
- [ ] Test out-of-stock handling ✓
- [ ] Test network error handling in apps ✓

---

## SECTION AI: FINAL CHECKLIST - GO LIVE

### AI1. Security review

- [ ] Change all default passwords ✓
- [ ] Verify env secrets are NOT in git ✓
- [ ] Enable HTTPS in Nginx ✓
- [ ] Rate limiting configured ✓
- [ ] CORS configured for frontend domains ✓

### AI2. Data & backups

- [ ] Database backup script runs ✓
- [ ] Restore process tested ✓
- [ ] Backup location is off-machine ✓
- [ ] Data migration plan if needed ✓

### AI3. Monitoring & logs

- [ ] Container health checks configured ✓
- [ ] Log rotation enabled ✓
- [ ] Uptime monitoring configured ✓
- [ ] Error alerting configured (optional) ✓

### AI4. Release checklist

- [ ] All tests passing ✓
- [ ] Code reviewed ✓
- [ ] Documentation complete ✓
- [ ] Git tags created for release ✓
- [ ] Changelog updated ✓

### AI5. Soft launch

- [ ] Deploy to staging ✓
- [ ] Test all critical user flows ✓
- [ ] Verify database integrity ✓
- [ ] Monitor for 24 hours ✓

### AI6. Production launch

- [ ] Deploy to production ✓
- [ ] Verify all endpoints respond ✓
- [ ] Smoke test critical flows ✓
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

---
