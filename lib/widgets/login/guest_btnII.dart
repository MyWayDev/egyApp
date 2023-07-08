import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/bottom_nav_guest.dart';
import 'package:mor_release/models/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:carrier_info/carrier_info.dart';
import 'dart:io' show Platform;
import '../../scoped/connected.dart';
import 'package:current_location/current_location.dart';

class GuestButton extends StatefulWidget {
  GuestButton({Key key}) : super(key: key);

  @override
  State<GuestButton> createState() => _GuestButtonState();
}

class _GuestButtonState extends State<GuestButton> {
  AndroidCarrierData _androidInfo;
  AndroidCarrierData get androidInfo => _androidInfo;
  set androidInfo(AndroidCarrierData carrierInfo) {
    setState(() => _androidInfo = carrierInfo);
  }

  String title =
      'للاستمرار في استخدام التطبيق برجاء' + 'الضغط في الشاشة التالية علي';
  String str = '-الاذونات'
      '١-الهاتف'
      '-سماح'
      '٢-الموقع'
      '-سماح'; // fix format before release;
  PermissionStatus _phonePermission;
  PermissionStatus _locationPermission;
  List<String> simList = [];

  Guest _guest = Guest(phone: [], location: '');

  Future<void> getLocation(Guest guest) async {
    await UserLocation.getValue().then((value) {
      guest.location = value.regionName;
      guest.phone = simList;
    });
  }

  Future<void> initPlatformState() async {
    simList.clear();

    // Ask for permissions before requesting data
    await [Permission.phone, Permission.location].request();

    _phonePermission = await Permission.phone.status;
    _locationPermission = await Permission.location.status;
    if (_phonePermission.isGranted == true &&
        _locationPermission.isGranted == true) {
      print('${_phonePermission.toString()} phoneInfo');
      print('${_locationPermission.toString()} locationInfo');
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        if (Platform.isAndroid)
          _androidInfo = await CarrierInfo.getAndroidInfo();
        // if (Platform.isIOS) iosInfo = await CarrierInfo.getIosInfo();
      } catch (e) {
        print(e.toString());
      }
      _androidInfo.subscriptionsInfo.forEach((t) {
        simList.add(t.phoneNumber);
        print('${t.phoneNumber} telephonyInfo');
      });
      // simList.add('+201021487211'); //delete before release;
      await getLocation(_guest);
    }
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
                    /*
                    await initPlatformState();
                    if (_phonePermission.isGranted == true &&
                        _locationPermission.isGranted == true) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('أدخل رقم الهاتف',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: 16)),
                            content: TelephoneForm(_guest),
                          );
                        },
                      );
                    } else {
                      showDialog(
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
                              ));
                    }*/
                    Navigator.pushNamed(context, '/otpApp');
                    //
                    /* Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PhoneInfo();
                  }));*/
                  }
                  // Navigator.pushNamed(context, '/registration'),
                  ),
            ),
          ],
        ),
      );
    });
  }
}
