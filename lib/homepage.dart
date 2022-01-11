import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/custom_widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    if (await showAlertDialog(
            context: context,
            title: 'Logout',
            content: 'Are you Sure that you want to Logout?',
            defaultActionText: 'Yes',
            cancelActionText: 'No') ==
        true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }
}
