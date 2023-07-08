import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/screens/splash_screen.dart';
import '../utlis/globals.dart';
import '../utlis/route_generator.dart';
import '../utlis/spp_theme.dart';

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
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: SplashScreen.id,
      ),
    );
  }
}
