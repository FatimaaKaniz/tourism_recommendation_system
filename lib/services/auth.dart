import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';


class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInAnonymously() async {
    final userCredentials = await _firebaseAuth.signInAnonymously();
    return userCredentials.user;
  }
  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async{
    final userCredentials = await _firebaseAuth.signInWithCredential(
      EmailAuthProvider.credential(email: email, password: password)
    );
    return userCredentials.user;

  }
  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredentials.user;

  }

  @override
  Future<User?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    if (googleAuth.idToken != null) {
      final userCredentials = await _firebaseAuth
          .signInWithCredential(GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      ));
      return userCredentials.user;
    } else {
      throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message: 'Missing Google ID Token');
    }
  }

  @override
  Future<User?> signInWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (response.status) {
      case FacebookLoginStatus.success:
        try {
          final accessToken = response.accessToken;
          final userCredential = await _firebaseAuth.signInWithCredential(
            FacebookAuthProvider.credential(accessToken!.token),
          );
          return userCredential.user;
        } catch (e) {
          var error = e.toString().split("[")[1].split("]");
          var errorCode = error[0].split("/");
          throw FirebaseAuthException(
            code: errorCode[errorCode.length-1],
            message: error[1],
          );
        }
      case FacebookLoginStatus.cancel:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign In aborted by User',
        );
      case FacebookLoginStatus.error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: response.error!.developerMessage,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
