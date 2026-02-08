import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_shared/models/user.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import '../../../core/config/constants.dart';

/// Firebase Authentication Provider
class FirebaseAuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiClient _apiClient;

  // State variables
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isSplashComplete = false;

  // Constructor
  FirebaseAuthProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSplashComplete => _isSplashComplete;
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);

      // Check if user is already logged in
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromFirebase(firebaseUser);
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }

    _isSplashComplete = true;
    notifyListeners();
  }

  /// Handle auth state changes
  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      await _clearLocalStorage();
    } else {
      await _loadUserFromFirebase(firebaseUser);
    }
    notifyListeners();
  }

  /// Load user data from Firebase user
  Future<void> _loadUserFromFirebase(firebase_auth.User firebaseUser) async {
    _currentUser = User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      role: 'CUSTOMER',
      isActive: true,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );

    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.spKeyUser,
      _currentUser!.toJson().toString(),
    );
  }

  /// Clear local storage
  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.spKeyAuthToken);
    await prefs.remove(AppConstants.spKeyRefreshToken);
    await prefs.remove(AppConstants.spKeyUser);
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _loadUserFromFirebase(userCredential.user!);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e);
      rethrow;
    } catch (e) {
      _error = 'An unexpected error occurred';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Register with email and password
  Future<void> register(String email, String password, String name) async {
    _setLoading(true);
    _error = null;

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser != null) {
          await _loadUserFromFirebase(updatedUser);
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e);
      rethrow;
    } catch (e) {
      _error = 'An unexpected error occurred';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    print('🟢 signInWithGoogle started');
    _setLoading(true);
    _error = null;

    try {
      // Trigger the Google Sign In flow
      print('🟢 Triggering Google Sign-In dialog...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print('🟠 User canceled Google Sign-In');
        _setLoading(false);
        return;
      }

      print('🟢 Got Google user: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🟢 Got auth tokens');

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🟢 Signing in to Firebase...');
      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      print(
        '🟢 Firebase sign-in successful. User: ${userCredential.user?.email}',
      );

      if (userCredential.user != null) {
        // Get Firebase ID token
        final idToken = await userCredential.user!.getIdToken();
        print('🟢 Got Firebase ID token');

        // Call backend to sync user and get JWT tokens
        try {
          final response = await _apiClient.post(
            ApiEndpoints.authFirebaseLogin,
            body: {'idToken': idToken},
            withAuth: false, // No auth needed for login
          );

          print('🟢 Backend response: $response');

          // Extract backend tokens
          final backendData = response['data'];
          final user = backendData['user'];
          final tokens = backendData['tokens'];

          // Save backend JWT tokens using TokenManager (same keys as ApiClient uses)
          await _apiClient.tokenManager.saveTokens(
            accessToken: tokens['accessToken'],
            refreshToken: tokens['refreshToken'],
            userId: user['id'],
            userRole: user['role'],
          );

          print('🟢 Tokens saved via TokenManager');

          // Load user data from backend response
          _currentUser = User(
            id: user['id'],
            email: user['email'],
            name: user['name'],
            phone: user['phone'] ?? '',
            role: user['role'],
            isActive: user['isActive'],
            createdAt: DateTime.parse(user['createdAt']),
          );

          // Save user to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            AppConstants.spKeyUser,
            _currentUser!.toJson().toString(),
          );

          print('🟢 User synced with backend: ${_currentUser?.email}');
        } catch (e, stackTrace) {
          print('🔴 Backend sync error: $e');
          print('🔴 Stack trace: $stackTrace');
          // If backend fails, still load from Firebase
          await _loadUserFromFirebase(userCredential.user!);
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('🔴 FirebaseAuthException: ${e.code} - ${e.message}');
      _error = _mapFirebaseError(e);
      rethrow;
    } catch (e) {
      print('🔴 Sign-in error: $e');
      _error = 'Failed to sign in with Google';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> logout() async {
    _setLoading(true);

    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

      _currentUser = null;
      await _clearLocalStorage();
    } catch (e) {
      _error = 'Failed to sign out';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e);
      rethrow;
    } catch (e) {
      _error = 'Failed to send password reset email';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Map Firebase errors to user-friendly messages
  String _mapFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
