import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

class Guest {
  String key;
  String phone;
  String stamp;
  String token;
  bool isAllowed;

  Guest(
      {this.phone = '0000000000',
      this.isAllowed = false,
      this.stamp,
      this.token});

  Guest.defaultGuest() {
    phone = '0';
    isAllowed = false;
  }

  Guest.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        phone = snapshot.value["phone"],
        stamp = snapshot.value["stamp"] ?? DateTime.now(),
        token = snapshot.value["token"],
        isAllowed = snapshot.value["isAllowed"] ?? false;

  toJson() {
    return {
      "phone": phone,
      "stamp": stamp,
      "token": token,
      'isAllowed': isAllowed,
    };
  }
}

class User {
  String key;
  String distrId;
  String name;
  String distrIdent;
  String email;
  String phone;
  String areaId;
  String photoUrl;
  String serviceCenter;
  bool isAllowed;
  bool isleader;
  bool isAdmin;
  bool tester;
  List stores;
  String token;
  bool isGuest;

  User(
      {this.distrId,
      this.email,
      this.distrIdent,
      this.phone,
      this.name,
      this.areaId,
      this.photoUrl,
      this.serviceCenter,
      this.isAllowed = false,
      this.isleader,
      this.isAdmin,
      this.tester,
      this.stores,
      this.token,
      this.isGuest = false});

  toJson() {
    return {
      "IsAllowed": true,
      "distrId": distrId,
      "distrIdent": distrIdent,
      "email": email,
      "id": int.parse(distrId).toString(),
      "isleader": true,
      "isAdmin": null ?? false,
      "isGuest": null ?? false,
      "areaId": areaId,
      "name": name ?? '',
      "tele": phone,
    };
  }

  factory User.formJson(Map<String, dynamic> json) {
    return User(
        distrId: json['DISTR_ID'] ?? '',
        name: json['ANAME'] ?? '', //! egyupdate from LNAME TO ANAME
        distrIdent: json['DISTR_IDENT'] ?? '',
        email: json['E_MAIL'] ?? '',
        phone: json['TELEPHONE'] ?? '',
        areaId: json['AREA_ID'] ?? '',
        serviceCenter: json['SERVICE_CENTER']);
  }
  // * firebase sample code for model..
  User.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"] ?? '',
        distrId = snapshot.value["distrId"],
        email = snapshot.value["email"] ?? '',
        isAllowed = snapshot.value["IsAllowed"],
        isleader = snapshot.value["isleader"],
        isAdmin = snapshot.value["isAdmin"] ?? false,
        isGuest = snapshot.value["isGuest"] ?? false,
        areaId = snapshot.value["areaId"],
        token = snapshot.value["token"],
        tester = snapshot.value["tester"] ?? false,
        stores = snapshot.value["stores"] ?? [],
        photoUrl = snapshot.value["photoUrl"];

  User.useSnapshot(DataSnapshot snapshot)
      : name = snapshot.value["name"] ?? '',
        distrId = snapshot.value["distrId"],
        email = snapshot.value["email"],
        isAllowed = snapshot.value["IsAllowed"],
        isleader = snapshot.value["isleader"],
        isAdmin = snapshot.value["isAdmin"] ?? false,
        areaId = snapshot.value["areaId"],
        token = snapshot.value["token"],
        tester = snapshot.value["tester"],
        stores = snapshot.value["stores"] ?? [],
        isGuest = snapshot.value["isGuest"] ?? false,
        photoUrl = snapshot.value["photoUrl"];
}

class NewMember {
  String sponsorId;
  String familyName;
  String name;
  String personalId;
  String birthDate;
  String email;
  String telephone;
  String address;
  String areaId;
  String bankAccoutName;
  String bankAccountNumber;
  String taxNumber;
  String serviceCenter;
  String password;

  NewMember(
      {this.sponsorId,
      this.familyName,
      this.name,
      this.personalId,
      this.birthDate,
      this.email,
      this.telephone,
      this.address,
      this.areaId,
      this.bankAccoutName,
      this.bankAccountNumber,
      this.taxNumber,
      this.password,
      this.serviceCenter});

  Map<String, dynamic> toJson() => {
        "SPONSOR_ID": sponsorId,
        "FAMILY_ANAME": familyName,
        "ANAME": name,
        "DISTR_IDENT": personalId,
        "BIRTH_DATE": birthDate,
        "E_MAIL": email,
        "TELEPHONE": telephone,
        "ADDRESS": address,
        "AREA_ID": areaId,
        "NOTES": bankAccoutName,
        "SM_ID": bankAccountNumber,
        "AP_AC_ID": taxNumber,
        "SERVICE_CENTER": serviceCenter,
      };

