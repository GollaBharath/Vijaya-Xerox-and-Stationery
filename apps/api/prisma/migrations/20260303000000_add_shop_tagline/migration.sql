-- AlterTable
ALTER TABLE "support_info" ADD COLUMN "shop_tagline" TEXT;

-- Update existing records with default tagline
UPDATE "support_info" SET "shop_tagline" = 'Your One-Stop Shop' WHERE "shop_tagline" IS NULL;
