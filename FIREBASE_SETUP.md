# Firebase Setup Guide

## Overview

The app now uses Firebase Authentication for user login and Google Sign-In, replacing the custom OAuth implementation.

## Prerequisites

1. Google account
2. Firebase project

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `vijaya-xerox-stationery`
4. Follow the setup wizard

### 2. Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.customer_app`
3. (Optional) Add SHA-1 certificate:
   ```bash
   cd apps/customer_app
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Download `google-services.json`
5. Place it at: `apps/customer_app/android/app/google-services.json`

### 3. Enable Authentication Methods

1. In Firebase Console, go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** sign-in
   - Use the same project for Google Sign-In
   - Firebase will auto-configure OAuth credentials

### 4. Update google-services.json

Replace the placeholder file at `apps/customer_app/android/app/google-services.json` with the actual file downloaded from Firebase.

### 5. Build and Run

```bash
cd apps/customer_app
flutter pub get
flutter run
```

## Features

### Email/Password Authentication

- User registration with email and password
- Login with email and password
- Password reset via email
- Email verification

### Google Sign-In

- One-tap Google Sign-In
- Automatic account creation
- Profile info syncing (name, email, photo)

## Security Notes

1. **Firebase Security Rules**: Configure Firestore security rules in Firebase Console
2. **API Keys**: The `google-services.json` file contains API keys - don't commit sensitive production keys to git
3. **Email Verification**: Users should verify their email addresses
4. **Password Requirements**: Firebase enforces minimum password length (6 characters)

## Testing

### Test Email/Password Login

1. Open the app
2. Click "Sign Up" to create an account
3. Enter email, password, and name
4. Login with the credentials

### Test Google Sign-In

1. Open the app
2. Click "Continue with Google"
3. Select a Google account
4. Grant permissions

## Advantages Over Custom OAuth

✅ **No backend OAuth implementation needed**

- Firebase handles all OAuth flows
- Automatic token refresh
- Secure token storage

✅ **Built-in security features**

- Rate limiting
- Brute force protection
- Account recovery

✅ **Easy to add more providers**

- Facebook, Twitter, Apple, GitHub
- Just enable in Firebase Console

✅ **Free tier is generous**

- 50,000 monthly active users
- Unlimited authentication requests

## Migration from Backend Auth

The app now uses Firebase for authentication instead of the custom backend API:

- **Before**: Custom JWT tokens from `/api/v1/auth/login`
- **After**: Firebase Auth tokens

If you need to integrate with your existing backend:

1. Verify Firebase ID tokens on the backend
2. Use Firebase Admin SDK to validate tokens
3. Map Firebase UIDs to your user database

## Troubleshooting

### Google Sign-In not working

- Verify SHA-1 certificate is added in Firebase Console
- Check that Google Sign-In is enabled in Firebase Authentication
- Ensure `google-services.json` is up to date

### Build errors

- Run `flutter clean && flutter pub get`
- Verify `com.google.gms:google-services` plugin version in `build.gradle.kts`
- Check that `google-services.json` is in the correct location

### Users not persisting

- Ensure Firebase initialization in `main.dart`
- Check Firebase Console for authentication events
- Verify internet connectivity

## Next Steps

1. Add iOS support (requires `GoogleService-Info.plist`)
2. Implement email verification flow
3. Add password reset screen
4. Configure Firebase security rules
5. Add multi-factor authentication (optional)
6. Integrate Firebase Analytics (optional)

## Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/auth/overview)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
