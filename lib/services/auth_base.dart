import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_recommendation_system/model/user.dart';

abstract class AuthBase {
  User? get currentUser;

  bool? get isCurrentUserAdmin;

  MyUser? get myUser;

  Stream<User?> authStateChanges();

  Future<User?> signInWithGoogle(
      GoogleSignInAuthentication googleAuth, bool isAdmin);

  Future<List?> initializeGoogleSignIn();

  Future<void> terminateGoogleSignIn();

  Future<void> deleteUserAccount();

  Future<User?> signInWithFacebook();

  Future<bool> isBiometricsAvailable();

  Future<bool> authenticateLocally();

  void setCurrentUserAdmin(bool value);

  void setMyUser(MyUser value);

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, bool isAdmin, String name);

  Future<User?> signInWithEmailAndPassword(
      String email, String password, bool isAdmin);

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
