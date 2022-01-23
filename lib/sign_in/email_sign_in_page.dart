import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/sign_in/email_sign_in_form.dart';

class EmailSignInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  child: EmailSignInForm.create(context),
                ),
              ),
            ],
          ),
        ),
      ),
      //backgroundColor: Colors.grey[200],
    );
  }
}
