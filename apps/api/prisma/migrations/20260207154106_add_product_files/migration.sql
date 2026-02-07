-- CreateEnum
CREATE TYPE "FileType" AS ENUM ('IMAGE', 'PDF', 'NONE');

-- AlterTable
ALTER TABLE "products" ADD COLUMN     "file_type" "FileType" NOT NULL DEFAULT 'NONE',
ADD COLUMN     "image_url" TEXT,
ADD COLUMN     "pdf_url" TEXT;
