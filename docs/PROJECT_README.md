# Vijaya Xerox and Stationery - E-Commerce Platform

A comprehensive e-commerce system for a local bookstore and stationery business specializing in academic and medical books.

## 🏗️ Architecture Overview

This is a monorepo containing:

- **Customer App** (Flutter) - Browse, cart, checkout
- **Admin App** (Flutter) - Catalog & order management
- **Backend API** (Next.js) - Business logic & REST APIs
- **Database** (PostgreSQL) - Primary data store
- **Cache** (Redis) - Session storage & caching
- **Payment Gateway** (Razorpay) - Payment processing

## 📁 Project Structure

```
bookstore-system/
├── apps/                    # Applications
│   ├── customer_app/        # Flutter customer app
│   ├── admin_app/           # Flutter admin app
│   └── api/                 # Next.js backend API
├── packages/                # Shared packages
│   └── flutter_shared/      # Shared Flutter code
├── infrastructure/          # DevOps & deployment
│   ├── docker/              # Dockerfiles
│   ├── nginx/               # Reverse proxy config
│   ├── postgres/            # Database init scripts
│   └── backup/              # Backup scripts
├── docs/                    # Documentation
├── scripts/                 # Utility scripts
├── Agent-Context/           # Project context (for AI)
├── .env.example             # Environment template
├── docker-compose.yml       # Docker orchestration
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ (for API)
- **Flutter** 3.16+ (for mobile apps)
- **PostgreSQL** 15+
- **Redis** 7+
- **Docker & Docker Compose** (optional, recommended)

### Setup with Docker (Recommended)

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd Vijaya-Xerox-and-Stationery
   ```

2. **Configure environment**

   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

3. **Start services**

   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**

   ```bash
   cd apps/api
   npm install
   npx prisma migrate deploy
   npx prisma db seed
   ```

5. **Access the application**
   - API: http://localhost:3000
   - Customer App: Build and run from `apps/customer_app`
   - Admin App: Build and run from `apps/admin_app`

### Setup without Docker

#### Backend API

```bash
# Install dependencies
cd apps/api
npm install

# Setup database
cp .env.example .env
# Update DATABASE_URL in .env
npx prisma migrate dev
npx prisma db seed

# Start development server
npm run dev
```

#### Flutter Apps

```bash
# Customer App
cd apps/customer_app
flutter pub get
flutter run

# Admin App
cd apps/admin_app
flutter pub get
flutter run
```

## 🔧 Development

### Running Tests

```bash
# API tests
cd apps/api
npm test

# Flutter tests
cd apps/customer_app
flutter test
```

### Database Migrations

```bash
cd apps/api

# Create a new migration
npx prisma migrate dev --name your_migration_name

# Apply migrations
npx prisma migrate deploy

# Reset database (development only)
npx prisma migrate reset
```

### Code Generation

```bash
# Generate Prisma Client
cd apps/api
npx prisma generate

# Generate Flutter code
cd apps/customer_app
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📚 Key Features

### Customer App

- Browse products by category and subject
- Search functionality
- Shopping cart
- Order placement with Razorpay
- Order history and tracking
- User authentication

### Admin App

- Product management (CRUD)
- Category & subject management
- Order management & fulfillment
- Stock tracking
- User management
- Dashboard & analytics

### Backend API

- RESTful API design
- JWT-based authentication
- Role-based access control (Customer/Admin)
- Rate limiting
- Payment webhook handling
- Comprehensive error handling

## 🗄️ Database Schema

Core entities:

- **Users** - Customer and admin accounts
- **Categories** - Flexible hierarchy for courses, companies, note types
- **Subjects** - Academic subjects (e.g., Anatomy → Upper Limb)
- **Products** - Books and stationery items
- **Product Variants** - Color/B&W versions with stock
- **Orders** - Customer orders with payment tracking
- **Cart Items** - Shopping cart state

## 🔐 Security

- JWT-based authentication
- Bcrypt password hashing
- Role-based access control
- Rate limiting
- Input validation
- SQL injection prevention (Prisma ORM)
- XSS protection

## 📦 Deployment

### Production Deployment

1. **Build Docker images**

   ```bash
   docker-compose -f docker-compose.prod.yml build
   ```

2. **Deploy**

   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Setup SSL with Let's Encrypt**
   ```bash
   ./scripts/setup-ssl.sh
   ```

### Backup & Recovery

```bash
# Backup database
./scripts/backup.sh

# Restore database
./scripts/restore.sh backup-file.sql
```

## 🛠️ Tech Stack

| Component      | Technology           |
| -------------- | -------------------- |
| Frontend       | Flutter (Dart)       |
| Backend        | Next.js (TypeScript) |
| Database       | PostgreSQL 15        |
| ORM            | Prisma               |
| Cache          | Redis                |
| Payments       | Razorpay             |
| Authentication | JWT                  |
| Reverse Proxy  | Nginx                |
| Container      | Docker               |

## 📖 Documentation

Detailed documentation available in the `docs/` directory:

- [Architecture](docs/architecture.md) - System architecture & design decisions
- [API Specification](docs/api-spec.md) - API endpoints documentation
- [Database Schema](docs/database.md) - Database structure & relationships
- [Deployment Guide](docs/deployment.md) - Deployment instructions
- [Backup & Restore](docs/backup-restore.md) - Data backup procedures

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Submit a pull request

## 📝 License

Proprietary - All rights reserved by Vijaya Xerox and Stationery

## 📞 Support

For issues and questions:

- Email: support@vijayaxerox.com
- Phone: +91 98765 43210

## 🎯 Roadmap

- [ ] Phase 1: MVP (Auth, Catalog, Cart, Orders, Admin CRUD)
- [ ] Phase 2: Advanced features (Wishlist, Reviews, Recommendations)
- [ ] Phase 3: Analytics & Reporting
- [ ] Phase 4: Mobile app optimization
- [ ] Phase 5: Multi-location support

---

**Built with ❤️ for Vijaya Xerox and Stationery**
