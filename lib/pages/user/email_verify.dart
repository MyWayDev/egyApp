/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({Key key}) : super(key: key);

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  TextEditingController _contrl = new TextEditingController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  bool _isloading = false;
  int _messageCount = 0;

  String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<void> sendPushMessage(_token) async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  bool _validChange = false;
  String _newEmail = '';
  bool _changed(bool i) {
    return i;
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('AppBar Demo'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Show Snackbar',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar')));
              },
            ),
            /*
            IconButton(
              icon: const Icon(Icons.navigate_next),
              tooltip: 'Go to the next page',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Next page'),
                      ),
                      body: const Center(
                        child: Text(
                          'This is the next page',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ));
              },
            ),
            */
          ],
        ),
        body: ModalProgressHUD(
          child: Container(
            child: buildForm(context),
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }

  bool validChange(bool changed) {
    final form = _emailFormKey.currentState;
    setState(() {
      _validChange = _changed(changed) && form.validate() ? true : false;
    });
    return _validChange;
  }

  bool validateAndSave() {
    final form = _emailFormKey.currentState;
    if (form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('valid'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget buildForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
          ),
          Form(
            key: _emailFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    expands: false,
                    decoration: InputDecoration(
                        labelText: 'البريد',
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(12.0),
                        icon: Icon(
                          Icons.email,
                          color: Colors.pink[500],
                        )),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: model.user.email,
                    validator: (value) => EmailValidator.validate(value)
                        ? null
                        : "Please enter a valid email",
                    onChanged: (value) {
                      validChange(true);
                    },
                    onSaved: (value) {
                      setState(() {
                        _newEmail = value;
                      });

                      print('newEmail=>$_newEmail');
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
          ),
          _validChange
              ? ElevatedButton.icon(
                  autofocus: true,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    onSurface: Colors.amber,
                    shadowColor: Colors.black,
                    primary: Colors.green, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () async {
                    _emailFormKey.currentState.save();
                    print(model.user.token);
                    //model.updateEm(_newEmail);
                    //  final _msg = await model.verifyEmail(_newEmail);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(''),
                      backgroundColor: Colors.green,
                    ));
                  },
                  icon: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32.0,
                    ),
                  ),
                  label: Text(''))
              : Container()
        ],
      ));
    });
  }
}*/
