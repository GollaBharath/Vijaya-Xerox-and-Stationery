# Rebranding Tracker

This document tracks all places where the old brand name "Vijaya Xerox and Stationery" (and variants) appeared and were replaced with generic "Company Name" placeholders. Use this to implement a dynamic company name setting in the admin panel.

## Replacement Summary

| Old Value                           | New Value           |
| ----------------------------------- | ------------------- |
| Vijaya Xerox and Stationery         | Company Name        |
| Vijaya Xerox & Stationery           | Company Name        |
| Vijaya Store                        | Company Name        |
| Vijaya Bookstore                    | Company Name        |
| Vijaya Admin                        | Admin Panel         |
| Vijaya API                          | E-Commerce API      |
| vijaya-api                          | ecommerce-api       |
| vijaya_api                          | ecommerce_api       |
| vijaya_network                      | ecommerce_network   |
| vijaya_postgres                     | ecommerce_postgres  |
| vijaya_user                         | app_user            |
| vijaya_password                     | app_password        |
| vijaya_bookstore                    | ecommerce_db        |
| @vijaya/api                         | @company/api        |
| admin@vijaya.local                  | admin@company.local |
| vijaya@admin.com                    | admin@company.local |
| vijayaxerox@example.com             | contact@company.com |
| vijayaxerox.com                     | company.com         |
| noreply@vijayaxerox.com             | noreply@company.com |
| admin@vijayaxerox.com               | admin@company.com   |
| support@vijayaxerox.com             | support@company.com |
| vijaya-redis                        | ecommerce-redis     |
| Vijaya-Xerox-and-Stationery (paths) | EcommerceMobileApp  |
| bookstore-system                    | ecommerce-system    |
| Books & Stationery (tagline)        | Your One-Stop Shop  |

---

## Files Changed — Grouped by Category

### Flutter Source Code (Customer App)

| File                                                                      | What Changed                                         |
| ------------------------------------------------------------------------- | ---------------------------------------------------- |
| `apps/customer_app/lib/core/config/constants.dart`                        | `appName`: "Vijaya Store" → "Company Name"           |
| `apps/customer_app/lib/features/profile/screens/profile_screen.dart`      | About dialog: app name & copyright                   |
| `apps/customer_app/lib/features/profile/screens/help_support_screen.dart` | Bug report email/WhatsApp subject lines              |
| `apps/customer_app/lib/features/auth/screens/splash_screen.dart`          | Tagline: "Books & Stationery" → "Your One-Stop Shop" |
| `apps/customer_app/pubspec.yaml`                                          | description field                                    |
| `apps/customer_app/ios/Flutter/flutter_export_environment.sh`             | FLUTTER_APPLICATION_PATH                             |
| `apps/customer_app/macos/Flutter/ephemeral/flutter_export_environment.sh` | FLUTTER_APPLICATION_PATH                             |

### Flutter Source Code (Admin App)

| File                                                                   | What Changed                                             |
| ---------------------------------------------------------------------- | -------------------------------------------------------- |
| `apps/admin_app/lib/core/config/constants.dart`                        | `appName`: "Vijaya Admin" → "Admin Panel"                |
| `apps/admin_app/lib/core/config/env.dart`                              | `appName`: "Vijaya Admin" → "Admin Panel"                |
| `apps/admin_app/lib/features/auth/screens/login_screen.dart`           | Email hint: "admin@vijaya.local" → "admin@company.local" |
| `apps/admin_app/pubspec.yaml`                                          | description field                                        |
| `apps/admin_app/ios/Flutter/flutter_export_environment.sh`             | FLUTTER_APPLICATION_PATH                                 |
| `apps/admin_app/macos/Flutter/ephemeral/flutter_export_environment.sh` | FLUTTER_APPLICATION_PATH                                 |

### Shared Flutter Package

| File                                               | What Changed        |
| -------------------------------------------------- | ------------------- |
| `packages/flutter_shared/lib/api/endpoints.dart`   | Doc comment         |
| `packages/flutter_shared/lib/api/api_client.dart`  | Doc comment         |
| `packages/flutter_shared/lib/models/user.dart`     | Doc comment         |
| `packages/flutter_shared/lib/models/category.dart` | Doc comment         |
| `packages/flutter_shared/lib/models/product.dart`  | Doc comment         |
| `packages/flutter_shared/pubspec.yaml`             | description field   |
| `packages/flutter_shared/README.md`                | Package description |

### API / Backend

| File                                              | What Changed                                                   |
| ------------------------------------------------- | -------------------------------------------------------------- |
| `apps/api/package.json`                           | name: "@vijaya/api" → "@company/api", description              |
| `apps/api/package-lock.json`                      | name field (2 occurrences)                                     |
| `apps/api/src/app/page.tsx`                       | Page title: "Vijaya Bookstore API" → "E-Commerce API"          |
| `apps/api/src/modules/support/support.repo.ts`    | Default shopName: "Vijaya Xerox & Stationery" → "Company Name" |
| `apps/api/prisma/seed.ts`                         | Admin email: "vijaya@admin.com" → "admin@company.local"        |
| `apps/api/prisma/migrations/.../seed_support.sql` | shopName, shopEmail, websiteUrl                                |
| `apps/api/scripts/seed-support.js`                | shopName, shopEmail, websiteUrl                                |
| `apps/api/scripts/verify-preview.ts`              | ADMIN_EMAIL                                                    |
| `apps/api/fly.toml`                               | app name: "vijaya-api" → "ecommerce-api"                       |

