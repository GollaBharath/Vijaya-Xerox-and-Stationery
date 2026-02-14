import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("📊 Database Verification Report\n");
  
  const users = await prisma.user.count();
  console.log(`✓ Users: ${users}`);
  
  const categories = await prisma.category.count();
  console.log(`✓ Categories: ${categories}`);
  
  const subjects = await prisma.subject.count();
  console.log(`✓ Subjects: ${subjects}`);
  
  const products = await prisma.product.count();
  console.log(`✓ Products: ${products}`);
  
  const variants = await prisma.productVariant.count();
  console.log(`✓ Product Variants: ${variants}`);
  
  console.log("\n📚 Products with Media:");
  const productsWithMedia = await prisma.product.findMany({
    select: { title: true, imageUrl: true, pdfUrl: true, fileType: true },
    take: 5,
  });
  
  productsWithMedia.forEach((p, i) => {
    console.log(`\n  ${i + 1}. ${p.title}`);
    console.log(`     Image: ${p.imageUrl || "N/A"}`);
    console.log(`     PDF: ${p.pdfUrl || "N/A"}`);
    console.log(`     Type: ${p.fileType}`);
  });
  
  console.log("\n✅ Database seeding verification complete!");
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
