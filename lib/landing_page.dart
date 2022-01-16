import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourism_recommendation_system/home/admin/admin_home.dart';
import 'package:tourism_recommendation_system/home/generic_home_page.dart';
import 'package:tourism_recommendation_system/home/homepage.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';
import 'package:tourism_recommendation_system/sign_in/email_sign_in_page.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key? key}) : super(key: key);
  final currentUserAdminSharedPref =
      "isCurrentuserAdmin_tourismManagementSystem";
  bool isTrue = true;

  Future<void> setIsAdmin(String email, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final auth = Provider.of<AuthBase>(context, listen: false);
    bool? isAdmin = prefs.getBool(currentUserAdminSharedPref);
    if (isAdmin != null) {
      auth.setCurrentUserAdmin(isAdmin);
    } else {
      isTrue = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.currentUser != null) setIsAdmin(auth.currentUser!.email!, context);


    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null || !isTrue ? EmailSignInPage() : MainHomePage();
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
