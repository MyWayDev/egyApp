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

class NewReport extends StatefulWidget {
  final String userId;
  final String apiUrl;
  NewReport(this.userId, this.apiUrl);

  State<StatefulWidget> createState() {
    return _NewReport();
  }
}

@override
class _NewReport extends State<NewReport> {
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

  void resetVeri() {
    veri = false;
  }

  @override
  void initState() {
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
        child: const Icon(
          Icons.refresh,
          size: 32,
          color: Colors.black38,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      body: ModalProgressHUD(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 58,
                color: Theme.of(context).primaryColorLight,
                child: Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.search,
                      size: 22.0,
                    ),
                    title: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "",
                        border: InputBorder.none,
                      ),
                      // style: TextStyle(fontSize: 18.0),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      alignment: AlignmentDirectional.centerEnd,
                      icon: const Icon(Icons.cancel, size: 20.0),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
              Card(
                  color: Colors.greenAccent[100],
                  child: ListTile(
                      title: Text('${members.length}: عدد الاعضاء الجدد ',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)))),
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
        await http.get(Uri.parse('${widget.apiUrl}/newmembers/$distrid'));
    if (response.statusCode == 200) {
      final _summary = json.decode(response.body) as List;
      members = _summary.map((m) => Member.formJsonNew(m)).toList();
    }
    isloading(false);
    members.forEach((m) => print(m.distrId));
    return members;
  }

  Widget buildDetailsReport(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Expanded(
          child: searchResult.length != 0 ||
                  controller.text.isNotEmpty //members.isNotEmpty

              ? ListView.builder(
                  itemCount: searchResult.length,
                  itemBuilder: (context, i) {
                    return Card(
                      elevation: 15,
                      color: Colors.green[50],
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(searchResult[i].joinDate),
                            Text(searchResult[i].distrId),
                            Text(
                                searchResult[i].name.length >= 14
                                    ? '..' +
                                        searchResult[i].name.substring(0, 14)
                                    : searchResult[i].name,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[500]))
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${searchResult[i].perBp.toInt()}: النقاط الشخصية',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(searchResult[i].telephone,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            Text(searchResult[i].areaName,
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : members.isNotEmpty
                  ? ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, i) {
                        return Card(
                          elevation: 15,
                          color: Colors.green[50],
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(members[i].joinDate),
                                Text(members[i].distrId),
                                Text(
                                    members[i].name.length >= 14
                                        ? '..' +
                                            members[i].name.substring(0, 14)
                                        : members[i].name,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[500]))
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '${members[i].perBp.toInt()}: النقاط الشخصية',
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(members[i].telephone,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                Text(members[i].areaName,
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        );
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
}
