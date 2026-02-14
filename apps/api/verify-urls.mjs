import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("📚 Verifying Product URLs:\n");
  
  const products = await prisma.product.findMany({
    select: { id: true, title: true, imageUrl: true, pdfUrl: true },
    take: 5,
  });
  
  products.forEach((p) => {
    console.log(`\n📦 ${p.title.substring(0, 50)}`);
    console.log(`   Image: ${p.imageUrl}`);
    console.log(`   PDF:   ${p.pdfUrl || "N/A"}`);
  });
  
  console.log("\n✅ URL verification complete!");
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error("❌ Error:", e.message);
    await prisma.$disconnect();
    process.exit(1);
  });
