import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:tourism_recommendation_system/main_page.dart';
import 'package:tourism_recommendation_system/services/auth.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        title: 'Tourism Recommendation System',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: SplashScreenView(
          navigateRoute: MainPage(),
          duration: 5000,
          imageSize: 300,
          imageSrc: "resources/images/logo.png",
          text: "Tourism Recommendation",
          textType: TextType.ColorizeAnimationText,
          colors: [
            Colors.blue,
            Colors.red,
            Colors.brown,
            Colors.teal
          ],
          textStyle: TextStyle(
            fontSize: 30.0,
          ),
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }
}
