import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../utlis/helpers.dart';
import '../widgets/otpLoader.dart';
import '../widgets/pinPointField.dart';
import 'home_screen.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  static const id = 'VerifyPhoneNumberScreen';

  final String phoneNumber;

  const VerifyPhoneNumberScreen({
    Key key,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen>
    with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  String otpCode = "";
  String otp = "";
  bool isLoaded = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  ScrollController scrollController;
  /* _getSignature() async {
    final String signature = await SmsAutoFill().getAppSignature;
    print("Signature: $signature");
  }*/

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void initState() {
    //  _getSignature();
    _listenSmsCode();
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = WidgetsBinding.instance.window.viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  // scroll to bottom of screen, when pin input field is in focus.
  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber,
        signOutOnSuccessfulVerification: false,

        //sendOtpOnInitialize: true,
        linkWithExistingUser: false,
        autoRetrievalTimeOutDuration: const Duration(seconds: 90),
        otpExpirationDuration: const Duration(seconds: 90),
        onCodeSent: () {
          log(VerifyPhoneNumberScreen.id, msg: 'OTP sent!');
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          log(
            VerifyPhoneNumberScreen.id,
            msg: autoVerified
                ? 'تم استلام كلمة المرور تلقائياً'
                : 'تم التحقق من كلمة المرور ',
          );

          showSnackBar('تم التحقق من رقم الهاتف بنجاح');

          log(
            VerifyPhoneNumberScreen.id,
            msg: 'تسجيل الدخول ناجح:: ${userCredential.user?.uid}',
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeScreen.id,
            (route) => false,
          );
        },
        onLoginFailed: (authException, stackTrace) {
          log(
            VerifyPhoneNumberScreen.id,
            msg: authException.message,
            error: authException,
            stackTrace: stackTrace,
          );

          switch (authException.code) {
            case 'invalid-phone-number':
              // invalid phone number
              return showSnackBar('رقم الهاتف غير صحيح');
            case 'invalid-verification-code':
              // invalid otp entered
              return showSnackBar('الرمز المدخل غير صحيح');
            // handle other error codes
            default:
              showSnackBar('Something went wrong!');
            // handle error further if needed
          }
        },
        onError: (error, stackTrace) {
          log(
            VerifyPhoneNumberScreen.id,
            error: error,
            stackTrace: stackTrace,
          );

          showSnackBar('حدث خطأ');
        },
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              title: const Text(
                'تأكيد رقم الهاتف',
                textDirection: TextDirection.rtl,
              ),
              actions: [
                if (controller.codeSent)
                  TextButton(
                    onPressed: controller.isOtpExpired
                        ? () async {
                            log(VerifyPhoneNumberScreen.id,
                                msg: 'إعادة إرسال رمز التحقق');
                            await controller.sendOTP();
                          }
                        : null,
                    child: Text(
                      controller.isOtpExpired
                          ? 'إعادة إرسال'
                          : '${controller.otpExpirationTimeLeft.inSeconds}s',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                const SizedBox(width: 5),
              ],
            ),
            body: controller.isSendingCode
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CustomLoader(),
                      SizedBox(height: 50),
                      Center(
                        child: Text(
                          'إرسال رمز التحقق',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    controller: scrollController,
                    children: [
                      Text(
                        "تم إرسال رسالة نصية قصيرة تحتوي على رمز التحقق ${widget.phoneNumber}",
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      if (controller.isListeningForOtpAutoRetrieve)
                        Column(
                          children: const [
                            CustomLoader(),
                            SizedBox(height: 50),
                            Text(
                              'في انتظار رمز التحقق',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(),
                            Text('أو',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center),
                            Divider(),
                          ],
                        ),
                      const SizedBox(height: 15),
                      const Text(
                        'أدخل رمز التحقق',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      PinFieldAutoFill(
                          currentCode: otpCode,
                          codeLength: 6,
                          autoFocus: true,
                          decoration: UnderlineDecoration(
                            lineHeight: 2,
                            lineStrokeCap: StrokeCap.square,
                            bgColorBuilder: PinListenColorBuilder(
                                Colors.green.shade200, Colors.grey.shade200),
                            colorBuilder:
                                const FixedColorBuilder(Colors.transparent),
                          )),
                      PinInputField(
                        length: 6,
                        onFocusChange: (hasFocus) async {
                          if (hasFocus) await _scrollToBottomOnKeyboardOpen();
                        },
                        onSubmit: (enteredOtp) async {
                          final verified =
                              await controller.verifyOtp(enteredOtp);
                          if (verified) {
                            // number verify success
                            // will call onLoginSuccess handler
                          } else {
                            // phone verification failed
                            // will call onLoginFailed or onError callbacks with the error
                          }
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
