import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/bottom_nav_guest.dart';
import 'package:mor_release/models/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io' show Platform;
import '../../scoped/connected.dart';

class GuestButton extends StatefulWidget {
  final Guest guest;
  GuestButton(this.guest, {Key key}) : super(key: key);

  @override
  State<GuestButton> createState() => _GuestButtonState();
}

class _GuestButtonState extends State<GuestButton> {
  String title =
      'للاستمرار في استخدام التطبيق برجاء' + 'الضغط في الشاشة التالية علي';
  String str = '-الاذونات'
      '١-الهاتف'
      '-سماح'
      '٢-الموقع'
      '-سماح'; // fix format before release;

  PermissionStatus _smsPermission;
  Future<bool> initPlatformState() async {
    //simList.clear();

    // Ask for permissions before requesting data
    await [Permission.sms]
        .request()
        .whenComplete(() async => _smsPermission = await Permission.sms.status)
        .whenComplete(() => print('${_smsPermission.toString()} smsInfo'));

    return _smsPermission.isGranted;
  }

  bool _verified;
  @override
  void initState() {
    if (widget.guest == null) {
      _verified = false;
    } else {
      _verified = widget.guest.isAllowed;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        margin: const EdgeInsets.only(top: 12.0),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(88, 36),
                    maximumSize: Size(99, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPrimary: Theme.of(context).primaryColor,
                    primary: Color.fromARGB(222, 184, 173, 222),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "       ضيف",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Icon(
                        GroovinMaterialIcons.account_group,
                        size: 36.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  onPressed: () async {
                    /* ?/* showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              actions: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    openAppSettings();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                              title: Text(
                                '$title',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.visible,
                              ),
                              content: Text(
                                '$str',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          )*/
                        :*/
                    // await initPlatformState().then((value) => !value
                    _verified
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
                        : Navigator.pushNamed(context, '/otpApp'); //);

                    //
                    /* Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PhoneInfo();
                  }));*/
                  }),
            ),
          ],
        ),
      );
    });
  }
}
