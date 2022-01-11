import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthBase {
  User? get currentUser;

  Stream<User?> authStateChanges();

  Future<User?> signInAnonymously();

  Future<User?> signInWithGoogle();

  Future<User?> signInWithFacebook();

  Future<User?> createUserWithEmailAndPassword(String email, String password);

  Future<User?> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}