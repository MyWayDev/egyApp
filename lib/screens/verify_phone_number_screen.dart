import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:telephony/telephony.dart';
import '../bottom_nav_guest.dart';
import '../models/user.dart';
import '../pages/user/login_screen.dart';
import '../scoped/connected.dart';
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
  OtpFieldController otpbox = OtpFieldController(); //!smslistener
  Telephony telephony = Telephony.instance; //!smslistener
  StreamSubscription<Event> subscription;
  Guest newGuest;

  final FirebaseAuth auth = FirebaseAuth.instance;
  ScrollController scrollController;
  /* _getSignature() async {
    final String signature = await SmsAutoFill().getAppSignature;
    print("Signature: $signature");
  }*/

  /*_listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }*/ //!deprecated smslistner

  @override
  void initState() {
    //! smslistener ..
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print(message.address); //+977981******67, sender nubmer
        print(message.body); //Your OTP code is 34567
        print(message.date); //1659690242000, timestamp

        String sms = message.body.toString(); //get the message

        if (message.address == "CloudOTP") {
          //verify SMS is sent for OTP with sender number
          String otpcode = sms.replaceAll(new RegExp(r'[^0-9]'), '');
          //prase code from the OTP sms
          otpbox.set(otpcode.split(""));
          //split otp code to list of number
          //and populate to otb boxes

          setState(() {
            //refresh UI
          });
        } else {}
      },
      listenInBackground: false,
    );
    //! smslistener;
    //  _getSignature();
    // _listenSmsCode(); //! deprecated smslistner
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    DatabaseReference guestRef = FirebaseDatabase.instance
        .reference()
        .child('egyDb/guest/en-US')
        .child(_telephone());

    subscription = guestRef.onValue.listen((Event event) {
      newGuest = Guest.fromSnapshot(event.snapshot);
      //print('Data updated: ${widget.model.guestInfo.toJson()}');
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    SmsAutoFill().unregisterListener();
    subscription?.cancel();
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

  bool newGuestToModel(MainModel model) {
    model.guestInfo = newGuest;
    return true;
  }

  String _telephone() {
    return widget.phoneNumber.replaceAll("+", "");
  }

  Guest _guest;
  Guest _guestModel(String _token) {
    _guest = Guest(
        phone: _telephone(),
        stamp: DateTime.now().toString(),
        token: _token,
        isAllowed: false);
    return _guest;
  }

  Future<bool> addGuest(Guest guest) async {
    try {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final String pathDB = "egyDb/";
      DatabaseReference databaseReference =
          database.reference().child('$pathDB/guest/en-US');
      await databaseReference.child(_telephone()).set(guest.toJson());

      return true; // Return true on success
    } catch (e) {
      print('Failed to add guest: $e');
      return false; // Return false on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SafeArea(
        child: FirebasePhoneAuthHandler(
          phoneNumber: widget.phoneNumber,
          signOutOnSuccessfulVerification: false,

          //sendOtpOnInitialize: true,
          linkWithExistingUser: false,
          autoRetrievalTimeOutDuration: const Duration(seconds: 90),
          otpExpirationDuration: const Duration(seconds: 90),
          onCodeSent: () {
            log(VerifyPhoneNumberScreen.id, msg: 'تم إرسال رسالة ');
          },
          onLoginSuccess: (userCredential, autoVerified) async {
            String _uid = userCredential.user?.uid;
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
            await FirebasePhoneAuthHandler.signOut(context).then((_) async =>
                await addGuest(_guestModel(_uid)).then((value) async => value
                    ? newGuestToModel(model)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavGuest(
                                      '6',
                                      isAdmin: model.user.isAdmin,
                                      stores: model.user.stores,
                                      isGuest: true,
                                    )),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          )
                    : print('notlog')));

            /* await FirebasePhoneAuthHandler.signOut(context).then(
                (value) async => await model
                    .guestLogIn(context)
                    .whenComplete(() async => await addGuest(_guestModel(_uid)))
                    .then((value) async => !value
                        ? DoNothingAction()
                        : await model.guestDetails(_telephone()))
                    .whenComplete(() => model.guestInfo.phone == _telephone()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavGuest(
                                      '6',
                                      isAdmin: model.user.isAdmin,
                                      stores: model.user.stores,
                                      isGuest: true,
                                    )),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          )));*/

            /* Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.id,
              (route) => false,
            );*/
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
                showSnackBar('خطأ في التحقق');
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
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 18),
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
                        Center(
                          child: Text(
                            "تم إرسال رسالة نصية قصيرة تحتوي على رمز التحقق",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontSize: 18),
                          ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        //const SizedBox(height: 15),
                        /* const Center(
                          child: Text(
                            'أدخل رمز التحقق',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),*/
                        // const SizedBox(height: 15),
                        Container(
                            padding:
                                EdgeInsets.only(top: 50, left: 20, right: 20),
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OTPTextField(
                                  controller: otpbox,
                                  length: 6,
                                  width: MediaQuery.of(context).size.width,
                                  fieldWidth: 50,
                                  style: TextStyle(fontSize: 17),
                                  textFieldAlignment:
                                      MainAxisAlignment.spaceAround,
                                  fieldStyle: FieldStyle.box,
                                  onCompleted: (pin) async {
                                    print("Entered OTP Code: $pin");

                                    await controller.verifyOtp(pin);
                                  },
                                ),
                              ],
                            )),
                        //! Deprecated smslistner ..
                        /*  PinFieldAutoFill(
                            currentCode: otpCode,
                            codeLength: 6,
                            autoFocus: true,
                            decoration: UnderlineDecoration(
                              lineHeight: 2,
                              lineStrokeCap: StrokeCap.square,
                              bgColorBuilder: PinListenColorBuilder(
                                  Color.fromARGB(255, 8, 192, 35),
                                  Colors.grey.shade200),
                              colorBuilder:
                                  const FixedColorBuilder(Colors.black),
                            )),*/
                        //! Deprecated smslistner;
                        /* PinInputField(
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
                        ),*/
                      ],
                    ),
            );
          },
        ),
      );
    });
  }
}
