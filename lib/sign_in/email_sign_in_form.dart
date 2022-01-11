import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

import 'email_sign_in_model.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({required this.model});

  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(
            model: model), //every time called when notify listner called
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

  EmailSignInChangeModel get model => widget.model;

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

  Widget _buildHeader() {
    if (model.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container();
  }

  List<Widget> _buildChildren() {
    return [
      _buildHeader(),
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
        child: Text(model.secondaryButtonText!,
            style: TextStyle(fontSize: 15)),
        onPressed: model.isLoading
            ? null
            : () => _updateFormType(model.secondaryActionFormType!),
      ),
      if (model.formType == EmailSignInFormType.signIn)
        TextButton(
          child: Text('Forgot password?',
              style: TextStyle(fontSize: 15)),
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


  UnderlineInputBorder _getTextFieldBorder({Color? color}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color ?? Colors.grey.shade200),
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
        child: Card(
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildChildren(),
            ),
          ),
        ),
      ),
    );
  }
}
