import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/view/home/common/main_home_page.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/view/sign_in/sign_in_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
   // FocusScope.of(context).unfocus();
    final auth = Provider.of<AuthBase>(context, listen: false);
    return authenticated
        ? StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? SignInForm.create(context) : MainHomePage();
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    )
        : Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("resources/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 180, 0, 20),
                    child: Text(
                      "Tourism Recommendation System",
                      style: GoogleFonts.permanentMarker(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5,
                          fontSize: 33,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText(
                          'Fuel Your Soul With Travel!',
                          textStyle: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        RotateAnimatedText(
                          'We’ve got it all for you!',
                          textStyle: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        RotateAnimatedText(
                          'Happiness Is Traveling!',
                          textStyle: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      repeatForever: true,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: SocialLoginButton(
                    buttonType: SocialLoginButtonType.generalLogin,
                    onPressed: () => authenticate(context),
                    text: 'Continue',
                    fontSize: 20,
                    borderRadius: 50,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  bool isAuthenticating = false;
  bool authenticated = false;
  bool localAuthEnabled = false;
  final localAuthPrefsKey = 'localAuthEnabled_TourismManagmentSystem_Fatima';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthBase>(context, listen: false);

    if (auth.currentUser != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        print(preferences.getBool(localAuthPrefsKey));
        setState(() {
          this.localAuthEnabled = preferences.containsKey(localAuthPrefsKey)
              ? preferences.getBool(localAuthPrefsKey) ?? false
              : false;
        });
      });
    }
  }

  Future<void> authenticate(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);

    if (auth.currentUser == null) {
      setState(() {
        this.authenticated = true;
      });
      return;
    }
    if (localAuthEnabled) {
      var authenticated = await auth.authenticateLocally();
      setState(() {
        this.authenticated = authenticated;
      });
      return;
    }
    setState(() {
      this.authenticated = true;
    });
    return;
  }
}
