import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable Firebase User
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    // Listen to login/logout
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Getter for user
  User? get user => firebaseUser.value;

  // SIGN IN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // SIGN UP
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
