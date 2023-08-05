import 'package:flutter/material.dart';
import 'package:mor_release/presentation/otp_login_screen.dart';
import '../global/utils/common_utils.dart';

class OtpHomeScreen extends StatefulWidget {
  const OtpHomeScreen({Key key}) : super(key: key);

  @override
  State<OtpHomeScreen> createState() => _OtpHomeScreenState();
}

class _OtpHomeScreenState extends State<OtpHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF0),
      appBar: AppBar(
        title: const Text("Welcome"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8C4A52),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome user",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
            ),
            const SizedBox(
              height: 60,
            ),
            GestureDetector(
              onTap: () async {
                await CommonUtils.firebaseSignOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Log out successfully!"),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtpLoginScreen(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                width: MediaQuery.of(context).size.width * 0.4,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFF8C4A52),
                ),
                child: const Center(
                  child: Text(
                    "Sign Out",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
