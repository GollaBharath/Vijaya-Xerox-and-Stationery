/**
 * Firebase Admin SDK initialization
 */

import * as admin from "firebase-admin";
import { logger } from "./logger";
import * as path from "path";
import * as fs from "fs";

let firebaseApp: admin.app.App | null = null;

export function initializeFirebaseAdmin() {
	if (firebaseApp) {
		return firebaseApp;
	}

	try {
		// Check if Firebase Admin is already initialized
		try {
			firebaseApp = admin.app();
			logger.info("Firebase Admin already initialized, reusing existing app");
			return firebaseApp;
		} catch (e) {
			// App doesn't exist, proceed with initialization
		}

		const projectId =
			process.env.FIREBASE_PROJECT_ID || "vijaya-xerox-stationery";
		const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

		let credential: admin.credential.Credential | undefined;

		// Try to load service account credentials
		if (credentialsPath) {
			const fullPath = path.resolve(process.cwd(), credentialsPath);
			if (fs.existsSync(fullPath)) {
				credential = admin.credential.cert(fullPath);
				logger.info("Firebase Admin initialized with service account", {
					projectId,
				});
			} else {
				logger.warn("Service account file not found", { path: fullPath });
			}
		}

		// Initialize Firebase Admin
		firebaseApp = admin.initializeApp({
			credential: credential,
			projectId: projectId,
		});

		logger.info("Firebase Admin initialized", { projectId });
		return firebaseApp;
	} catch (error) {
		logger.error("Failed to initialize Firebase Admin", { error });
		throw error;
	}
}

export async function verifyFirebaseToken(
	idToken: string,
): Promise<admin.auth.DecodedIdToken> {
	if (!firebaseApp) {
		initializeFirebaseAdmin();
	}

	try {
		// Try to verify with Firebase Admin
		const decodedToken = await admin.auth().verifyIdToken(idToken);
		return decodedToken;
	} catch (error: any) {
		logger.warn("Firebase token verification failed, attempting fallback", {
			error: error?.message,
		});

		// DEVELOPMENT FALLBACK: Decode token without verification
		// WARNING: This is NOT secure for production!
		// Only use this in development when proper service account is not set up
		if (process.env.NODE_ENV === "development") {
			try {
				// Decode JWT without verification (for development only)
				const base64Payload = idToken.split(".")[1];
				const payload = JSON.parse(
					Buffer.from(base64Payload, "base64").toString(),
				);

				logger.warn("Using unverified token payload (DEVELOPMENT ONLY)", {
					email: payload.email,
				});

				return payload as admin.auth.DecodedIdToken;
			} catch (decodeError) {
				logger.error("Failed to decode token payload", { decodeError });
				throw new Error("Invalid Firebase token");
			}
		}

		logger.error("Failed to verify Firebase token", { error });
		throw new Error("Invalid Firebase token");
	}
}

export function getFirebaseAuth() {
	if (!firebaseApp) {
		initializeFirebaseAdmin();
	}
	return admin.auth();
}
