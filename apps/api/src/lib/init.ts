import { initializeUploadDirs } from "@/lib/file_storage";

/**
 * Initialize application on startup
 * This is called early when the app starts
 */
export async function initializeApp() {
	console.log("[Init] Initializing application...");

	try {
		// Initialize upload directories
		initializeUploadDirs();
		console.log("[Init] Upload directories initialized successfully");
	} catch (error) {
		console.error("[Init] Error initializing application:", error);
		// Don't fail startup if initialization has issues
	}
}

// Call initialization immediately when this module is imported
if (typeof window === "undefined") {
	// Only run on server side
	initializeApp().catch((error) => {
		console.error("[Init] Fatal error during initialization:", error);
	});
}
