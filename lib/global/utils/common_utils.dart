import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommonUtils {
  static String verify = "";

  static Future<String> firebasePhoneAuth(
      {String phone, BuildContext context}) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          print("Phone credentials $credential");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed $e");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Verification Failed! Try after some time.")));
        },
        codeSent: (String verificationId, int resendToken) async {
          String smsCode = 'xxxx';
          CommonUtils.verify = verificationId;
          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await FirebaseAuth.instance.signInWithCredential(credential);
          print("Verify: $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) async {},
      );
      return CommonUtils.verify;
    } catch (e) {
      print("Exception $e");
      return "";
    }
  }

  static Future<bool> firebaseSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
