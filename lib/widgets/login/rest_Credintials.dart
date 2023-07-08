import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

import '../color_loader_2.dart';

class RestCredintials extends StatefulWidget {
  const RestCredintials({Key key}) : super(key: key);
  @override
  _RestCredintialsState createState() => _RestCredintialsState();
}

class _RestCredintialsState extends State<RestCredintials> {
  TextEditingController pwCntr = TextEditingController();

  String _pw = '';
  bool _isloading = false;
  bool _saveEnable = false;
  String _msg = '';
  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _showMaterialDialog(context, model);
    });
  }

  _showMaterialDialog(BuildContext context, MainModel model) {
    return ModalProgressHUD(
      inAsyncCall: _isloading,
      opacity: 0.6,
      progressIndicator: ColorLoader2(),
      child: SimpleDialog(
        title: Text(
          ' تحديث كلمة السر',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        children: <Widget>[
          SimpleDialogOption(
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(1),
                      child: TextField(
                        maxLength: 8,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLines: 1,
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: pwCntr,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: ' كلمة السر',
                        ),
                        onChanged: (text) {
                          setState(() {
                            _pw = text;
                            text.length >= 6
                                ? _saveEnable = true
                                : _saveEnable = false;
                            //you can access nameController in its scope to get
                            // the value of text entered as shown below
                            //fullName = nameController.text;
                          });
                        },
                      )),
                  Container(
                    margin: EdgeInsets.all(1),
                    child: Text(_pw),
                  ),
                ],
              ),
            ),
            onPressed: () {
              //_dismissDialog();
            },
          ),
          _saveEnable
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SimpleDialogOption(
                      onPressed: () async {
                        isloading(true);
                        await model
                            .emailSignIn(
                                model.firebaseUser.user.email, model.pw)
                            .whenComplete(
                          () {
                            print(model.firebaseUser.toString());
                            _msg =
                                model.updatePassword(model.firebaseUser, _pw);
                          },
                        ).whenComplete(
                          () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: ListTile(
                                title: Text(_msg),
                              ),
                              actions: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    model.signOut();
                                    //  SystemNavigator.pop();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/login', (_) => false);
                                  },
                                  icon: Icon(
                                    GroovinMaterialIcons.close_circle_outline,
                                    size: 38,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        isloading(false);
                      },
                      child: Icon(
                        Icons.check_circle_outline_outlined,
                        size: 39,
                        color: Colors.green,
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        model.fbItemsUpdateFromDb();
                        // _dismissDialog();
                      },
                      child: Icon(
                        GroovinMaterialIcons.close_circle_outline,
                        size: 38,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