  String postNewMemberToJson(NewMember newMember) {
    final dyn = newMember.toJson();
    return json.encode(dyn);
  }
  //!! refactor to new schema from api documentation;

  Future<http.Response> createPost(
      NewMember newMember,
      String user,
      String shipmentPlace,
      String shipmentPlaceName,
      String areaId,
      String docType,
      String storeId) async {
    final response = await http.put(
        Uri.parse(
            'http://mywayegypt-api.azurewebsites.net/api/memregister_ds_8k/$user/$shipmentPlace/$areaId/$shipmentPlaceName/$docType/$storeId'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postNewMemberToJson(newMember));

    return response;
  }

  Future<http.Response> createGuestPost(
      NewMember newMember,
      String user,
      String shipmentPlace,
      String shipmentPlaceName,
      String areaId,
      String docType,
      String storeId) async {
    final response = await http.put(
        Uri.parse(
            'http://mywayegypt-api.azurewebsites.net/api/post-guest-membership/$user/$shipmentPlace/$areaId/$shipmentPlaceName/$docType/$storeId'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postNewMemberToJson(newMember));

    return response;
  }
}

class Member {
  String distrId;
  String name;
  String joinDate; //?new member REPORT
  var count21; //? ratio REPORT
  var perBp;
  var grpBp;
  var totBp;
  var ratio;
  var grpCount;
  String leaderId;
  String leaderName; //? details REPORT
  String sponsorId;
  String sponsorName; //? details REPORT
  String areaName; //?new member REPORT
  String telephone; //?new member REPORT
  String area;
  String lastUpdate;
  String nextUpdate;

  Member({
    this.distrId,
    this.name,
    this.joinDate,
    this.count21,
    this.perBp,
    this.grpBp,
    this.totBp,
    this.ratio,
    this.leaderId,
    this.leaderName,
    this.sponsorId,
    this.sponsorName,
    this.areaName,
    this.telephone,
    this.grpCount,
    this.area,
    this.lastUpdate,
    this.nextUpdate,
  });

  factory Member.formJson(Map<String, dynamic> json) {
    return Member(
      distrId: json['DISTR_ID'],
      name: json['M_ANAME'],
      perBp: json['PER_BP'] ?? 0,
      grpBp: json['PGROUP_BP'] ?? 0,
      totBp: json['TOTAL_BP'] ?? 0,
      ratio: json['m_ratio'] ?? 0,
      leaderId: json['LEADER_ID_N'] ?? '',
      sponsorId: json['SPONSOR_ID'] ?? '',
      grpCount: json['COUNT'] ?? 0,
      area: json['AREA'],
      lastUpdate: json['LASTUPDATE'] ?? '12:00:00 ',
      nextUpdate: json['NEXTUPDATE'] ?? '12:01:00 ',
    );
  }
  factory Member.formJsonNew(Map<String, dynamic> json) {
    return Member(
      distrId: json['distr_id'],
      name: json['distr_name'],
      joinDate: json['JOIN_DATE'],
      perBp: json['per_bp'] ?? 0,
      areaName: json['area_name'],
      telephone: json['TELEPHONE'],
    );
  }
  factory Member.formJsonRatio(Map<String, dynamic> json) {
    return Member(
      distrId: json['distr_id'],
      name: json['distr_name'],
      ratio: json['M_RATIO'],
      count21: json['COUNT21'],
      perBp: json['per_bp'] ?? 0,
      grpBp: json['PGROUP_BP'] ?? 0,
      totBp: json['TOTAL_BP'] ?? 0,
      areaName: json['area_name'],
      telephone: json['TELEPHONE'],
    );
  }
  factory Member.formJsonDetails(Map<String, dynamic> json) {
    return Member(
      distrId: json['DISTR_ID'],
      name: json['NAME'],
      perBp: json['PER_BP'] ?? 0,
      grpBp: json['PGROUP_BP'] ?? 0,
      totBp: json['TOTAL_BP'] ?? 0,
      ratio: json['RATIO'] ?? 0,
      leaderId: json['LEADER_ID'],
      leaderName: json['LEADER_NAME'],
      sponsorId: json['SPONSER_ID'],
      sponsorName: json['SPONSER_NAME'],
      grpCount: json['COUNT'] ?? 0,
      areaName: json['AREA'],
    );
  }
}

class DistrBonus {
  String distrId;
  String name;
  var bonus;

  DistrBonus({this.distrId, this.name, this.bonus});
  toJson() {
    return {"DISTR_ID": distrId};
  }

  String distrBonusToJson(DistrBonus distrBonus) {
    final dyn = distrBonus.toJson();
    return json.encode(dyn);
  }

  factory DistrBonus.fromJson(Map<dynamic, dynamic> json) {
    return DistrBonus(distrId: json['distr_id'], bonus: json['NET_DESRV']);
  }
}
