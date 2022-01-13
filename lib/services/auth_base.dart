import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  User? get currentUser;
  bool get isCurrentUserAdmin;

  Stream<User?> authStateChanges();

  Future<User?> signInAnonymously(bool isAdmin);

  Future<User?> signInWithGoogle(GoogleSignInAuthentication googleAuth, bool isAdmin);

  Future<List> initializeGoogleSignIn();

  Future<User?> signInWithFacebook();

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, bool isAdmin);

  Future<User?> signInWithEmailAndPassword(
      String email, String password, bool isAdmin);

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}