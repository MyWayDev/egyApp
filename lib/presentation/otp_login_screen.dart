import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mor_release/presentation/widget/border_box.dart';
import 'package:mor_release/presentation/widget/white_container.dart';

//import 'package:sms_autofill/sms_autofill.dart'; //*auto google policy

import '../global/utils/common_utils.dart';
import 'otp_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  static String verify = "";

  const OtpLoginScreen({Key key}) : super(key: key);

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _formOTPKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController();
  Color focusBorderColor = Colors.black12;
  Color underlineColor = Colors.grey.shade200;
  RegExp regExp = RegExp(r'^[0]?[6789]\d{9}$');
  RegExp countryRegExp = RegExp(r'^\+?(\d+)');
  bool divider = false;
  bool isLoaded = false;

  int validatePhone(String phone) {
    String pattern = r'^[0]?[6789]\d{9}$';
    RegExp regExp = RegExp(pattern);
    if (phone.isEmpty) {
      return 1;
    } else if (phone.length <= 11) {
      return 2;
    } else if (!regExp.hasMatch(phone)) {
      return 3;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        color: const Color(0xFF8C4A52),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: isLoaded ? Colors.white : const Color(0xFF8C4A52),
            body: isLoaded
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 50),
                                child: Container(
                                  height: 50,
                                )),
                            const SizedBox(
                              height: 25,
                            ),
                            WhiteContainer(
                                headerText: "Login",
                                labelText:
                                    "Please enter your 10 digit phone no to proceed",
                                child: BorderBox(
                                    margin: false,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    color: Colors.grey.shade200,
                                    height: 60,
                                    child: Form(
                                      key: _formOTPKey,
                                      child: Row(
                                        children: [
                                          BorderBox(
                                              height: 100,
                                              width: 55,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                              color: Colors.grey.shade200,
                                              margin: false,
                                              child: TextFormField(
                                                controller:
                                                    _countryCodeController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onChanged: (value) {
                                                  if (!countryRegExp
                                                      .hasMatch(value)) {
                                                    setState(() {
                                                      focusBorderColor =
                                                          Colors.red.shade900;
                                                      underlineColor =
                                                          focusBorderColor;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      focusBorderColor =
                                                          Colors.green.shade700;
                                                      underlineColor =
                                                          focusBorderColor;
                                                    });
                                                  }
                                                  if (value.length == 4) {
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "Code?";
                                                  } else if (!countryRegExp
                                                      .hasMatch(value)) {
                                                    return "Invalid";
                                                  }
                                                  return null;
                                                },
                                                style: const TextStyle(
                                                    fontSize: 19),
                                                keyboardType:
                                                    TextInputType.phone,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      4)
                                                ],
                                                decoration: InputDecoration(
                                                  hintText: "+91",
                                                  hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade400),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: underlineColor),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            focusBorderColor),
                                                  ),
                                                ),
                                              )),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 7.0),
                                            child: VerticalDivider(
                                              thickness: 2,
                                            ),
                                          ),
                                          BorderBox(
                                              height: 100,
                                              width: 250,
                                              color: Colors.grey.shade200,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                              margin: false,
                                              child: TextFormField(
                                                controller: _phoneController,
                                                validator: (value) {
                                                  int res =
                                                      validatePhone(value);
                                                  if (res == 1) {
                                                    return "Please enter number";
                                                  } else if (res == 2) {
                                                    return "Please enter 10 digits phone number";
                                                  } else if (res == 3) {
                                                    return "Please enter a valid 10 digits phone number";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: const TextStyle(
                                                    fontSize: 19),
                                                keyboardType:
                                                    TextInputType.phone,
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    FocusScope.of(context)
                                                        .previousFocus();
                                                  } else if (value.length ==
                                                      11) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  }
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      11),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "XXXXXXXXXX",
                                                    hintStyle: TextStyle(
                                                        color: Colors
                                                            .grey.shade400)),
                                              )),
                                        ],
                                      ),
                                    ))),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              color: Colors.white,
              child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoaded = true;
                    });
                    if (_formOTPKey.currentState.validate()) {
                      //     var appSignature = await SmsAutoFill()
                      //       .getAppSignature; //*auto google policy
                      OtpLoginScreen.verify =
                          await CommonUtils.firebasePhoneAuth(
                              phone: _countryCodeController.text +
                                  _phoneController.text,
                              context: context);
                      Future.delayed(const Duration(seconds: 3))
                          .whenComplete(() {
                        setState(() {
                          isLoaded = false;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                      phone: _countryCodeController.text +
                                          _phoneController.text)));
                        });
                      });
                    }
                  },
                  child: const BorderBox(
                    margin: false,
                    color: Color(0xFF8C4A52),
                    height: 50,
                    child: Text(
                      "Proceed",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )),
            ),
          ),
        ));
  }
}
