import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_packages/widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/models/email_sign_in_model.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({required this.model, required this.db});

  final EmailSignInModel model;
  final Database db;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final db = Provider.of<Database>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInModel>(
      create: (_) => EmailSignInModel(auth: auth),
      child: Consumer<EmailSignInModel>(
          builder: (_, model, __) => EmailSignInForm(
              model: model,
              db: db) //every time called when notify listener called
          ),
    );
  }

  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();

  EmailSignInModel get model => widget.model;

  Database get db => widget.db;

  @override
  void dispose() {
    _emailController.dispose();
    _node.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      bool success = false;
      if (model.formType == EmailSignInFormType.signIn) {
        if (await checkIfUserExists(model.email)) {
          if (await canLogin(model.email, model.isAdmin)) {
            success = await model.submit(context);
          } else {
            await showExceptionAlertDialog(
              context: context,
              title: 'Operation Not Allowed',
              exception: new FirebaseAuthException(
                  code: 'ERROR_OPERATION_NOT_ALLOWED',
                  message: 'Restricted User Type!'),
            );
          }
        } else {
          success = await model.submit(context, ifExists: true);
        }
      } else {
        success = await model.submit(context);
      }
      if (success) {
        if (model.formType == EmailSignInFormType.forgotPassword) {
          await showAlertDialog(
            context: context,
            title: "Reset Link Sent",
            content: "Reset link has been sent your email address!",
            defaultActionText: "OK",
          );
          _updateFormType(EmailSignInFormType.signIn);
        }
      }
    } on Exception catch (e) {
      _showSignInError(context, e);
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    }
  }

  void _updateFormType(EmailSignInFormType formType) {
    model.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  Widget _buildHeader() {
    if (model.isLoading) {
      return SizedBox(
        height: 80,
        child: Center(
            child: LoadingAnimationWidget.staggeredDotWave(
          color: Colors.teal,
          size: 65,
        )),
      );
    }
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Text(
          'Hello User!\nPlease fill this form to get started',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return [
      if (model.formType == EmailSignInFormType.register) ...<Widget>[
        _buildNameTextField(),
      ],
      _buildEmailTextField(),
      if (model.formType != EmailSignInFormType.forgotPassword) ...<Widget>[
        SizedBox(height: 8.0),
        _buildPasswordTextField(),
      ],
      SizedBox(height: 8.0),
      SocialLoginButton(
        buttonType: SocialLoginButtonType.generalLogin,
        backgroundColor: Colors.teal,
        disabledBackgroundColor: Colors.grey,
        text: model.primaryButtonText,
        fontSize: 20,
        height: 44,
        borderRadius: 25,
        onPressed: model.canSubmit ? _submit : null,
      ),
      if (!model.isAdmin) ...<Widget>[
        SizedBox(height: 8.0),
        TextButton(
          child:
              Text(model.secondaryButtonText!, style: TextStyle(fontSize: 15)),
          onPressed: model.isLoading
              ? null
              : () => _updateFormType(model.secondaryActionFormType!),
        )
      ],
      if (model.formType == EmailSignInFormType.signIn)
        TextButton(
          child: Text('Forgot password?', style: TextStyle(fontSize: 15)),
          onPressed: model.isLoading
              ? null
              : () => _updateFormType(EmailSignInFormType.forgotPassword),
        ),
      SizedBox(height: 8.0),
      Text(
        "OR",
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SocialLoginButton(
            buttonType: SocialLoginButtonType.google,
            onPressed: () => _signInWithGoogle(context),
            mode: model.isAdmin
                ? SocialLoginButtonMode.multi
                : SocialLoginButtonMode.single,
          ),
          if (!model.isAdmin) ...<Widget>[
            SocialLoginButton(
              buttonType: SocialLoginButtonType.facebook,
              onPressed: () => _signInWithFacebook(context),
              mode: SocialLoginButtonMode.single,
            ),
          ],
        ],
      ),
    ];
  }

  void _showSignInError(BuildContext context, Exception exception,
      [bool isSignIn = true]) {
    showExceptionAlertDialog(
      title: isSignIn ? 'Sign in failed' : 'Registration Failed',
      exception: exception,
      context: context,
    );
  }

  Future<bool> checkIfUserExists(String email) async {
    final users = await db.usersStream().first;
    final allEmails = users.map((user) => user.email).toList();
    if (!allEmails.contains(email)) {
      return false;
    }
    return true;
  }

  Future<bool> canLogin(String email, bool isAdmin) async {
    final users = await db.usersStream().first;
    final allUsers = users.map((user) => user).toList();
    bool _isAdmin =
        allUsers.where((user) => user.email == email).first.isAdmin!;
    if (_isAdmin == isAdmin) {
      return true;
    }
    return false;
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      model.updateWith(isLoading: true);
      final googleSignInInfo = await auth.initializeGoogleSignIn();
      if (googleSignInInfo == null) {
        throw Exception('Something Went Wrong!');
      } else {
        final googleAuth = googleSignInInfo.elementAt(0);
        final email = googleSignInInfo.elementAt(1);
        bool userExists = await checkIfUserExists(email);
        var user = MyUser(email: email, isAdmin: model.isAdmin);
        if (!userExists && !model.isAdmin) {
          await auth.signInWithGoogle(googleAuth, model.isAdmin);
          auth.setMyUser(user);
        } else {
          if (await canLogin(email, model.isAdmin)) {
            await auth.signInWithGoogle(googleAuth, model.isAdmin);
            auth.setMyUser(user);
          } else {
            await auth.terminateGoogleSignIn();
            throw FirebaseAuthException(
                code: 'ERROR_OPERATION_NOT_ALLOWED',
                message: 'Restricted User Type!');
          }
        }
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: e.toString().split(':').elementAt(1));
    } finally {
      try {
        model.updateWith(isLoading: false);
      } catch (e) {}
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signInWithFacebook();

      var user = MyUser(
          email: auth.currentUser!.email!,
          isAdmin: false);

      auth.setMyUser(user);
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      try {
        model.updateWith(isLoading: false);
      } catch (e) {}
    }
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.email],
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'test@test.com',
        errorText: model.emailErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      keyboardAppearance: Brightness.light,
      onChanged: model.updateEmail,
      onEditingComplete: _emailEditingComplete,
      inputFormatters: <TextInputFormatter>[
        model.emailInputFormatter,
      ],
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.name],
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        errorText: model.nameErrorText,
        enabled: !model.isLoading,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      keyboardAppearance: Brightness.light,
      onChanged: model.updateName,
      onEditingComplete: _emailEditingComplete,
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.password],
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: model.passwordLabelText,
        errorText: model.passwordErrorText,
        enabled: !model.isLoading,
        suffixIcon: IconButton(
          alignment: Alignment.bottomRight,
          icon: model.showPassword
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
          color: model.showPassword ? Colors.teal : Colors.grey,
          onPressed: () {
            model.updateWith(showPassword: !model.showPassword);
          },
        ),
      ),
      obscureText: !model.showPassword,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      keyboardAppearance: Brightness.light,
      onChanged: model.updatePassword,
      onEditingComplete: _passwordEditingComplete,
    );
  }

  void _emailEditingComplete() {
    if (model.canSubmitEmail) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!model.canSubmitEmail) {
      _node.previousFocus();
      return;
    }
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
            child: Text(
              model.formType == EmailSignInFormType.register
                  ? 'Account Type'
                  : 'Choose Account Type',
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (model.formType != EmailSignInFormType.register) ...<Widget>[
                InkWell(
                  onTap: () => model.updateWith(isAdmin: true),
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Card(
                      borderOnForeground: true,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: model.isAdmin
                                ? Colors.teal
                                : Colors.grey.shade200,
                            width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image(
                            image: AssetImage('resources/images/admin.png'),
                          ),
                          Text(
                            'Admin User',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
              InkWell(
                onTap: () => model.updateWith(isAdmin: false),
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Card(
                    borderOnForeground: true,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: !model.isAdmin
                              ? Colors.teal
                              : Colors.grey.shade200,
                          width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(
                          image: AssetImage('resources/images/user.png'),
                        ),
                        Text(
                          'Standard User',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          _buildHeader(),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            color: Colors.white,
            borderOnForeground: true,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AutofillGroup(
                onDisposeAction:
                    model.formType == EmailSignInFormType.forgotPassword
                        ? AutofillContextAction.commit
                        : AutofillContextAction.commit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildChildren(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
