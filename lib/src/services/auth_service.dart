import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class AuthService {
  static const String _tag = 'AuthService';
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    AppLogger.info('Attempting sign in for email: $email', tag: _tag);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.info('Sign in successful for user: ${credential.user?.uid}', tag: _tag);
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in failed', tag: _tag, error: e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    AppLogger.info('Attempting sign up for email: $email', tag: _tag);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.info('Sign up successful for user: ${credential.user?.uid}', tag: _tag);
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign up failed', tag: _tag, error: e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign up', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    AppLogger.info('Signing out user: ${currentUser?.uid}', tag: _tag);
    try {
      await _auth.signOut();
      AppLogger.info('Sign out successful', tag: _tag);
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    AppLogger.info('Sending password reset email to: $email', tag: _tag);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent', tag: _tag);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', tag: _tag, error: e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during password reset', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Convert Firebase Auth exceptions to user-friendly error messages
  AuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password sign-in is not enabled.';
        break;
      case 'weak-password':
        message = 'The password is too weak. Please use at least 6 characters.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please check your credentials.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = 'Authentication failed: ${e.message ?? e.code}';
    }
    return AuthException(code: e.code, message: message);
  }
}

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  @override
  String toString() => message;
}

