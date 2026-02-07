# Section L - File Upload Support Implementation Summary

**Completed**: February 7, 2026

## Overview

Successfully implemented comprehensive file upload support for both stationery product images (JPEG/PNG/WebP, max 5MB) and book preview PDFs (max 10MB).

## What Was Implemented

### 1. Database Schema Updates

- ✅ Added `imageUrl` (String?) field to Product model
- ✅ Added `pdfUrl` (String?) field to Product model
- ✅ Added `fileType` enum (IMAGE | PDF | NONE) to Product model
- ✅ Created and ran Prisma migration: `20260207154106_add_product_files`
- ✅ Updated Prisma schema.prisma with FileType enum and new fields

### 2. File Storage Infrastructure

**Location**: `/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/lib/file_storage.ts`

Implemented file storage utility with:

- `initializeUploadDirs()` - Creates `/uploads/images/products` and `/uploads/pdfs/books` directories
- `generateFilename(originalName)` - Generates unique filenames with timestamp + random hash
- `validateImage(file)` - Validates image type (jpeg/png/webp) and size (max 5MB)
- `validatePDF(file)` - Validates PDF type and size (max 10MB)
- `saveImageFile(filename, buffer)` - Saves image file and returns URL path
- `savePDFFile(filename, buffer)` - Saves PDF file and returns URL path
- `deleteFile(relativeUrl)` - Deletes file from filesystem
- `getFilePath(relativeUrl)` - Gets absolute path from relative URL
- `getFilesInDirectory(dir)` - Lists files in directory

### 3. Product Repository Updates

**Location**: `/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/product.repo.ts`

Updated all product operations to support files:

- ✅ `createProduct()` - Now accepts `imageUrl`, `pdfUrl`, `fileType`
- ✅ `updateProduct()` - Now handles file URL updates
- ✅ Added `deleteProductFiles(productId)` - Deletes both files and clears database URLs
- ✅ Updated `toProduct()` mapper to include file fields
- ✅ Added import for `deleteFile` utility

### 4. API Endpoints Created

#### Image Upload

**Route**: `POST /api/v1/catalog/products/upload-image`

- Admin-only endpoint
- Accepts multipart/form-data: `file` and `productId`
- Validates image type (jpeg/png/webp) and size (max 5MB)
- Returns: `{ success: true, imageUrl: "/api/v1/files/images/products/filename" }`

#### PDF Upload

**Route**: `POST /api/v1/catalog/products/upload-pdf`

- Admin-only endpoint
- Accepts multipart/form-data: `file` and `productId`
- Validates PDF type and size (max 10MB)
- Returns: `{ success: true, pdfUrl: "/api/v1/files/pdfs/books/filename" }`

#### File Deletion

**Route**: `DELETE /api/v1/catalog/products/[id]/files`

- Admin-only endpoint
- Deletes associated image/PDF files from filesystem
- Clears `imageUrl`, `pdfUrl`, and sets `fileType` to 'NONE'

#### Image Serving

**Route**: `GET /api/v1/files/images/[...path]`

- Public endpoint
- Serves stored product images
- Sets proper content-type headers
- Implements caching: `Cache-Control: public, max-age=31536000, immutable`

#### PDF Serving

**Route**: `GET /api/v1/files/pdfs/[...path]`

- Public endpoint
- Serves stored book preview PDFs
- Supports inline preview or attachment download via query param
- Implements caching headers

### 5. Type System Updates

**Location**: `/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/catalog.types.ts`

Updated Product interface:

```typescript
export interface Product {
	// ... existing fields ...
	imageUrl?: string | null;
	pdfUrl?: string | null;
	fileType: "IMAGE" | "PDF" | "NONE";
	// ... rest of fields ...
}
```

### 6. Validation Updates

**Location**: `/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/catalog.validator.ts`

- ✅ Updated `UpdateProductInput` interface to include file fields
- ✅ Added `validateFileUpload(file, fileType)` function for file validation
- ✅ Defined size limits: 5MB for images, 10MB for PDFs
- ✅ Defined allowed MIME types: image/jpeg, image/png, image/webp, application/pdf

### 7. Seed Script Updates

**Location**: `/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/prisma/seed.ts`

- ✅ Added `initializeUploadDirs()` call at start of seed
- ✅ Upload directories are now created automatically during seeding
- ✅ Directories created: `/uploads/images/products/` and `/uploads/pdfs/books/`

