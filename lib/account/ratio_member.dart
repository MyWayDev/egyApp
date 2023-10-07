// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class RatioReport extends StatefulWidget {
  final String userId;
  final String apiUrl;
  RatioReport(this.userId, this.apiUrl);

  State<StatefulWidget> createState() {
    return _RatioReport();
  }
}

@override
class _RatioReport extends State<RatioReport> {
  List<Member> members;
  List<Member> searchResult = [];
  TextEditingController controller = new TextEditingController();

  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  bool veri = false;
  //int _courier;
  User _nodeData;

  @override
  void initState() {
    _nodeData = null;
    memberDetailsReportSummary(widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: false,

      //drawer: Container(),
      floatingActionButton: FloatingActionButton(
        elevation: 21.5,
        backgroundColor: Colors.transparent,
        //foregroundColor: Colors.transparent,
        onPressed: () {
          memberDetailsReportSummary(widget.userId);
        },
        child: Icon(
          Icons.refresh,
          size: 32,
          color: Colors.black38,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      body: ModalProgressHUD(
        child: Column(children: <Widget>[
          Container(
            height: 58,
            color: Theme.of(context).primaryColorLight,
            child: Card(
              child: ListTile(
                leading: Icon(
                  Icons.search,
                  size: 22.0,
                ),
                title: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                  // style: TextStyle(fontSize: 18.0),
                  onChanged: onSearchTextChanged,
                ),
                trailing: IconButton(
                  alignment: AlignmentDirectional.centerEnd,
                  icon: Icon(Icons.cancel, size: 20.0),
                  onPressed: () {
                    controller.clear();
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
          Card(
              color: Colors.yellowAccent[100],
              child: ListTile(
                  title: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          '3% : ${members.where((m) => m.ratio == 3).length}   -  ',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          '6% : ${members.where((m) => m.ratio == 6).length}  -  ',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          '9% : ${members.where((m) => m.ratio == 9).length}    ',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          '12% : ${members.where((m) => m.ratio == 12).length}  -  ',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          '15% : ${members.where((m) => m.ratio == 15).length}  -  ',
                          style: TextStyle(fontSize: 13)),
                      Text(
                          '18% : ${members.where((m) => m.ratio == 18).length}   ',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          '21% : ${members.where((m) => m.ratio == 21).length}',
                          style: TextStyle(fontSize: 13)),
                    ],
                  )
                ],
              ))),
          buildDetailsReport(context),
        ]),
        inAsyncCall: _isloading,
        opacity: 0.6,
        progressIndicator: ColorLoader2(),
      ),
    );
  }

  Future<List<Member>> memberDetailsReportSummary(String distrid) async {
    members = [];
    isloading(true);

    http.Response response =
        await http.get(Uri.parse('${widget.apiUrl}/distrratio/$distrid'));
    if (response.statusCode == 200) {
      final _summary = json.decode(response.body) as List;
      members = _summary.map((m) => Member.formJsonRatio(m)).toList();
    }
    isloading(false);
    members.forEach((m) => print('${m.distrId}'));
    return members;
  }

  Widget buildDetailsReport(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Expanded(
          child: searchResult.length != 0 || controller.text.isNotEmpty
              ? ListView.builder(
                  itemCount: searchResult.length,
                  itemBuilder: (context, i) {
                    return Card(
                          elevation: 15,
                          color: Colors.yellow[50],
                          child: ListTile(
                            contentPadding: EdgeInsets.all(5),
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('${searchResult[i].distrId}'),
                                Text(
                                    searchResult[i].name.length >= 14
                                        ? searchResult[i]
                                                .name
                                                .substring(0, 14) +
                                            '..'
                                        : searchResult[i].name,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange[900])),
                                Text('${searchResult[i].telephone}',
                                    style: TextStyle(
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                    '${searchResult[i].ratio.toInt().toString()}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                    )),
                                members[i].count21 != 0
                                    ? Text(
                                        '  ${searchResult[i].count21.toString()}: عدد اليدر',
                                        style: TextStyle(
                                          fontSize: 13,
                                        ))
                                    : Text(''),
                                Text('${searchResult[i].areaName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                            trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                      '${searchResult[i].perBp.toInt().toString()}: النقاط الشخصية',
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 13,
                                      )),
                                  Text(
                                      '${searchResult[i].grpBp.toInt().toString()}: نقاط االمجموعة',
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: 13,
                                      )),
                                  searchResult[i].grpBp == searchResult[i].totBp
                                      ? Text('')
                                      : Text(
                                          '${searchResult[i].totBp.toInt().toString()}: اجمالى النقاط',
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 13,
                                          ))
                                ]),
                          ),
                        ) ??
                        '';
                  },
                )
              : members.isNotEmpty
                  ? ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, i) {
                        return Card(
                              elevation: 15,
                              color: Colors.yellow[50],
                              child: ListTile(
                                contentPadding: EdgeInsets.all(5),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('${members[i].distrId}',
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                        members[i].name.length >= 14
                                            ? members[i].name.substring(0, 14) +
                                                '..'
                                            : members[i].name,
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[900])),
                                    Text('${members[i].telephone}',
                                        style: TextStyle(
                                          fontSize: 11,
                                        )),
                                  ],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                        '${members[i].ratio.toInt().toString()}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                        )),
                                    members[i].count21 != 0
                                        ? Text(
                                            '${members[i].count21.toString()}: عدد اليدر',
                                            style: TextStyle(
                                              fontSize: 11,
                                            ))
                                        : Text(''),
                                    Text('${members[i].areaName}',
                                        style: TextStyle(
                                          fontSize: 11,
                                        )),
                                  ],
                                ),
                                trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                          '${members[i].perBp.toInt().toString()}: النقاط الشخصية',
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 11,
                                          )),
                                      Text(
                                          '${members[i].grpBp.toInt().toString()}: نقاط االمجموعة',
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: 11,
                                          )),
                                      members[i].grpBp == members[i].totBp
                                          ? Text('',
                                              style: TextStyle(fontSize: 11))
                                          : Text(
                                              '${members[i].totBp.toInt().toString()}: اجمالى النقاط',
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 11,
                                              ))
                                    ]),
                              ),
                            ) ??
                            Container();
                      },
                    )
                  : Container());
    });
  }

  onSearchTextChanged(String text) {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    members.forEach((item) {
      if (item.name.toLowerCase().contains(text.toLowerCase()) ||
          item.distrId.contains(text)) searchResult.add(item);
    });
    setState(() {});
  }
// One entry in the multilevel list displayed by this app.
}
