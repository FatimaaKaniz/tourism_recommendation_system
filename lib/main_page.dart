import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:tourism_recommendation_system/landing_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                    ),
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
}
