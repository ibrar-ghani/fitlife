import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase user stream
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    // Firebase is initialized in main.dart — DO NOT initialize here!
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // ---------------------------------------------------------
  // 🔥 GET CURRENT USER
  // ---------------------------------------------------------
  User? get user => firebaseUser.value;

  // ---------------------------------------------------------
  // 🔥 LOGIN USER
  // ---------------------------------------------------------
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  // ---------------------------------------------------------
  // 🔥 REGISTER NEW USER
  // ---------------------------------------------------------
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  // ---------------------------------------------------------
  // 🔥 LOGOUT
  // ---------------------------------------------------------
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // ---------------------------------------------------------
  // 🔥 ERROR HANDLER
  // ---------------------------------------------------------
  String _handleAuthError(Object error) {
    final String message = error.toString();

    if (message.contains("wrong-password")) {
      return "Incorrect password. Please try again.";
    } else if (message.contains("user-not-found")) {
      return "No user found with this email.";
    } else if (message.contains("invalid-email")) {
      return "Invalid email address.";
    } else if (message.contains("email-already-in-use")) {
      return "This email is already registered.";
    } else if (message.contains("too-many-requests")) {
      return "Too many attempts. Try again later.";
    } else if (message.contains("network-request-failed")) {
      return "No internet connection. Please check your network.";
    }

    return "Authentication error: $message";
  }
}