### Environment / Config Files

| File                 | What Changed                                                         |
| -------------------- | -------------------------------------------------------------------- |
| `.env`               | COMPOSE_PROJECT_NAME, DB comment, EMAIL_FROM, ADMIN_EMAIL, APP_NAMEs |
| `apps/api/.env`      | DB comments, ADMIN_EMAIL                                             |
| `docker-compose.yml` | Container names, network name                                        |
| `deploy-fly.sh`      | Script header, APP_NAME, header text                                 |

### Scripts

| File                           | What Changed                         |
| ------------------------------ | ------------------------------------ |
| `scripts/test-api.sh`          | Header, test suite name, admin email |
| `scripts/quick-test.sh`        | Header, admin email                  |
| `scripts/quick-api-test.sh`    | Admin email                          |
| `scripts/test-likes-phase1.sh` | Customer email                       |

### Root Files

| File                  | What Changed                |
| --------------------- | --------------------------- |
| `README.md`           | Title, description, license |
| `package-lock.json`   | Project name                |
| `SEEDING_REPORT.md`   | Admin email                 |
| `DEPLOYMENT_GUIDE.md` | API URLs (4 occurrences)    |

### Documentation (docs/)

| File                              | What Changed                                           |
| --------------------------------- | ------------------------------------------------------ |
| `docs/PROJECT_README.md`          | Title, description, folder ref, license, email, footer |
| `docs/QUICKSTART.md`              | DB URLs, container names, network name                 |
| `docs/ENVIRONMENT.md`             | Folder path, DB URLs, compose name, docker host        |
| `docs/API_QUICK_REFERENCE.md`     | Admin email (2 occurrences)                            |
| `docs/BACKEND_REVIEW_REPORT.md`   | Project name (2 occurrences)                           |
| `docs/BACKEND_TESTING_SUMMARY.md` | Brand name, test header                                |
| `docs/VERIFICATION_REPORT.md`     | Network, container, DB names, folder path              |
| `docs/SECTION_L_COMPLETION.md`    | File paths (6 occurrences)                             |
| `docs/SECTION_Y_COMPLETION.md`    | App name, tagline                                      |
| `docs/UPSTASH_REDIS_SETUP.md`     | Redis name                                             |

### Agent Context

| File                                 | What Changed                |
| ------------------------------------ | --------------------------- |
| `Agent-Context/Architecture.md`      | Title, overview description |
| `Agent-Context/Backend-Endpoints.md` | Admin email (2 occurrences) |
| `Agent-Context/Folder-structure.md`  | Root folder name            |

---

## NOT Changed (Firebase — Requires New Project)

These files contain the Firebase project ID `vijaya-xerox-stationery` which is tied to the actual Firebase project. To change these, you must create a new Firebase project and download new credentials.

| File                                                                    | Reason                               |
| ----------------------------------------------------------------------- | ------------------------------------ |
| `.env` → `GOOGLE_APPLICATION_CREDENTIALS`, `FIREBASE_PROJECT_ID`        | Firebase project config              |
| `apps/api/.env` → `FIREBASE_PROJECT_ID`                                 | Firebase project config              |
| `apps/api/src/lib/firebase-admin.ts`                                    | Fallback Firebase project ID         |
| `apps/api/firebase-service-account.json`                                | Firebase service account credentials |
| `apps/api/credentials/vijaya-xerox-stationery-firebase-adminsdk-*.json` | Firebase service account file        |
| `apps/customer_app/android/app/google-services.json`                    | Firebase Android config              |
| `apps/admin_app/android/app/google-services.json`                       | Firebase Android config              |
| `FIREBASE_MIGRATION_SUMMARY.md`                                         | Reference to Firebase project name   |
| `FIREBASE_SETUP.md`                                                     | Firebase project setup instructions  |

---

## Recommended: Admin Company Name Setting

To make the company name fully configurable from the admin panel, implement these changes:

### 1. Backend — Add to SupportInfo model

The `support_info` table already has a `shop_name` field. This is currently seeded with "Company Name" and can be updated via:

- `PUT /api/v1/admin/support` (already exists)

### 2. Customer App — Dynamic Loading

Replace hardcoded `AppConstants.appName` with values fetched from the support info API:

- **Splash screen** → Fetch `shopName` from `/api/v1/support`
- **Profile > About** → Use `shopName` from support info
- **Help & Support** → Already dynamic (uses `_supportInfo.shopName`)

### 3. Admin App — Settings Screen

- Add a "Store Settings" section in admin app
- Allow editing `shopName`, tagline, contact info via the existing support API

### Key Files to Modify for Dynamic Company Name:

1. `apps/customer_app/lib/core/config/constants.dart` — Make `appName` configurable
2. `apps/customer_app/lib/features/profile/screens/profile_screen.dart` — Read from API
3. `apps/customer_app/lib/features/auth/screens/splash_screen.dart` — Read from API
4. `apps/admin_app/lib/core/config/constants.dart` — Make `appName` configurable
5. `apps/api/src/modules/support/support.repo.ts` — Default shop name source
