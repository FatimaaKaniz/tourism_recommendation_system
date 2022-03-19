import 'package:flutter/cupertino.dart';
import 'package:tourism_recommendation_system/model/user.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/custom_packages/tools/validators.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/services/database.dart';

enum SignInFormType { signIn, register, forgotPassword }

class SignInViewModel with EmailAndPasswordValidators, ChangeNotifier {
  SignInViewModel({
    required this.auth,
    this.email = '',
    this.password = '',
    this.formType = SignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
    this.isAdmin = false,
    this.showPassword = false,
    this.name = '',
  });

  final AuthBase auth;
  String email;
  String password;
  SignInFormType formType;
  bool isLoading;
  bool submitted;
  bool isAdmin;
  bool showPassword;
  String name;

  Future<bool> checkIfUserExists(Database db, {String? email}) async {
    email = email ?? this.email;
    final users = await db.usersStream().first;
    final allEmails = users.map((user) => user.email).toList();
    if (!allEmails.contains(email)) {
      return false;
    }
    return true;
  }

  Future<bool> canLogin(Database db, {String? email, bool? isAdmin}) async {
    email = email ?? this.email;
    isAdmin = isAdmin ?? this.isAdmin;
    final users = await db.usersStream().first;
    final allUsers = users.map((user) => user).toList();
    bool _isAdmin =
        allUsers.where((user) => user.email == email).first.isAdmin!;
    if (_isAdmin == isAdmin) {
      return true;
    }
    return false;
  }

  Future<bool> submit(BuildContext context, {bool? ifExists}) async {
    final db = Provider.of<Database>(context, listen: false);

    try {
      updateWith(submitted: true);
      if (!canSubmit) {
        return false;
      }
      updateWith(isLoading: true);
      switch (formType) {
        case SignInFormType.signIn:
          await auth.signInWithEmailAndPassword(email, password, isAdmin);
          await updateUser(db);
          break;
        case SignInFormType.register:
          await auth.createUserWithEmailAndPassword(
              email, password, isAdmin, name);
          if (ifExists != null && !ifExists) {
            await updateUser(db);
          }
          break;
        case SignInFormType.forgotPassword:
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

  Future<void> updateUser(Database db) async {
    var user = MyUser(
        isAdmin: this.isAdmin,
        email: email,
        name: auth.currentUser!.displayName);
    auth.setMyUser(user);
  }

  void updateEmail(String email) => updateWith(email: email);

  void updateName(String name) => updateWith(name: name);

  void updatePassword(String password) => updateWith(password: password);

  void updateFormType(SignInFormType formType) {
    updateWith(
      email: '',
      password: '',
      isAdmin: false,
      name: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  void updateWith({
    String? email,
    String? password,
    SignInFormType? formType,
    bool? isLoading,
    bool? submitted,
    bool? isAdmin,
    bool? showPassword,
    String? name,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.isAdmin = isAdmin ?? this.isAdmin;
    this.showPassword = showPassword ?? this.showPassword;
    this.name = name ?? this.name;

    notifyListeners();
  }

  String get passwordLabelText {
    if (formType == SignInFormType.register) {
      return 'Password (8+ characters)';
    }
    return 'Password';
  }

  String? get primaryButtonText {
    return <SignInFormType, String>{
      SignInFormType.register: 'Create an account',
      SignInFormType.signIn: 'Sign in',
      SignInFormType.forgotPassword: 'Send Reset Link',
    }[formType];
  }

  String? get secondaryButtonText {
    return <SignInFormType, String>{
      SignInFormType.register: 'Already have an Account?',
      SignInFormType.signIn: "Don't have an account?",
      SignInFormType.forgotPassword: 'Back to SignIn',
    }[formType];
  }

  SignInFormType? get secondaryActionFormType {
    return <SignInFormType, SignInFormType>{
      SignInFormType.register: SignInFormType.signIn,
      SignInFormType.signIn: SignInFormType.register,
      SignInFormType.forgotPassword: SignInFormType.signIn,
    }[formType];
  }

  String? get errorAlertTitle {
    return <SignInFormType, String>{
      SignInFormType.register: "Registration Failed!",
      SignInFormType.signIn: "Sign In Failed",
      SignInFormType.forgotPassword: "Password Reset Link Sending failed!",
    }[formType];
  }

  String? get title {
    return <SignInFormType, String>{
      SignInFormType.register: "Register",
      SignInFormType.signIn: "Sign In",
      SignInFormType.forgotPassword: "Forget password",
    }[formType];
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    if (formType == SignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  bool get canSubmitName {
    return nameValidator.isValid(name);
  }

  bool get canSubmit {
    final bool canSubmitFields = formType == SignInFormType.forgotPassword
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

  String? get nameErrorText {
    final bool showErrorText = submitted && !canSubmitName;
    final String errorText = 'Name can\'t be empty';
    return showErrorText ? errorText : null;
  }
}
