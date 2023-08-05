import 'package:easy_container/easy_container.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/screens/verify_phone_number_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../bottom_nav_guest.dart';
import '../scoped/connected.dart';
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
  bool activeGuest;
  Guest guest;
  final _formKey = GlobalKey<FormState>();
  final String pathDB = "egyDb/";
  String _telephone() {
    return phoneNumber.replaceAll("+", "");
  }

  Future<Guest> guestDetails(String key) async {
    final DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('egyDb/guest/en-US')
        .child(key)
        .once();
    guest = Guest.fromSnapshot(snapshot);
    print('guest key:$key');
    return guest;
  }

  Future<bool> _activeGuest(MainModel model) async {
    guest = await model.guestDetails(_telephone());
    model.guestInfo = guest;

    return guest.isAllowed;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
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
                  style: TextStyle(fontSize: 15),
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
                ClipOval(
                  child: Material(
                    color: Colors.white, // Button color
                    child: InkWell(
                      splashColor: Colors.red, // Ink splash color
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(
                          GroovinMaterialIcons.check_circle_outline,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                      onTap: () async {
                        if (isNullOrBlank(phoneNumber) ||
                            !_formKey.currentState.validate()) {
                          showSnackBar('يرجى إدخال رقم هاتف صحيح');
                        } else {
                          var appSignature =
                              await SmsAutoFill().getAppSignature;
                          await model.guestLogIn(context).whenComplete(
                              () async => await _activeGuest(model)
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
                                  : model
                                      .signOut()
                                      .whenComplete(() => Navigator.pushNamed(
                                            context,
                                            VerifyPhoneNumberScreen.id,
                                            arguments: phoneNumber,
                                          )));

                          //get firebase guest data and match phone number if exists

                          print("App Signature : $appSignature");
                        }
                      },
                    ),
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
    });
  }
}
