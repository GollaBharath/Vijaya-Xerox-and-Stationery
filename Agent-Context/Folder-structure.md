# 0) Monorepo Root Structure

```
ecommerce-system/
│
├── apps/
├── packages/
├── infrastructure/
├── docs/                # ALL documentation goes here
├── scripts/
├── .env.example
├── docker-compose.yml
├── README.md            # Optional: GitHub landing page only
```

**IMPORTANT**: All `.md` documentation files MUST be placed in `/docs` directory. No scattered documentation in root or other folders.

**Agent-Context Files** (for AI agents only):

- Architecture.md
- checklist.md
- Folder-structure.md
- Backend-Endpoints.md

---

# 1) Apps Folder

```
/apps
  /customer_app
  /admin_app
  /api
```

---

# 2) Flutter Apps Structure

Both apps should share the same internal structure.

---

## 2.1 Customer App

```
/apps/customer_app
│
├── android/
├── ios/
├── web/                # optional
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── env.dart
│   │   │   ├── api_config.dart
│   │   │   └── constants.dart
│   │   │
│   │   ├── networking/
│   │   │   ├── api_client.dart
│   │   │   ├── interceptors.dart
│   │   │   └── api_response.dart
│   │   │
│   │   ├── errors/
│   │   │   ├── app_exceptions.dart
│   │   │   └── error_mapper.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── extensions.dart
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── catalog/
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── orders/
│   │   ├── profile/
│   │   └── search/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── providers/
│   │
│   └── routing/
│       ├── app_router.dart
│       └── route_names.dart
│
├── assets/
│   ├── images/
│   └── icons/
│
└── pubspec.yaml
```

---

## 2.2 Admin App

Same structure, but features differ:

```
features/
  ├── dashboard/
  ├── product_management/
  ├── category_management/
  ├── subject_management/
  ├── order_management/
  ├── user_management/
  └── settings/
```

---

# 3) Shared Flutter Package

Avoid duplicating logic.

```
/packages/flutter_shared
│
├── lib/
│   ├── models/
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── subject.dart
│   │   ├── order.dart
│   │   └── user.dart
│   │
│   ├── api/
│   │   ├── api_client.dart
│   │   └── endpoints.dart
│   │
│   ├── auth/
│   │   ├── token_manager.dart
│   │   └── auth_service.dart
│   │
│   └── utils/
│       ├── validators.dart
│       └── formatters.dart
│
└── pubspec.yaml
```

Both apps depend on this.

---

# 4) Next.js API Structure

```
/apps/api
│
├── src/
│   │
│   ├── app/
│   │   └── api/
│   │       └── v1/
│   │           ├── auth/
│   │           ├── catalog/
│   │           ├── subjects/
│   │           ├── orders/
│   │           ├── payments/
│   │           ├── admin/
│   │           └── health/
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.repo.ts
│   │   │   ├── auth.validator.ts
│   │   │   └── auth.types.ts
│   │   │
│   │   ├── catalog/
│   │   ├── subjects/
│   │   ├── orders/
│   │   ├── payments/
│   │   └── users/
│   │
│   ├── lib/
│   │   ├── prisma.ts
│   │   ├── redis.ts
│   │   ├── logger.ts
│   │   ├── env.ts
│   │   └── rate_limiter.ts
│   │
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── admin.middleware.ts
│   │   └── error.middleware.ts
│   │
│   ├── utils/
│   │   ├── validators.ts
│   │   ├── pagination.ts
│   │   └── helpers.ts
│   │
│   └── types/
│       └── global.d.ts
│
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
│
├── tests/
│   ├── integration/
│   └── unit/
│
├── package.json
└── tsconfig.json
```

---

# 5) Infrastructure Folder

```
/infrastructure
│
├── nginx/
│   ├── nginx.conf
│   └── sites/
│
├── docker/
│   ├── api.Dockerfile
│   ├── flutter.Dockerfile
│   └── nginx.Dockerfile
│
├── postgres/
│   └── init.sql
│
├── backup/
│   ├── backup.sh
│   └── restore.sh
│
└── monitoring/
    ├── uptime-kuma/
    └── prometheus/  # optional
```

---

# 6) Docs Folder

```
/docs
  ├── architecture.md
  ├── api-spec.md
  ├── database.md
  ├── deployment.md
  └── backup-restore.md
```

---

# 7) Scripts Folder

```
/scripts
  ├── dev.sh
  ├── deploy.sh
  ├── migrate.sh
  ├── seed.sh
  └── backup.sh
```

---

# 8) Environment Strategy

```
.env.dev
.env.staging
.env.prod
```

Never commit real secrets.

---

# 9) Why This Structure Works

✔ Clear domain separation
✔ Easy to scale features
✔ Easy onboarding
✔ Clean DevOps story
✔ Supports volatile requirements
✔ Shared code reduces bugs
✔ Testable modules
✔ Docker-friendly

---

# 10) Pro Tip (Important)

If solo/small team:

Start simple:

- Don’t over-modularize on day 1
- Add complexity only when needed
- Keep modules but avoid deep nesting

---
