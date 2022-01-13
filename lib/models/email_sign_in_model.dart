import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/sign_in/validators.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/services/database.dart';

enum EmailSignInFormType { signIn, register, forgotPassword }

class EmailSignInModel with EmailAndPasswordValidators, ChangeNotifier {
  EmailSignInModel({
    required this.auth,
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
    this.isAdmin = false,
  });

  final AuthBase auth;
  String email;
  String password;
  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;
  bool isAdmin;

  Future<bool> submit(BuildContext context) async {
    final db = Provider.of<Database>(context, listen: false);

    try {
      updateWith(submitted: true);
      if (!canSubmit) {
        return false;
      }
      updateWith(isLoading: true);
      switch (formType) {
        case EmailSignInFormType.signIn:
          await auth.signInWithEmailAndPassword(email, password, isAdmin);
          break;
        case EmailSignInFormType.register:
          await auth.createUserWithEmailAndPassword(email, password, isAdmin);
          db.setUser(MyUser(isAdmin: this.isAdmin, email: email),
              auth.currentUser!.uid);
          break;
        case EmailSignInFormType.forgotPassword:
          await auth.sendPasswordResetEmail(email);
          updateWith(isLoading: false);
          break;
      }
      return true;
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);

  void updateFormType(EmailSignInFormType formType) {
    updateWith(
      email: '',
      password: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  void updateWith({
    String? email,
    String? password,
    EmailSignInFormType? formType,
    bool? isLoading,
    bool? submitted,
    bool? isAdmin,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.isAdmin = isAdmin ?? this.isAdmin;
    notifyListeners();
  }

  String get passwordLabelText {
    if (formType == EmailSignInFormType.register) {
      return 'Password (8+ characters)';
    }
    return 'Password';
  }

  String? get primaryButtonText {
    return <EmailSignInFormType, String>{
      EmailSignInFormType.register: 'Create an account',
      EmailSignInFormType.signIn: 'Sign in',
      EmailSignInFormType.forgotPassword: 'Send Reset Link',
    }[formType];
  }

  String? get secondaryButtonText {
    return <EmailSignInFormType, String>{
      EmailSignInFormType.register: 'Already have an Account?',
      EmailSignInFormType.signIn: "Don't have an account?",
      EmailSignInFormType.forgotPassword: 'Back to SignIn',
    }[formType];
  }

  EmailSignInFormType? get secondaryActionFormType {
    return <EmailSignInFormType, EmailSignInFormType>{
      EmailSignInFormType.register: EmailSignInFormType.signIn,
      EmailSignInFormType.signIn: EmailSignInFormType.register,
      EmailSignInFormType.forgotPassword: EmailSignInFormType.signIn,
    }[formType];
  }

  String? get errorAlertTitle {
    return <EmailSignInFormType, String>{
      EmailSignInFormType.register: "Registration Failed!",
      EmailSignInFormType.signIn: "Sign In Failed",
      EmailSignInFormType.forgotPassword: "Password Reset Link Sending failed!",
    }[formType];
  }

  String? get title {
    return <EmailSignInFormType, String>{
      EmailSignInFormType.register: "Register",
      EmailSignInFormType.signIn: "Sign In",
      EmailSignInFormType.forgotPassword: "Forget password",
    }[formType];
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    if (formType == EmailSignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  bool get canSubmit {
    final bool canSubmitFields = formType == EmailSignInFormType.forgotPassword
        ? canSubmitEmail
        : canSubmitEmail && canSubmitPassword;
    return canSubmitFields && !isLoading;
  }

  String? get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    final String errorText =
        email.isEmpty ? 'Email is invalid' : 'Email can\'t be empty';
    return showErrorText ? errorText : null;
  }

  String? get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    final String errorText =
        password.isEmpty ? 'Password can\'t be empty' : 'Password is too short';
    return showErrorText ? errorText : null;
  }
}
