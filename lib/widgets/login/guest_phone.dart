import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../bottom_nav_guest.dart';
import '../../models/user.dart';

class TelephoneForm extends StatefulWidget {
  final Guest guest;

  TelephoneForm(this.guest);
  @override
  _TelephoneFormState createState() => _TelephoneFormState();
}

class _TelephoneFormState extends State<TelephoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool matched = false;
  String lastEight;
  String matchedNumber = '';

  String _subStringPhone(String phoneNumber) {
    if (phoneNumber.length >= 10) {
      lastEight = phoneNumber.substring(phoneNumber.length - 8);
    } else {
      lastEight = phoneNumber.toString();
    }
    return lastEight;
  }

  addGuest(Guest guest) async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    final String pathDB = "egyDb/";
    DatabaseReference databaseReference =
        database.reference().child('$pathDB/guest/en-US');
    databaseReference.child(widget.guest.phone).update(guest.toJson());
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Icon(
            Icons.warning,
            color: Colors.red,
            size: 60,
          ),
          content: new Center(
              heightFactor: 1,
              child: new Text(
                'غير مسموح بالدخول',
                textDirection: TextDirection.rtl,
              )),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new IconButton(
              icon: new Icon(
                Icons.cancel,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    print(widget.guest.phone.length);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintTextDirection: TextDirection.rtl,
                alignLabelWithHint: true,
                label: Center(
                  child: Text(
                    'رقم الهاتف',
                    textDirection: TextDirection.rtl,
                  ),
                ),
                hintStyle: TextStyle(
                    color: Color.fromARGB(255, 223, 216, 216),
                    fontStyle: FontStyle.italic,
                    fontSize: 15),
                hintText: 'مثال: 01234567890',
              ),
              controller: _controller,
              keyboardType: TextInputType.phone,
              validator: (value) {
                String errMsg = 'من فضلك أدخل رقم الهاتف ';
                String errInput = 'الرجاء إدخال رقم هاتف صحيح';
                String misMatch = 'رقم الهاتف غير مطابق';

                if (value == null || value.isEmpty) {
                  return errMsg;
                }
                final numericRegex = RegExp(r'^[0-9]+$');
                if (!numericRegex.hasMatch(value) || value.length < 9) {
                  return errInput;
                }
                if (!matched) {
                  return misMatch;
                }
                return null;
              },
            ),
            IconButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await model
                        .guestLogIn(context)
                        .whenComplete(() async => await addGuest(widget.guest))
                        .whenComplete(() async =>
                            await model.guestDetails(widget.guest.phone))
                        .then((value) {
                      if (value) {
                        _formKey.currentState.reset();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavGuest(
                                    '6',
                                    isAdmin: model.user.isAdmin,
                                    stores: model.user.stores,
                                    isGuest: true,
                                  )),
                        );
                      } else {
                        _showDialog();
                      }
                    });

                    //    Navigator.of(context).pop();

                    //

                    print('Telephone: ${_controller.text}');
                  }
                },
                icon: Icon(
                  Icons.check_circle_outline_outlined,
                  color: Colors.green,
                  size: 38,
                )),
          ],
        ),
      );
    });
  }
}
