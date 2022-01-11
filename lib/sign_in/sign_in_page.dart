import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/custom_widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/sign_in/sign_in_bloc.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key, required this.bloc, required this.isLoading})
      : super(key: key);
  final SignInBloc bloc;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInBloc>(
          create: (_) => SignInBloc(auth: auth, isLoading: isLoading),
          child: Consumer<SignInBloc>(
            builder: (_, bloc, __) =>
                SignInPage(bloc: bloc, isLoading: isLoading.value),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    showExceptionAlertDialog(
      title: 'Sign in failed',
      exception: exception,
      context: context,
    );
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await bloc.signInAnonymously();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await bloc.signInWithFacebook();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        //builder: (context) => EmailSignInPage(),
        builder: (context) => Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tourism Recommendation System'),
        elevation: 2.0,
      ),
      body: _buildContent(context),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            child: _buildHeader(),
          ),
          SizedBox(height: 48.0),

          SocialLoginButton(
            buttonType: SocialLoginButtonType.google,
            onPressed: () => _signInWithGoogle(context),
          ),
          SizedBox(height: 8.0),
          SocialLoginButton(
            buttonType: SocialLoginButtonType.facebook,
            onPressed: () => _signInWithFacebook(context),
          ),
          SizedBox(height: 8.0),
          SocialLoginButton(
            buttonType: SocialLoginButtonType.generalLogin,
            onPressed: () => _signInWithEmail(context),
          ),
          SizedBox(height: 8.0),
          Text(
            "or",
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          SocialLoginButton(
            buttonType: SocialLoginButtonType.generalLogin,
            text: 'Go Anonymous',
            backgroundColor: Colors.lime[300],
            textColor: Colors.black,
            onPressed: () => _signInAnonymously(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    );
  }
}
