// Seed support info via API
const apiUrl = "http://192.168.0.7:3000/api/v1/admin/support";

const supportData = {
	shopName: "Vijaya Xerox & Stationery",
	shopPhone: "+91 1234567890",
	shopEmail: "vijayaxerox@example.com",
	shopWhatsapp: "+911234567890",
	shopAddress: "123 Main Street, City Name, State - 123456",
	developerName: "Developer Team",
	developerEmail: "developer@example.com",
	developerWhatsapp: "+919876543210",
	workingHours: "Monday to Saturday: 9:00 AM - 7:00 PM\nSunday: Closed",
	websiteUrl: "https://vijayaxerox.com",
};

// Get admin token from Firebase login first
const adminToken = process.env.ADMIN_TOKEN || "your-admin-token-here";

console.log("Seeding support info...");
console.log("Data:", JSON.stringify(supportData, null, 2));
console.log("\nTo seed this data, run:");
console.log(`curl -X PATCH '${apiUrl}' \\`);
console.log(`  -H 'Authorization: Bearer ${adminToken}' \\`);
console.log(`  -H 'Content-Type: application/json' \\`);
console.log(`  -d '${JSON.stringify(supportData)}'`);
