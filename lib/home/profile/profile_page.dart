import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/custom_packages/avatar.dart';
import 'package:tourism_recommendation_system/custom_packages/widgets/dialogs/alert_dialogs.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

class ProfilePage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    if (await showQuestionAlertDialog(
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
    final auth = Provider.of<AuthBase>(context, listen: false);
    final user = Provider.of<MyUser>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          TextButton(
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        bottom:  PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: _buildUserInfo(auth.currentUser!, user),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      if (!user.isNameEditAble) ...<Widget>[
                        SizedBox(
                          width: 250,
                          child: Text(
                            user.name ?? "",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                      ] else ...<Widget>[
                        SizedBox(
                          height: 50,
                          width: 230,
                          child: TextFormField(
                            initialValue: user.name ?? "",
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              errorText: user.name?.trim() == ""
                                  ? "Name can't be empty!"
                                  : null,
                            ),
                            autocorrect: false,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.name,
                            keyboardAppearance: Brightness.light,
                            onChanged: user.updateName,
                          ),
                        )
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: IconButton(
                        icon: user.isNameEditAble
                            ? Icon(
                                Icons.check,
                                color: user.canNameSubmit
                                    ? Colors.teal
                                    : Colors.grey,
                              )
                            : Icon(Icons.edit),
                        color: Colors.teal,
                        onPressed: () {
                          if (user.isNameEditAble) {
                            if (user.canNameSubmit) {
                              user.updateWith(
                                  isNameEditAble: !user.isNameEditAble);
                              auth.currentUser!.updateDisplayName(user.name);
                            }
                          } else {
                            user.updateWith(
                                isNameEditAble: !user.isNameEditAble);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(
                    Icons.email_rounded,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        user.email!,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User firebaseUser, MyUser user) {
    return Column(
      children: <Widget>[
        Avatar(
          photoUrl: firebaseUser.photoURL,
          radius: 50,
        ),
        SizedBox(height: 8),
        if (user.name != null)
          Text(
            user.name!,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
