/*
  Warnings:

  - The `stock` column on the `product_variants` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterEnum
ALTER TYPE "VariantType" ADD VALUE 'DEFAULT';

-- AlterTable
ALTER TABLE "product_variants" DROP COLUMN "stock",
ADD COLUMN     "stock" BOOLEAN NOT NULL DEFAULT true;
