import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/screens/splash_screen.dart';
import '../utlis/globals.dart';
import '../utlis/route_generator.dart';

class OtpApp extends StatelessWidget {
  const OtpApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: Globals.scaffoldMessengerKey,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          brightness: Brightness.light,
          primaryColor: Colors.pink[900],
          accentColor: Colors.pinkAccent[700],
          backgroundColor: Colors.white70,
          buttonColor: Colors.pink[900],
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.pink,
          brightness: Brightness.light,
          primaryColor: Colors.pink[900],
          accentColor: Colors.pinkAccent[700],
          backgroundColor: Colors.white70,
          buttonColor: Colors.pink[900],
        ),
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: SplashScreen.id,
      ),
    );
  }
}
