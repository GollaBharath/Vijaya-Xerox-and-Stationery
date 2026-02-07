# Architecture.md

## Local Bookstore & Stationery E-Commerce System - for Vijaya Xerox and Stationery

---

# 1. Overview

This system is a domain-specific e-commerce platform for a local bookstore and stationery business focused on academic and medical books. It consists of:

- **Customer App (Flutter)** – browsing, cart, checkout
- **Admin App (Flutter)** – catalog & order management
- **Backend (Next.js API)** – business logic & APIs
- **Database (PostgreSQL)** – primary data store
- **Redis** – caching & session storage
- **Razorpay** – payments
- **Self-hosted infrastructure** – all services run locally on owned servers

Design goals:

- Flexible schema for volatile requirements
- Minimal rewrites when hierarchy changes
- Operational simplicity
- Data safety & recoverability
- Small-scale optimization (~10k lifetime users)

---

# 2. High-Level Architecture

```
Flutter Apps (Customer/Admin)
        |
        v
    Next.js API
        |
---------------------
|           |       |
Postgres Redis Razorpay
```

Reverse proxy (Nginx/Caddy) sits in front of the API for TLS and routing.

---

# 3. Technology Stack

## Frontend (Apps)

**Flutter**

- Two apps: Customer & Admin
- Shared core package:
  - API client
  - DTO/models
  - Auth handling
  - Validators

---

## Backend

**Next.js (API-only focus)**

- Route Handlers as REST API
- Modular architecture
- JWT-based auth
- Role-based access (admin/customer)

---

## Database

**PostgreSQL**

- Primary source of truth
- Strong consistency
- Prisma ORM for type-safe queries and migrations

---

## Caching & Sessions

**Redis**

- Session storage
- Short-term caching:
  - Category tree
  - Product lists

Avoid over-caching.

---

## Payments

**Razorpay**

- Orders created server-side
- Webhook verification required
- Payment status stored in DB

---

# 4. Code Structure & Documentation

## ⚠️ CRITICAL: FOLDER STRUCTURE MUST BE FOLLOWED EXACTLY

**All code MUST follow the structure defined in Folder-structure.md**

This is not a suggestion - it is a strict requirement. The folder structure is designed for:

- Maintainability and scalability
- Clear separation of concerns
- Type safety and predictable imports
- Easy navigation and onboarding

## ⚠️ CRITICAL: DOCUMENTATION STRUCTURE

**All documentation MUST be placed in the `/docs` directory**

This is mandatory for project organization:

- NO scattered `.md` files in the root directory
- ALL project documentation goes in `/docs`
- Only exception: Root `README.md` (if needed for GitHub)
- Agent-Context files are for AI agents only (Architecture.md, checklist.md, Folder-structure.md, Backend-Endpoints.md)

**Before creating ANY new file or folder:**

1. Check Folder-structure.md for the correct location
2. Verify the path matches the documented structure
3. Do not create parallel or alternative structures

**Key principles:**

- All Next.js app code goes in `src/app/`
- Business logic goes in `src/modules/`
- Shared utilities go in `src/lib/`
- Types go in `src/types/`
- Middleware goes in `src/middleware/`

### Full Structure Reference

See [Folder-structure.md](./Folder-structure.md) for complete folder hierarchy.

See [Backend-Endpoints.md](./Backend-Endpoints.md) for complete API endpoint documentation.

**Summary for Next.js API:**

```
/apps/api/src/
├── app/api/v1/          # Route handlers (REST endpoints)
├── modules/             # Business logic (services, repos, validators)
├── lib/                 # Core utilities (prisma, redis, logger)
├── middleware/          # Request interceptors
├── utils/               # Helper functions
└── types/               # TypeScript definitions
```

---

# 5. Domain Modeling

## 5.1 Core Principles

- No hardcoded academic logic
- Hierarchies stored as data
- Generic and extensible models
- Subjects treated as domain entities

---

# 6. Catalog Design

## 6.1 Category Tree (Generic)

Represents:

- Course
- Company
- Notes Type
- Stationery categories
- Any future hierarchy

### categories

```

id
name
parent_id (nullable)
metadata (jsonb)
is_active
created_at

```

Example hierarchy:

```

Medical
→ NEET PG
→ Marrow
→ Main Notes
Stationery
→ Notebooks
→ Pens

```

---

## 6.2 Subjects (First-Class Entity)

Subjects are academically important and must be structured.

### subjects

```

id
name
parent_subject_id (nullable)

```

Example:

```

Anatomy
→ Upper Limb
→ Thorax

```

---

## 6.3 Products

### products

```

id
title
description
isbn
base_price
is_active
created_at

```

---

## 6.4 Product Variants

Handles color/B&W.

### product_variants

```

id
product_id
variant_type (color | bw)
price
stock
sku

```

---

## 6.5 Relationships

### product_categories

```

product_id
category_id

```

### Product → Subject

```

products.subject_id

```

Each product belongs to one subject node.

---

# 7. Orders System

### orders

```

id
user_id
status (pending/paid/shipped/delivered/cancelled)
total_price
payment_status
address_snapshot
created_at

```

### order_items

```

id
order_id
product_variant_id
quantity
price_snapshot

```

Snapshots prevent future price edits affecting past orders.

---

# 8. Users & Auth

### users

```

id
name
phone/email
password_hash
role (customer/admin)
created_at

```

Auth:

- JWT tokens
- Short expiry + refresh tokens

---

# 9. Config-Driven Behavior

### store_settings

```

key
value_json

```

Examples:

- allow_cod
- max_order_quantity
- show_out_of_stock

Prevents code changes for policy tweaks.

---

# 10. API Versioning

Always prefix:

```

/api/v1/...

```

Protects future compatibility.

**For complete endpoint documentation, see [Backend-Endpoints.md](./Backend-Endpoints.md)**

---

# 11. Self-Hosted Infrastructure

## 11.1 Dockerized Services

- nextjs-api
- postgres
- redis
- nginx/caddy
- backup service

No bare-metal processes.

---

## 11.2 Reverse Proxy

Handles:

- TLS termination
- Routing
- Rate limiting

---

## 11.3 Backups (Critical)

Daily:

- Postgres dumps
- Off-machine storage
- 7–14 day retention

---

## 11.4 Security

- Firewall: expose only 80/443
- Never expose DB/Redis
- Strong admin passwords
- Rate limiting
- Secure env secrets

---

## 11.5 Reliability

- UPS/power backup
- Disk monitoring
- Log rotation

---

# 12. Monitoring

Minimum:

- Uptime monitoring
- CPU/disk alerts
- Container health checks

Optional:

- Error tracking (Sentry)

---

# 13. Development Roadmap

## Phase 1 (MVP)

- Auth
- Categories
- Subjects
- Products & variants
- Cart
- Orders
- Admin CRUD

## Phase 2

- Payments
- Basic caching
- Stability improvements

## Phase 3

- Optional enhancements
- Offers/coupons
- Advanced search

---

# 14. Non-Goals (For Now)

- Recommendations
- Analytics
- Notifications
- Complex ML features

---

# 15. Key Risks

1. Data loss
2. Payment verification bugs
3. Admin data-entry mistakes

Mitigations:

- Backups
- Strict validation
- Audit logs (optional future)

---

# 16. Guiding Philosophy

Optimize for:

- Simplicity
- Flexibility
- Recoverability
- Correctness

Not scale.

---