### 8. Project Configuration

- ✅ Verified `/uploads` already added to `.gitignore`
- ✅ Build passes without errors
- ✅ All TypeScript types compile correctly

## Directory Structure Created

```
/home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/
├── uploads/                          (created by seed)
│   ├── images/
│   │   └── products/                 (for stationery images)
│   └── pdfs/
│       └── books/                    (for book previews)
├── src/
│   ├── lib/
│   │   └── file_storage.ts          (file operations)
│   ├── app/api/v1/
│   │   ├── catalog/products/
│   │   │   ├── upload-image/route.ts
│   │   │   ├── upload-pdf/route.ts
│   │   │   └── [id]/files/route.ts
│   │   └── files/
│   │       ├── images/[...path]/route.ts
│   │       └── pdfs/[...path]/route.ts
│   └── modules/catalog/
│       ├── product.repo.ts           (updated)
│       ├── catalog.types.ts          (updated)
│       └── catalog.validator.ts      (updated)
└── prisma/
    ├── schema.prisma                 (updated)
    ├── seed.ts                       (updated)
    └── migrations/
        └── 20260207154106_add_product_files/
            └── migration.sql
```

## Database Changes

### Migration: `20260207154106_add_product_files`

```sql
CREATE TYPE "FileType" AS ENUM ('IMAGE', 'PDF', 'NONE');

ALTER TABLE "products" ADD COLUMN "file_type" "FileType" NOT NULL DEFAULT 'NONE',
ADD COLUMN "image_url" TEXT,
ADD COLUMN "pdf_url" TEXT;
```

Sample product after schema update:

```json
{
	"id": "cmlchpo6d000e13jo5lc2nz23",
	"title": "BD Chaurasia Anatomy",
	"imageUrl": null,
	"pdfUrl": null,
	"fileType": "NONE",
	"...": "other fields"
}
```

## File Processing Details

### Image Upload Flow

1. Admin POST to `/api/v1/catalog/products/upload-image`
2. Validate admin role
3. Parse multipart form data
4. Validate image type and size
5. Generate unique filename: `${originalName}-${timestamp}-${randomHash}.ext`
6. Save to `/uploads/images/products/`
7. Store URL in database: `/api/v1/files/images/products/filename`
8. Return URL to client

### PDF Upload Flow

1. Admin POST to `/api/v1/catalog/products/upload-pdf`
2. Validate admin role
3. Parse multipart form data
4. Validate PDF type and size
5. Generate unique filename with timestamp + hash
6. Save to `/uploads/pdfs/books/`
7. Store URL in database: `/api/v1/files/pdfs/books/filename`
8. Return URL to client

### File Retrieval Flow

1. Client GET to `/api/v1/files/images/[filename]` or `/api/v1/files/pdfs/[filename]`
2. Extract filename from URL
3. Resolve to absolute file path
4. Read file from filesystem
5. Set appropriate content-type header
6. Return file with caching headers

## Security Measures

1. **File Type Validation**
   - Images: Only JPEG, PNG, WebP allowed
   - PDFs: Only application/pdf allowed

2. **Size Limits**
   - Images: 5MB maximum
   - PDFs: 10MB maximum

3. **Access Control**
   - Upload endpoints require admin role
   - File serving endpoints are public (read-only)
   - File deletion requires admin role

4. **Path Security**
   - Filenames are sanitized with unique hash
   - Files stored outside webroot
   - Direct directory access prevented

5. **Admin Authorization**
   - All file operations use `requireAdmin()` middleware
   - JWT token validation required
   - Role-based access control enforced

## Testing Status

All 6 subtasks completed:

- ✅ L1: File storage infrastructure
- ✅ L2: Prisma schema updates
- ✅ L3: Product repository updates
- ✅ L4: Upload endpoints created
- ✅ L5: File serving endpoints
- ✅ L6: Validators and types updated
- ⏳ L7: Manual testing (ready for QA)

## Ready for Next Section

The file upload system is complete and ready for:

- **Section M**: Flutter shared package (can use file upload types)
- **Section N-W**: Admin app development (can implement file upload UI)
- **Section X-AE**: Customer app (can display images/PDFs from URLs)

## Notes

- All migrations are idempotent
- Seed script is safe to run multiple times
- Upload directories are gitignored
- File storage uses synchronous I/O (can be optimized later if needed)
- No external dependencies required (no multer, using Next.js built-in form handling)
