-- CreateTable
CREATE TABLE "support_info" (
    "id" TEXT NOT NULL,
    "shop_name" TEXT,
    "shop_phone" TEXT,
    "shop_email" TEXT,
    "shop_whatsapp" TEXT,
    "shop_address" TEXT,
    "developer_name" TEXT,
    "developer_email" TEXT,
    "developer_whatsapp" TEXT,
    "working_hours" TEXT,
    "website_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "support_info_pkey" PRIMARY KEY ("id")
);
