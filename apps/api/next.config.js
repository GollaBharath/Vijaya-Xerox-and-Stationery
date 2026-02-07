/** @type {import('next').NextConfig} */
const nextConfig = {
	reactStrictMode: true,
	swcMinify: true,
	poweredByHeader: false,
	env: {
		NEXT_PUBLIC_API_URL: process.env.API_BASE_URL || "http://localhost:3000",
	},
};

module.exports = nextConfig;
