import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reactive Firebase user
  final Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    // ✅ Bind auth state stream (non-blocking)
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Get current user
  User? get user => firebaseUser.value;

  // ---------------------------------------------------------
  // 🔐 LOGIN
  // ---------------------------------------------------------
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (_) {
      return "Unexpected error occurred. Please try again.";
    }
  }

  // ---------------------------------------------------------
  // 📝 REGISTER
  // ---------------------------------------------------------
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (_) {
      return "Unexpected error occurred. Please try again.";
    }
  }

  // ---------------------------------------------------------
  // 🚪 LOGOUT
  // ---------------------------------------------------------
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      Get.log("Logout error: $e");
    }
  }

  // ---------------------------------------------------------
  // ❌ ERROR HANDLER (SAFE + CLEAN)
  // ---------------------------------------------------------
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'too-many-requests':
        return "Too many attempts. Try again later.";
      case 'network-request-failed':
        return "No internet connection.";
      default:
        return e.message ?? "Authentication failed.";
    }
  }
}
