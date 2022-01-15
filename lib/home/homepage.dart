import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
    );
  }

  void _showProfilePage(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => ChangeNotifierProvider<MyUser>(
          create: (_) => MyUser(
            email: auth.currentUser!.email,
            isAdmin: auth.isCurrentUserAdmin,
            name: auth.currentUser!.displayName,
          ),
          child: ProfilePage(),
        ),
      ),
    );
  }
}
