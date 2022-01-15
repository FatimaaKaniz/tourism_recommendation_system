import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/homepage.dart';
import 'package:tourism_recommendation_system/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';

import '../services/auth_base.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home Page'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
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
