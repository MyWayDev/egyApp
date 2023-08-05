import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

import '../bottom_nav_guest.dart';
import '../pages/user/login_screen.dart';
import '../utlis/globals.dart';
import '../widgets/otpLoader.dart';
import 'authentication_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const id = 'SplashScreen';

  const SplashScreen({Key key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final MainModel model = MainModel();
  @override
  void initState() {
    (() async {
      await Future.delayed(Duration.zero);
      final isLoggedIn = Globals.firebaseUser != null;

      if (!mounted) return;
      isLoggedIn
          ? FirebasePhoneAuthHandler.signOut(context)
              .whenComplete(() => Navigator.pushReplacementNamed(
                    context,
                    AuthenticationScreen.id,
                  ))
          : Navigator.pushReplacementNamed(
              context,
              AuthenticationScreen.id,
            );
    })();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: CustomLoader(),
      ),
    );
  }
}
