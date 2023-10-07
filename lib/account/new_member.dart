import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
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

import '../bottom_nav.dart';
import '../bottom_nav_guest.dart';

class Id {
  int code;
  String id;
  String err;

  Id({this.code, this.id, this.err});

  factory Id.fromJson(Map<String, dynamic> json, [int statusCode]) {
    if (json == null) return Id();

    return Id(
      code: statusCode ?? json['code'] is int ? json['code'] : null,
      id: json['id'] is String ? json['id'] : null,
      err: json['errMsg'] is String ? json['errMsg'] : null,
    );
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
  final _formMKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _confirmPassword;
  String testPhone;
  bool _btnView = false;

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

  void isbtnView(bool b) {
    setState(() {
      _btnView = b;
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
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: null,
            label: Container(
              child: Center(
                child: StoreFloat(model),
              ),
              height: 48,
            ),
            isExtended: true,
            elevation: 30,
            backgroundColor: Colors.transparent),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
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
      return Form(
        key: _newMemberFormKey,
        child: ListView(
          children: <Widget>[
            Container(
              width: 200,
              padding: const EdgeInsets.only(bottom: 1.0),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 1.0),
                          leading: Icon(Icons.vpn_key,
                              size: 20.0, color: Colors.pink[500]),
                          title: Column(
                            children: [
                              TextFormField(
                                readOnly: widget.isGuest ? true : false,
                                textAlign: TextAlign.center,
                                controller: controller,
                                enabled: !veri ? true : false,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  helperStyle: TextStyle(fontSize: 12),
                                  labelStyle: TextStyle(fontSize: 12),
                                  hintText: ' ادخل رقم العضو الراعى',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value.isEmpty
                                    ? 'Code is Empty !!'
                                    : RegExp('[0-9]').hasMatch(value)
                                        ? null
                                        : 'invalid code !!',
                                onSaved: (_) {
                                  _newMemberForm.sponsorId = _nodeData.distrId;
                                },
                              ),
                              widget.isGuest
                                  ? Text(
                                      '$_phone' + ' ' + 'رقم هاتف الراعي',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Container(),
                            ],
                          ),
                          trailing: IconButton(
                            icon: !veri && controller.text.length > 0
                                ? const Icon(
                                    Icons.check,
                                    size: 30.0,
                                    color: Colors.blue,
                                  )
                                : controller.text.isNotEmpty && !widget.isGuest
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
                                      : controller.text = _nodeData.distrId +
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
                                  child: KeyboardAvoider(
                                    focusPadding: 12,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              height: 35,
                                              child: ListTile(
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(model.settings.catCode,
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .lightGreen[
                                                                900],
                                                            fontSize: 15,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    _newMemberFormKey
                                                                .currentState
                                                                .validate() &&
                                                            selectedItem !=
                                                                null &&
                                                            selectedValue !=
                                                                null
                                                        ? Row(
                                                            children: <Widget>[
                                                              Center(
                                                                child:
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (validateAndSave(
                                                                              model.userInfo.distrId,
                                                                              model.setStoreId,
                                                                              model)) {
                                                                            await _saveNewMember(model.userInfo.distrId, model.docType, model.setStoreId, isGuest: widget.isGuest).then((body) async =>
                                                                                {
                                                                                  print('${body.code}' + '${body.err}'),
                                                                                  showReview(context, body)
                                                                                });
                                                                            // await runGuestCode(model); /*.then((value) => mobileRegForm(context, model));*/
                                                                          }
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          GroovinMaterialIcons
                                                                              .account_check,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              38,
                                                                        ),
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          minimumSize: Size(
                                                                              80,
                                                                              34),
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 16),
                                                                          primary:
                                                                              Colors.greenAccent[700],
                                                                          onPrimary:
                                                                              Colors.black87,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(24.0),
                                                                            side:
                                                                                const BorderSide(color: Colors.blueGrey),
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
                                                leading: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8, left: 35),
                                                    child: RawMaterialButton(
                                                      child: const Icon(
                                                        GroovinMaterialIcons
                                                            .calendar_check,
                                                        size: 20.0,
                                                        color: Colors.white,
                                                      ),
                                                      shape:
                                                          const CircleBorder(),
                                                      highlightColor:
                                                          Colors.pink[500],
                                                      elevation: 8,
                                                      fillColor:
                                                          Colors.pink[500],
                                                      onPressed: () {
                                                        _showDateTimePicker(
                                                            model.userInfo
                                                                .distrId);
                                                      },
                                                      splashColor:
                                                          Colors.pink[900],
                                                    )),

                                                title: selected != null
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 2,
                                                                right: 8),
                                                        child: Text(
                                                          intl.DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(selected)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        ))
                                                    : const Text(''),

                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 15,
                                                          right: 10),
                                                  child: selected == null
                                                      ? const Text(
                                                          'تاريخ الميلاد',
                                                          style: TextStyle(
                                                              fontSize: 12))
                                                      : const Text(''),
                                                ),

                                                //trailing:
                                              )),
                                          Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  // autovalidate: true,
                                                  decoration: InputDecoration(
                                                      helperStyle: TextStyle(
                                                          fontSize: 12),
                                                      labelStyle: TextStyle(
                                                          fontSize: 12),
                                                      labelText: 'اسم العضو',
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 1.0),
                                                      icon: Icon(
                                                          GroovinMaterialIcons
                                                              .format_title,
                                                          size: 20,
                                                          color: Colors
                                                              .pink[500])),
                                                  validator: (value) {
                                                    String _msg;
                                                    value.length < 8
                                                        ? _msg =
                                                            'أدخل أسم العضو'
                                                        : _msg = null;
                                                    return _msg;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  onSaved: (String value) {
                                                    _newMemberForm.name = value;
                                                  },
                                                ),
                                                TextFormField(
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  // autovalidate: true,
                                                  decoration: InputDecoration(
                                                    helperStyle:
                                                        TextStyle(fontSize: 12),
                                                    labelStyle:
                                                        TextStyle(fontSize: 12),
                                                    labelText: 'الرقم القومي',
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical: 1.0),
                                                    icon: Icon(
                                                      Icons.assignment_ind,
                                                      color: Colors.pink[500],
                                                      size: 20,
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    String _msg;
                                                    final pattern =
                                                        r'(2|3)[0-9][1-9][0-1][1-9][0-3][1-9](01|02|03|04|11|12|13|14|15|16|17|18|19|21|22|23|24|25|26|27|28|29|31|32|33|34|35|88)\d\d\d\d\d';
                                                    final regExp =
                                                        RegExp(pattern);

                                                    if (value.isEmpty) {
                                                      _msg =
                                                          'أدخل الرقم القومي';
                                                    } else if (!regExp
                                                            .hasMatch(value) &&
                                                        value.length != 14) {
                                                      _msg =
                                                          'الرقم القومي غير صحيح';
                                                    } else {
                                                      _msg = null;
                                                    }
                                                    return _msg;
                                                  },
                                                  autocorrect: true,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  keyboardType: TextInputType
                                                      .number, // Changed to number
                                                  onSaved: (String value) {
                                                    _newMemberForm.personalId =
                                                        value;
                                                  },
                                                ),
                                                TextFormField(
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                  initialValue: widget.isGuest
                                                      ? model.guestInfo?.phone
                                                      : '',
                                                  readOnly: widget.isGuest
                                                      ? false //! true
                                                      : false,
                                                  decoration: InputDecoration(
                                                      helperStyle: TextStyle(
                                                          fontSize: 12),
                                                      labelStyle: TextStyle(
                                                          fontSize: 12),
                                                      labelText: 'رقم الهاتف',
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 1.0),
                                                      icon: Icon(
                                                        Icons.phone,
                                                        color: Colors.pink[500],
                                                        size: 20,
                                                      )),
                                                  validator: (value) {
                                                    String _msg;
                                                    value.length < 6
                                                        ? _msg = ' أدخل الهاتف'
                                                        : _msg = null;
                                                    return _msg;
                                                  },
                                                  keyboardType:
                                                      const TextInputType
                                                              .numberWithOptions(
                                                          signed: true),
                                                  onSaved: (String value) {
                                                    _newMemberForm.telephone =
                                                        value;
                                                    //!delete code before production
                                                    setState(() {
                                                      testPhone = value;
                                                    });
                                                  },
                                                ),
                                                widget.isGuest
                                                    ? TextFormField(
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                        decoration: InputDecoration(
                                                            helperStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        12),
                                                            labelStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        12),
                                                            labelText:
                                                                'البريد الإلكتروني',
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        2.0),
                                                            icon: Icon(
                                                                Icons.email,
                                                                size: 20,
                                                                color:
                                                                    Colors.pink[
                                                                        500])),
                                                        validator: (value) {
                                                          String _msg;
                                                          if (value.isEmpty) {
                                                            _msg =
                                                                'البريد الإلكتروني مطلوب';
                                                          }
                                                          // Added this else if block to check the email format
                                                          else if (!RegExp(
                                                                  r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                                              .hasMatch(
                                                                  value)) {
                                                            _msg =
                                                                'الرجاء إدخال بريد إلكتروني صحيح';
                                                          } else {
                                                            _msg = null;
                                                          }
                                                          return _msg;
                                                        },
                                                        autocorrect: true,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        onSaved:
                                                            (String value) {
                                                          _newMemberForm.email =
                                                              value;
                                                        },
                                                      )
                                                    : Container(),
                                                TextFormField(
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                  decoration: InputDecoration(
                                                      helperStyle: TextStyle(
                                                          fontSize: 12),
                                                      labelStyle: TextStyle(
                                                          fontSize: 12),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 2.0),
                                                      labelText: 'العنوان',
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                      icon: Icon(
                                                        GroovinMaterialIcons
                                                            .home,
                                                        size: 20,
                                                        color: Colors.pink[500],
                                                      )),
                                                  validator: (value) {
                                                    String _msg;
                                                    value.length < 15
                                                        ? _msg = 'أدخل العنوان'
                                                        : _msg = null;
                                                    return _msg;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                  onSaved: (String value) {
                                                    _newMemberForm.address =
                                                        value;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 300,
                                            child: Wrap(children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.add_location,
                                                    color: Colors.pink[500],
                                                    size: 20,
                                                  ),
                                                  SearchableDropdown(
                                                    hint: const Text(
                                                      'المنطقه',
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    icon: Icon(
                                                      Icons
                                                          .arrow_drop_down_circle,
                                                      color: Colors.pink[300],
                                                      size: 20,
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
                                                        areaSplit = selectedItem
                                                            .split('\ ');
                                                        _newMemberForm.areaId =
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
                                                            size: 20,
                                                          ),

                                                          //style: TextStyle(fontSize: 12),
                                                          hint: const Text(
                                                            'شحن الي منطقه',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          iconEnabledColor:
                                                              Colors.pink[200],
                                                          iconDisabledColor:
                                                              Colors.grey,
                                                          items: places,
                                                          value: selectedValue,
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
                                    ),
                                  ),
                                )
                              : Container()),
                    ]),
              ),
            ),
          ],
        ),
      ) //this line
          ;
    });
  }

  Future<bool> mobileRegForm(
      BuildContext context, MainModel model, String guestMemberId) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 320,
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formMKey,
                child: Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 40.0, // desired height
                      width: 120.0, // desired width
                      child: Center(
                        child: Text(guestMemberId),
                      ),
                    ),

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _newMemberForm.email,
                            textDirection: TextDirection.ltr,
                            enabled: false,
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
                      ),
                    ),
                    SizedBox(height: 1.0),
                    //* Mobile app registration button..
                    ElevatedButton(
                        onPressed: () async {
                          if (_formMKey.currentState.validate()) {
                            _formMKey.currentState.save();
                            await model
                                .regUserGuest(_email, _password, guestMemberId)
                                .then(
                              (value) {
                                if (value == 'true') {
                                  // _newMemberFormKey.currentState.reset();
                                  _formMKey.currentState.reset();
                                  appRegError(context, value, _password,
                                      guestMemberId, true);
                                }
                              },
                            );

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
                )),
              ),
            ),
          );
        });
  }

  void appRegError(BuildContext context, String e, String password,
      String distrId, bool fromGuest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text('$e'),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.check,
                size: 30.0,
                color: Colors.blue,
              ),
              onPressed: () async {
                if (e == 'true') {
                  await widget.model
                      .logIn(distrId, _password, context, fromGuest: true)
                      .then((value) => Navigator.of(context).pop());
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool isValidJson(String source) {
    try {
      json.decode(source);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Id> _saveNewMember(String user, String docType, String storeId,
      {bool isGuest: false}) async {
    Id body;

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
      if (isValidJson(response.body)) {
        body = Id.fromJson(json.decode(response.body));
      } else {
        print("Invalid JSON response: ${response.body}");
      }

      isGuest
          ? await widget.model
              .regUserGuest(_newMemberForm.email, testPhone, body.id)
              .then(
              (value) {
                if (value != 'true') {
                  setState(() {
                    body.err = value;
                  });
                }
              },
            )
          : DoNothingAction();

      print('body.response=>${response.body}');

      setState(() {
        body.code = response.statusCode;
      });

      if (kDebugMode) {
        print("body.id${body.id}");
      }
    } else {
      if (isValidJson(response.body)) {
        body = Id.fromJson(json.decode(response.body));
      } else {
        print("Invalid JSON response: ${response.body}");
      }

      if (kDebugMode) {
        print("body.err${body.err}");
      }
    }
    if (kDebugMode) {
      print(response.statusCode);
    }

    isloading(false);
    return body;
  }

// ! 99299682	 29407180101791	6281212207735
  Future<bool> showReview(BuildContext context, Id body) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ModalProgressHUD(
            child: Container(
              child: AlertDialog(
                actions: [
                  _btnView
                      ? IconButton(
                          onPressed: (() {
                            Navigator.of(context).pop();
                          }),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 24,
                          ))
                      : Container() //all commented lines belongs to guest model view.
                ],
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
                            //0124568111
                            body.code == 201
                                ? widget.model.userInfo.isGuest
                                    ? '${widget.model.guestInfo?.phone}:' +
                                        ' ' +
                                        'كلمة المرور' +
                                        ' ' +
                                        body.id +
                                        ' ' +
                                        'رقم العضويه'
                                    : ' ' + body.id + '  ' + ':رقم العضويه'
                                : body.err,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.pink[900],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          if (body.code == 201) {
                            _newMemberFormKey.currentState.reset();
                            isloading(true);
                            if (widget.model.userInfo.isGuest) {
                              await widget.model
                                  .logIn(body.id, testPhone, context,
                                      fromGuest: true)
                                  .whenComplete(() =>
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BottomNav(
                                            body.id,
                                            isAdmin: widget.model.user.isAdmin,
                                            stores: widget.model.user.stores,
                                          ),
                                        ),
                                        (route) => false,
                                      ));
                              isloading(false);
                              // Navigator.of(context).pushReplacementNamed('/login');

                            } else {
                              isloading(false);
                              Navigator.of(context).pop();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/bottomnav', (_) => false);
                            }
                            /*   _newMemberFormKey.currentState.reset();
                                await widget.model
                                   .logIn(
                                body.id, widget.model.guestInfo.phone, context,
                                fromGuest: true)
                                  .then((value) => Navigator.of(context).pop());*/

                            //

                          } else {
                            isloading(false);

                            Navigator.of(context).pop();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/bottomnav', (_) => false);
                          }
                        },
                        child: !_btnView
                            ? Container(
                                height: 35.0,
                                width: 35.0,
                                color: Colors.white,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              )
                            : Container(), //all commented three line belonge to guest pop up message
                      ),
                    ],
                  ),
                ),
              ),
            ),
            inAsyncCall: _isloading,
            opacity: 0.6,
            progressIndicator: ColorLoader2(),
          );
        });
  }
}
