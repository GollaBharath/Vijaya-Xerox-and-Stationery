# Simplify Variant and Stock Management

## Overview

Simplify the product management workflow by:
1. Automatically creating a default variant when products are created without explicit variants
2. Replacing numeric stock tracking with a simple boolean in-stock/out-of-stock toggle

## User Review Required

> [!IMPORTANT]
> **Breaking Change**: Existing products with numeric stock values will need migration
> 
> Products with stock > 0 will be marked as in-stock (true), stock = 0 will be out-of-stock (false).

## Proposed Changes

### Backend Changes

#### [product.repo.ts](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/product.repo.ts)

**Modify [createProduct](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/product.repo.ts#145-180) function:**
- After creating product, automatically create a default variant
- Variant type: "DEFAULT"
- Price: Use the product's `basePrice`
- Stock: Default to `true` (in stock)

```typescript
// After product creation
await prisma.productVariant.create({
  data: {
    productId: product.id,
    variantType: "DEFAULT",
    price: data.basePrice,
    stock: true, // Boolean instead of number
    sku: `${product.id}-DEFAULT`,
  },
});
```

---

#### Database Schema Migration

**Change `stock` field from `Int` to `Boolean`:**

```prisma
model ProductVariant {
  id          String   @id @default(cuid())
  productId   String   @map("product_id")
  variantType String   @map("variant_type")
  price       Float
  stock       Boolean  @default(true)  // Changed from Int
  sku         String?
  // ... rest of fields
}
```

**Migration steps:**
1. Create migration to alter column type
2. Convert existing data: `stock > 0` → `true`, `stock = 0` → `false`

---

#### [variant.repo.ts](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/api/src/modules/catalog/variant.repo.ts)

**Update all variant operations:**
- Change `stock` parameter from `number` to `boolean`
- Update return types and validation

---

### Frontend Changes (Admin App)

#### Variant Form

**Replace stock number input with toggle switch:**

```dart
// Before
TextFormField(
  decoration: InputDecoration(labelText: 'Stock'),
  keyboardType: TextInputType.number,
  // ...
)

// After
SwitchListTile(
  title: Text('In Stock'),
  subtitle: Text('Toggle to mark product availability'),
  value: isInStock,
  onChanged: (value) => setState(() => isInStock = value),
)
```

---

#### Product Creation Flow

**Remove manual variant creation requirement:**
- Product creation form only needs: title, description, price, image
- Default variant created automatically on backend
- Admin can add additional variants later if needed (e.g., different colors, sizes)

---

### Frontend Changes (Customer App)

#### [product_card.dart](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/customer_app/lib/features/catalog/widgets/product_card.dart)

**Update stock checking logic:**

```dart
// Before
final isInStock = variant != null && variant.stock > 0;

// After
final isInStock = variant != null && variant.stock == true;
```

---

#### [product_detail_screen.dart](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/apps/customer_app/lib/features/catalog/screens/product_detail_screen.dart)

**Update stock display:**

```dart
// Before
Text('In Stock ($stock available)')

// After
Text('In Stock') // No quantity shown
```

---

### Shared Model Updates

#### [product.dart](file:///home/dead/freelancing/Vijaya-Xerox-and-Stationery/packages/flutter_shared/lib/models/product.dart)

**Update `ProductVariant` model:**

```dart
class ProductVariant {
  final String id;
  final String productId;
  final String variantType;
  final double price;
  final bool stock;  // Changed from int
  final String? sku;
  // ...
}
```

**Update JSON parsing:**

```dart
stock: json['stock'] as bool,  // Instead of as int
```

---

## Implementation Order

1. **Database Migration**
   - Create Prisma migration to change stock column type
   - Run migration to convert existing data

2. **Backend Updates**
   - Update variant repository functions
   - Modify product creation to auto-create default variant
   - Update API response types

3. **Shared Model Updates**
   - Update ProductVariant model in flutter_shared
   - Update JSON serialization/deserialization

4. **Admin App Updates**
   - Replace stock number input with toggle
   - Update variant creation/edit forms
   - Test product creation flow

5. **Customer App Updates**
   - Update stock checking logic
   - Update stock display UI
   - Test add-to-cart functionality

## Verification Plan

### Database Verification
```sql
-- Check variant types
SELECT variant_type, COUNT(*) 
FROM product_variants 
GROUP BY variant_type;

-- Verify stock values are boolean
SELECT stock, COUNT(*) 
FROM product_variants 
GROUP BY stock;
```

### API Testing
```bash
# Create product without variants
curl -X POST http://localhost:3000/api/v1/catalog/products \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Product",
    "basePrice": 99.99,
    "description": "Test"
  }'

# Verify default variant was created
curl http://localhost:3000/api/v1/catalog/products/{id}/variants
```

### Manual Testing
- ✅ Create new product in admin app (no manual variant needed)
- ✅ Verify default variant appears automatically
- ✅ Toggle stock on/off in admin app
- ✅ Verify customer app shows correct availability
- ✅ Test add-to-cart for in-stock products
- ✅ Verify out-of-stock products disable add-to-cart button
