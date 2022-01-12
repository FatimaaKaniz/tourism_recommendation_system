import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import '../models/email_sign_in_model.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({required this.model});

  final EmailSignInModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInModel>(
      create: (_) => EmailSignInModel(auth: auth),
      child: Consumer<EmailSignInModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(
            model: model), //every time called when notify listener called
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusScopeNode _node = FocusScopeNode();

  EmailSignInModel get model => widget.model;

  @override
  void dispose() {
    _emailController.dispose();
    _node.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final bool success = await model.submit();
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
    } on PlatformException catch (e) {
      _showSignInError(context, e);
    }
  }

  void _updateFormType(EmailSignInFormType formType) {
    model.updateFormType(formType);
    _emailController.clear();
    _passwordController.clear();
  }

  //
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
      SizedBox(height: 8.0),
      TextButton(
        child: Text(model.secondaryButtonText!, style: TextStyle(fontSize: 15)),
        onPressed: model.isLoading
            ? null
            : () => _updateFormType(model.secondaryActionFormType!),
      ),
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
            mode: SocialLoginButtonMode.single,
          ),
          SocialLoginButton(
            buttonType: SocialLoginButtonType.facebook,
            onPressed: () => _signInWithFacebook(context),
            mode: SocialLoginButtonMode.single,
          ),
        ],
      ),
    ];
  }

  void _showSignInError(BuildContext context, Exception exception) {
    showExceptionAlertDialog(
      title: 'Sign in failed',
      exception: exception,
      context: context,
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      model.updateWith(isLoading: true);
      await auth.signInWithGoogle();
      model.updateWith(isLoading: false);
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      model.updateWith(isLoading: false);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      model.updateWith(isLoading: true);
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signInWithFacebook();
      model.updateWith(isLoading: false);
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      model.updateWith(isLoading: false);
    }
  }

  Widget _buildEmailTextField() {
    return TextField(
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

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: model.passwordLabelText,
        errorText: model.passwordErrorText,
        enabled: !model.isLoading,
      ),
      obscureText: true,
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
              child: Text(
                'Choose Account Type',
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
                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildChildren(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
