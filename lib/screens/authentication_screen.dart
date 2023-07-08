import 'package:easy_container/easy_container.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mor_release/screens/verify_phone_number_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../utlis/helpers.dart';

class AuthenticationScreen extends StatefulWidget {
  static const id = 'AuthenticationScreen';

  const AuthenticationScreen({
    Key key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String phoneNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "سنرسل رسالة نصية تحتوي على رمز التحقق",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              EasyContainer(
                elevation: 0,
                borderRadius: 10,
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: IntlPhoneField(
                    autofocus: true,
                    invalidNumberMessage: 'رقم الهاتف غير صالح',
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 21),
                    onChanged: (phone) => phoneNumber = phone.completeNumber,
                    initialCountryCode: 'EG',
                    flagsButtonPadding: const EdgeInsets.only(right: 10),
                    showDropdownIcon: false,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              IconButton(
                onPressed: () async {
                  if (isNullOrBlank(phoneNumber) ||
                      !_formKey.currentState.validate()) {
                    showSnackBar('يرجى إدخال رقم هاتف صحيح');
                  } else {
                    var appSignature = await SmsAutoFill().getAppSignature;
                    Navigator.pushNamed(
                      context,
                      VerifyPhoneNumberScreen.id,
                      arguments: phoneNumber,
                    );
                    print("App Signature : $appSignature");
                  }
                },
                icon: Icon(
                  GroovinMaterialIcons.check_circle_outline,
                  size: 68.0,
                  color: Colors.green,
                ),
              ),
              /* EasyContainer(
                width: double.infinity,
                onTap: () async {
                  if (isNullOrBlank(phoneNumber) ||
                      !_formKey.currentState.validate()) {
                    showSnackBar('Please enter a valid phone number!');
                  } else {
                    Navigator.pushNamed(
                      context,
                      VerifyPhoneNumberScreen.id,
                      arguments: phoneNumber,
                    );
                  }
                },
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 18),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
