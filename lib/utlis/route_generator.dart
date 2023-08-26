import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';

import '../screens/authentication_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/verify_phone_number_screen.dart';
import 'helpers.dart';

class RouteGenerator {
  static const _id = 'RouteGenerator';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    log(_id, msg: "Pushed ${settings.name}(${args ?? ''})");
    switch (settings.name) {
      case SplashScreen.id:
        return _route(const SplashScreen());
      case AuthenticationScreen.id:
        return _route(const AuthenticationScreen());
      case VerifyPhoneNumberScreen.id:
        return _route(VerifyPhoneNumberScreen(phoneNumber: args));
      case HomeScreen.id:
        return _route(const HomeScreen());
      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _route(Widget widget) =>
      MaterialPageRoute(builder: (context) => widget);

  static Route<dynamic> _errorRoute(String name) {
    return MaterialPageRoute(
      builder: (context) {
        // Check for the specific name that should trigger the pop action.
        if (name == '/otpApp') {
          Future.delayed(Duration(seconds: 1), () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
        }

        // Return a scaffold with the error message, and it will be displayed for 2 seconds.
        return Scaffold(
          body: Center(
            child: Text(
              'سوف يتم توجيهك إلى صفحة تسجيل الدخول، يرجى الانتظار',
              textDirection: TextDirection.rtl,
            ),
            //Text('ROUTE \n\n$name\n\nNOT FOUND'),
          ),
        );
      },
    );
  }
}
