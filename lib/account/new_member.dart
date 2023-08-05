import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/pages/order/widgets/payment.dart';
import 'package:mor_release/pages/order/widgets/storeFloat.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:searchable_dropdown/searchable_dropdown.dart';

class Id {
  String id;
  Id({this.id});

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(id: json['id']);
  }
}

class NewMemberPage extends StatefulWidget {
  final bool isGuest;
  final MainModel model;
  const NewMemberPage(this.model, {Key key, this.isGuest = false})
      : super(key: key);

  //final List<Area> areas;
  // NewMemberPage(this.areas);

  @override
  State<StatefulWidget> createState() => _NewMemberPage();
}

//final FirebaseDatabase dataBase = FirebaseDatabase.instance;
@override
class _NewMemberPage extends State<NewMemberPage> {
  DateTime selected;
  String path = 'flamelink/environments/egyProduction/content/district/en-US/';
  FirebaseDatabase database = FirebaseDatabase.instance;
  TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> _newMemberFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> places = [];
  String selectedValue;
  String selectedItem;
  String placeValue;
  var areaSplit;
  var placeSplit;

  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _confirmPassword;

  @override
  void initState() {
    widget.isGuest ? guestSponsor(widget.model) : DoNothingAction();
    getPlaces();
    getAreas();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  _showDateTimePicker(String userId) async {
    selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    // locale: Locale('fr'));
    setState(() {});
  }

  //final model = MainModel();
  void getAreas() async {
    DataSnapshot snapshot = await database.reference().child(path).once();

    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    List<District> fbRegion = list.map((f) => District.json(f)).toList();

    if (snapshot.value != null) {
      for (var t in fbRegion) {
        String sValue = t.districtId + " " + t.name;
        items.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: const TextStyle(fontSize: 11),
              ),
              value: sValue),
        );
      }
    }
  }

  AreaPlace getplace(String id) {
    AreaPlace place;
    place = areaPlace.firstWhere((p) => p.shipmentPlace == id);
    if (kDebugMode) {
      print(
          'shipmentPlace:${place.shipmentPlace}:spName${place.spName}:areaId:${place.areaId}');
    }
    return place;
  }

  List<AreaPlace> areaPlace;
  void getPlaces() async {
    areaPlace = [];
    final response = await http.get(Uri.parse(
        'http://mywayegypt-api.azurewebsites.net/api/get_all_shipment_places/'));
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      areaPlace = _shipmentArea.map((s) => AreaPlace.json(s)).toList();
      //areaPlace.forEach((a) => print(a.spName));
    } else {
      areaPlace = [];
    }

    if (areaPlace.isNotEmpty) {
      for (var t in areaPlace) {
        String sValue = t.shipmentPlace + " " + t.spName;
        places.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: const TextStyle(fontSize: 12),
              ),
              value: sValue),
        );
      }
    }
  }

  final NewMember _newMemberForm = NewMember(
    sponsorId: null,
    familyName: null,
    name: null,
    personalId: null,
    birthDate: null,
    email: null,
    telephone: null,
    address: null,
    areaId: null,
    bankAccoutName: null,
    bankAccountNumber: null,
    taxNumber: null,
    serviceCenter: null,
  );

  Area stateValue;
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  String _phone = '';
  bool veri = false;
  //int _courier;
  User _nodeData;

  void resetVeri() {
    controller.clear();
    setState(() {
      veri = false;
      _isloading = false;
    });
  }

  Future<void> guestSponsor(MainModel model) async {
    isloading(true);

    controller.text = model.setSpotId;
    if (!veri) {
      veri = await model.leaderVerification(controller.text.padLeft(8, '0'));
      if (veri) {
        _nodeData = await model.nodeJson(controller.text.padLeft(8, '0'));
        _nodeData.distrId == '00000000'
            ? resetVeri()
            : controller.text = _nodeData.distrId + ' ' + _nodeData.name;
      } else {
        resetVeri();
      }
    } else {
      resetVeri();
    }
    _phone = _nodeData.phone;
    isloading(false);
  }

  bool validData;
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  bool validateAndSave(String userId, String sc, MainModel model) {
    final form = _newMemberFormKey.currentState;
    isloading(true);
    if (form.validate() &&
        selected != null &&
        selectedValue != null &&
        selectedItem != null) {
      _newMemberForm.birthDate =
          intl.DateFormat('yyyy-MM-dd').format(selected).toString();

      // _newMemberForm.areaId = getplace(placeSplit.first).areaId;
      _newMemberForm.serviceCenter = sc;
      setState(() {
        validData = true;
      });
      // isloading(true);
      if (kDebugMode) {
        print('valide entry $validData');
      }
      _newMemberFormKey.currentState.save();
      if (kDebugMode) {
        print('${_newMemberForm.sponsorId}:${_newMemberForm.birthDate}');
      }
      isloading(false);
      return true;
    }
    isloading(false);
    PaymentInfo(model, 'الرجاء ادجال جميع البيانات')
        .flushAction(context)
        .show(context);

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: null,
            label: StoreFloat(model),
            isExtended: true,
            elevation: 30,
            backgroundColor: Colors.transparent),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        resizeToAvoidBottomInset: false,
        body: ModalProgressHUD(
          child: Container(
            child: buildRegForm(context),
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }

  Widget buildRegForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: Form(
          key: _newMemberFormKey,
          child: ListView(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    primary: true,
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                                contentPadding: const EdgeInsets.only(left: 8),
                                leading: Icon(Icons.vpn_key,
                                    size: 25.0, color: Colors.pink[500]),
                                title: SingleChildScrollView(
                                    child: Column(
                                  children: [
                                    TextFormField(
                                      readOnly: widget.isGuest ? true : false,
                                      textAlign: TextAlign.center,
                                      controller: controller,
                                      enabled: !veri ? true : false,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        hintText: ' ادخل رقم العضو الراعى',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400]),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value.isEmpty
                                          ? 'Code is Empty !!'
                                          : RegExp('[0-9]').hasMatch(value)
                                              ? null
                                              : 'invalid code !!',
                                      onSaved: (_) {
                                        _newMemberForm.sponsorId =
                                            _nodeData.distrId;
                                      },
                                    ),
                                    widget.isGuest
                                        ? Text(
                                            '$_phone' +
                                                ' ' +
                                                'Sponsor phone Number',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Container(),
                                  ],
                                )),
                                trailing: IconButton(
                                  icon: !veri && controller.text.length > 0
                                      ? const Icon(
                                          Icons.check,
                                          size: 30.0,
                                          color: Colors.blue,
                                        )
                                      : controller.text.isNotEmpty &&
                                              !widget.isGuest
                                          ? const Icon(
                                              Icons.close,
                                              size: 28.0,
                                              color: Colors.grey,
                                            )
                                          : Container(),
                                  color: Colors.pink[900],
                                  onPressed: () async {
                                    isloading(true);
                                    if (!veri) {
                                      veri = await model.leaderVerification(
                                          controller.text.padLeft(8, '0'));
                                      if (veri) {
                                        _nodeData = await model.nodeJson(
                                            controller.text.padLeft(8, '0'));
                                        _nodeData.distrId == '00000000'
                                            ? resetVeri()
                                            : controller.text =
                                                _nodeData.distrId +
                                                    ' ' +
                                                    _nodeData.name;
                                      } else {
                                        resetVeri();
                                      }
                                    } else {
                                      resetVeri();
                                    }
                                    isloading(false);
                                  },
                                  splashColor: Colors.pink,
                                )),
                            ModalProgressHUD(
                                inAsyncCall: _loading,
                                opacity: 0.6,
                                progressIndicator: ColorLoader2(),
                                child: veri
                                    ? Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            ListTile(
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(model.settings.catCode,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .lightGreen[900],
                                                          fontSize: 15,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  _newMemberFormKey.currentState
                                                              .validate() &&
                                                          selectedItem !=
                                                              null &&
                                                          selectedValue != null
                                                      ? Row(
                                                          children: <Widget>[
                                                            Center(
                                                              child: TextButton(
                                                                  onPressed: widget
                                                                          .isGuest
                                                                      ? () async {
                                                                          String
                                                                              msg =
                                                                              '';
                                                                          if (validateAndSave(
                                                                              model.userInfo.distrId,
                                                                              model.setStoreId,
                                                                              model)) {
                                                                            await runGuestCode(model);
                                                                            mobileRegForm(context,
                                                                                model);

                                                                            //  _newMemberFormKey.currentState.reset();

                                                                            /*
                                                                      msg = await _saveNewMember(
                                                                          model
                                                                              .userInfo
                                                                              .distrId,
                                                                          model
                                                                              .docType,
                                                                          model
                                                                              .setStoreId);
                                                                                 showReview(
                                                                          context,
                                                                          msg);
                                                                  */ //! add to mobile registration dialog
                                                                          }

                                                                          //  s

                                                                          //_
                                                                        }
                                                                      : () async {
                                                                          String
                                                                              msg =
                                                                              '';
                                                                          msg = await _saveNewMember(
                                                                              model.userInfo.distrId,
                                                                              model.docType,
                                                                              model.setStoreId);
                                                                          showReview(
                                                                              context,
                                                                              msg);
                                                                        },
                                                                  child:
                                                                      const Icon(
                                                                    GroovinMaterialIcons
                                                                        .account_check,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 38,
                                                                  ),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    minimumSize:
                                                                        Size(80,
                                                                            34),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16),
                                                                    primary:
                                                                        Colors.greenAccent[
                                                                            700],
                                                                    onPrimary:
                                                                        Colors
                                                                            .black87,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                      side: const BorderSide(
                                                                          color:
                                                                              Colors.blueGrey),
                                                                    ),
                                                                    elevation:
                                                                        21,
                                                                  )),
                                                            ),
                                                          ],
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                              leading: RawMaterialButton(
                                                child: const Icon(
                                                  GroovinMaterialIcons
                                                      .calendar_check,
                                                  size: 24.0,
                                                  color: Colors.white,
                                                ),
                                                shape: const CircleBorder(),
                                                highlightColor:
                                                    Colors.pink[500],
                                                elevation: 8,
                                                fillColor: Colors.pink[500],
                                                onPressed: () {
                                                  _showDateTimePicker(
                                                      model.userInfo.distrId);
                                                },
                                                splashColor: Colors.pink[900],
                                              ),
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 30),
                                                child: selected != null
                                                    ? Text(intl.DateFormat(
                                                            'yyyy-MM-dd')
                                                        .format(selected)
                                                        .toString())
                                                    : const Text(''),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 1),
                                                child: selected == null
                                                    ? const Text(
                                                        'تاريخ الميلاد')
                                                    : const Text(''),
                                              ),

                                              //trailing:
                                            ),
                                            const Divider(
                                              height: 4,
                                              color: Colors.black,
                                            ),
                                            TextFormField(
                                              // autovalidate: true,
                                              decoration: InputDecoration(
                                                  labelText: 'اسم العضو',
                                                  contentPadding:
                                                      const EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                      GroovinMaterialIcons
                                                          .format_title,
                                                      color: Colors.pink[500])),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 8
                                                    ? _msg = 'أدخل أسم العضو'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.name = value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'الرقم القومي',
                                                  contentPadding:
                                                      const EdgeInsets.all(4.0),
                                                  icon: Icon(
                                                      Icons.assignment_ind,
                                                      color: Colors.pink[500])),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 10
                                                    ? _msg = 'أدخل الرقم القومي'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              autocorrect: true,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.personalId =
                                                    value;
                                              },
                                            ),
                                            TextFormField(
                                              initialValue: widget.isGuest
                                                  ? model.guestInfo.phone
                                                  : '',
                                              readOnly:
                                                  widget.isGuest ? true : false,
                                              decoration: InputDecoration(
                                                  labelText: 'رقم الهاتف',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      const EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    Icons.phone,
                                                    color: Colors.pink[500],
                                                  )),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 6
                                                    ? _msg = ' أدخل الهاتف'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: const TextInputType
                                                      .numberWithOptions(
                                                  signed: true),
                                              onSaved: (String value) {
                                                _newMemberForm.telephone =
                                                    value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'العنوان',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      const EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    GroovinMaterialIcons.home,
                                                    color: Colors.pink[500],
                                                  )),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 15
                                                    ? _msg = 'أدخل العنوان'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.address = value;
                                              },
                                            ),
                                            SizedBox(
                                              width: 300,
                                              child: Wrap(children: <Widget>[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(Icons.add_location,
                                                        color:
                                                            Colors.pink[500]),
                                                    SearchableDropdown(
                                                      hint:
                                                          const Text('المنطقه'),
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_circle,
                                                        color: Colors.pink[300],
                                                        size: 28,
                                                      ),
                                                      iconEnabledColor:
                                                          Colors.pink[200],
                                                      iconDisabledColor:
                                                          Colors.grey,
                                                      items: items,
                                                      value: selectedItem,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedItem = value;
                                                          areaSplit =
                                                              selectedItem
                                                                  .split('\ ');
                                                          _newMemberForm
                                                                  .areaId =
                                                              areaSplit.first;
                                                          if (kDebugMode) {
                                                            print(
                                                                'Areasplit:${_newMemberForm.areaId}');
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    model.docType == 'CR'
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    right: 3),
                                                            child: Icon(
                                                              Icons
                                                                  .local_shipping,
                                                              size: 24,
                                                              color: Colors
                                                                  .pink[500],
                                                            ),
                                                          )
                                                        : Container(),
                                                    model.docType == 'CR'
                                                        ? SearchableDropdown(
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_drop_down_circle,
                                                              color: Colors
                                                                  .pink[300],
                                                              size: 28,
                                                            ),

                                                            //style: TextStyle(fontSize: 12),
                                                            hint: const Text(
                                                                'شحن الي منطقه'),
                                                            iconEnabledColor:
                                                                Colors
                                                                    .pink[200],
                                                            iconDisabledColor:
                                                                Colors.grey,
                                                            items: places,
                                                            value:
                                                                selectedValue,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedValue =
                                                                    value;
                                                                placeSplit =
                                                                    selectedValue
                                                                        .split(
                                                                            '\ ');
                                                                if (kDebugMode) {
                                                                  print(placeSplit
                                                                      .first);
                                                                }
                                                              });
                                                            },
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ]),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()),
                          ]),
                    ),
                  )),
            ],
          ),
        ), //this line
      );
    });
  }

  String errorM = '';
  Future<String> _saveNewMember(String user, String docType, String storeId,
      {bool isGuest: false}) async {
    setState(() {
      _newMemberForm.email = _email;
    });
    if (kDebugMode) {
      print('docType:$docType:storeId:$storeId');
    }
    Id body;
    String msg = '';
    isloading(true);
    if (kDebugMode) {
      print(_newMemberForm.postNewMemberToJson(_newMemberForm));
    }

    Response response = !isGuest
        ? await _newMemberForm.createPost(
            _newMemberForm,
            user,
            getplace(placeSplit.first).shipmentPlace,
            _newMemberForm.areaId,
            getplace(placeSplit.first).spName,
            docType,
            storeId)
        : await _newMemberForm.createGuestPost(
            _newMemberForm,
            user,
            getplace(placeSplit.first).shipmentPlace,
            _newMemberForm.areaId,
            getplace(placeSplit.first).spName,
            docType,
            storeId);
    if (response.statusCode == 201) {
      body = Id.fromJson(json.decode(response.body));
      msg = body.id;
      if (kDebugMode) {
        print("body.id${body.id}");
      }
    } else {
      msg = "خطأ في حفظ البيانات";
    }
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (kDebugMode) {
      print(msg);
    }
    isloading(false);
    return msg;
  }

  Future<bool> mobileRegForm(BuildContext context, MainModel model) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /*  Container(
                      height: 40.0, // desired height
                      width: 120.0, // desired width
                      child: Image.asset(
                        'assets/images/mwlogo.png',
                        fit: BoxFit.cover,
                      ),
                    ),*/
                    Text(
                        'Membership id:${model.memberData.distrId}'), // Assuming your logo is named 'logo.png' and is in the 'assets' directory
                    SizedBox(height: 1),
                    Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            TextFormField(
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'الرجاء إدخال عنوان بريد إلكتروني';
                                } else if (!_isEmailValid(value)) {
                                  return 'الرجاء إدخال عنوان بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _email = value;
                              },
                            ),
                            TextFormField(
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                label: Text(
                                  'كلمة السر',
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value.isEmpty || value.length < 6) {
                                  return ' الرجاء إدخال كلمة السر لحد الأدنى 6 أحرف';
                                }
                                _password = value;
                                return null;
                              },
                              onSaved: (value) {
                                _password = value;
                              },
                            ),
                            TextFormField(
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'تأكيد كلمة السر',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'يرجى تأكيد كلمة السر';
                                } else if (value != _password) {
                                  return 'كلمات السر غير متطابقة';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _confirmPassword = value;
                              },
                            ),
                          ],
                        )),
                    SizedBox(height: 1.0),
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            await model
                                .regUserGuest(_email, _password)
                                .then((value) {
                              print('regUser Function Value:=>$value');
                              setState(() {
                                model.memberData.email = _email;
                              });
                            });
                            if (_email == model.memberData.email) {
                              model.userPushToFirebase(
                                  model.memberData.distrId, model.memberData);
                            } else {
                              print('email failed');
                            }
                            _formKey.currentState.reset();
                            model.logIn(
                                model.memberData.distrId, _password, context,
                                fromGuest: true);
                            /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavGuest(
                                      '6',
                                      isAdmin: model.user.isAdmin,
                                      stores: model.user.stores,
                                      isGuest: true,
                                    )),
                          );*/
                            //model.userPushToFirebase(, )

                            //  _newMemberFormKey.currentState.reset();

                            // await firebase_auth.FirebaseAuth.instance.signOut();
                            /* Navigator.of(context)
                                .pushReplacementNamed('/login');*/
                            //  model.logIn(user.distrId, _password, context);
                            /* .then((value) => value
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => BottomNav(
                                                  user.distrId,
                                                  isAdmin: model.user.isAdmin,
                                                  stores: model.user.stores,
                                                )),
                                      )
                                    : null);*/

                          }
                        },
                        child: Text('تسجيل')),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<bool> runGuestCode(MainModel model) async {
    String msg = '';
    bool done = false;

    await _saveNewMember(
            model.userInfo.distrId, model.docType, model.setStoreId,
            isGuest: widget.isGuest)
        .then((value) async {
      msg = value;
      if (value.length != 8) {
        showReview(context, value);
      } else {
        await model.memberJson(value);
        //  print('memberdata=>:${model.memberData.distrId}');
        // ignore: missing_return
//model.userPushToFirebase(msg, );

      }
    }).whenComplete((() async => setState(() {
                  done = true;
                }) // msg = await model.regUserGuest(_email, _password)
            ));

    return done;
  }

  Future<bool> showReview(BuildContext context, String msg) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Container(
              height: 110.0,
              width: 110.0,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'رقم العضويه: $msg',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.pink[900],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      _newMemberFormKey.currentState.reset();
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/bottomnav', (_) => false);
                    },
                    child: Container(
                      height: 35.0,
                      width: 35.0,
                      color: Colors.white,
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
