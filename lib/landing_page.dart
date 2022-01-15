import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin_home.dart';
import 'package:tourism_recommendation_system/home/generic_home_page.dart';
import 'package:tourism_recommendation_system/home/homepage.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/sign_in/email_sign_in_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? EmailSignInPage() : MainHomePage();
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
