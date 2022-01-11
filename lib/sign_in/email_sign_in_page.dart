import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/sign_in/email_sign_in_form.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Sign In'),
        elevation: 2.0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  child: EmailSignInFormChangeNotifier.create(context),
                ),
              ),
            ),
          ],
        ),
      ),
      //backgroundColor: Colors.grey[200],
    );
  }
}
