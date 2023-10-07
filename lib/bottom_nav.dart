import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:http/http.dart' as http;
import 'package:mor_release/account/new_member.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/items/items.tabs.dart';
import 'package:mor_release/pages/messages/tickets.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

import 'account/report.tabs.dart';

class BottomNav extends StatefulWidget {
  final String user;
  final bool isAdmin;
  final List stores;
  final bool isGuest;

  const BottomNav(
    this.user, {
    Key key,
    this.isAdmin: false,
    this.stores: const [],
    this.isGuest,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _BottomNav();
  }
}

// SingleTickerProviderStateMixin is used for animation
class _BottomNav extends State<BottomNav> with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController tabController;
  Query query;
  var subAdd;
  var subChanged;
  var subDel;
  List<Ticket> _msgsList = [];
  String path = "flamelink/environments/egyProduction/content/support/en-US/";
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  int _msgCount = 0;
  @override
  void initState() {
    databaseReference = database.reference().child(path);
    !widget.isAdmin
        ? query = databaseReference
            .child('/')
            .orderByChild('user')
            .equalTo(widget.user.toString())
        : query = databaseReference.child("/");

    subAdd = query.onChildAdded.listen(_onMessageEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    super.initState();

//! add admin conditions here for 1 to 5 users..

    // Initialize the Tab Controller
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      // model.countGuest();
      return Scaffold(
        resizeToAvoidBottomInset: false, // Appbar
        /*appBar: new AppBar(
        // Title
        title: new Text("Using Bottom Navigation Bar"),
        // Set the background color of the App Bar
        backgroundColor: Colors.blue,
      ),*/
        // Set the TabBar view as the body of the Scaffold

        body: TabBarView(
          // Add tabs as widgets
          children: <Widget>[
            ItemsTabs(),
            NewMemberPage(model),
            ReportTabs(),
            Tickets(
              distrId: int.parse(model.user.key),
              isAdmin: model.user.isAdmin,
              stores: model.user.stores,
            )

            //Report(model.user.distrId),
            //  Cat(pdfUrl: model.settings.pdfUrl)
          ],

          // set the controller
          controller: tabController,
        ),
        // Set the bottom navigation bar
        bottomNavigationBar: Material(
          // set the color of the bottom navigation bar
          color: Colors.transparent,
          elevation: 20,

          // set the tab bar as the child of bottom navigation bar
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            indicatorColor: Colors.pink[700],
            tabs: <Tab>[
              Tab(
                // set icon to the tab
                icon: Icon(
                  Icons.home,
                  size: 32,
                  color: Colors.pink[700],
                ),
              ),
              Tab(
                icon: Icon(GroovinMaterialIcons.account_plus,
                    size: 32, color: Colors.pink[700]),
              ),
              Tab(
                  icon: Badge(
                showBadge: model.guestCount == 0 ? false : true,
                animationDuration: const Duration(microseconds: 450),
                animationType: BadgeAnimationType.scale,
                badgeColor: Colors.deepPurple[300],
                badgeContent: Text(
                  '${model.guestCount > 0 ? model.guestCount : 0}',
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(
                  GroovinMaterialIcons.book_open_page_variant,
                  size: 32.0,
                  color: Colors.pink[700],
                ),
              )),
              Tab(
                  icon: Badge(
                showBadge: _msgCount == 0 ? false : true,
                animationDuration: const Duration(microseconds: 450),
                animationType: BadgeAnimationType.scale,
                badgeColor: Colors.pink,
                badgeContent: Text(
                  '${_msgCount > 0 ? _msgCount : 0}',
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(
                  Icons.forum,
                  size: 32.0,
                  color: Colors.pink[700],
                ),
              )
                  /*BadgeIconButton(
                itemCount: _msgCount > 0 ? _msgCount : 0,
                badgeColor: Colors.deepPurple[300],
                icon: Icon(
                  Icons.forum,
                  size: 32.0,
                  color: Colors.pink[700],
                ),
              )*/
                  )
            ],
            // setup the controller
            controller: tabController,
          ),
        ),
      );
    });
  }

  void _onMessageEntryAdded(Event event) {
    _msgsList.add(Ticket.fromSnapshot(event.snapshot));

    setState(() {});
    _msgSnapshotCount(widget.user);
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = _msgsList.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _msgsList[_msgsList.indexOf(oldEntry)] =
          Ticket.fromSnapshot(event.snapshot);
      _msgSnapshotCount(widget.user);
    });
  }

  void _msgSnapshotCount(String user) {
    _msgCount = 0;
    if (!widget.isAdmin) {
      _msgsList.forEach((f) => _msgCount += f.fromSupport);
    } else {
      _msgsList
          .where(
              (t) => widget.stores.where((e) => t.store == e).any((a) => true))
          .toList()
          .forEach((f) => _msgCount += f.fromClient);
      //_msgsList.forEach((f) => _msgCount += f.fromClient);

    }
  }
}

class Msgs {
  String key;
  int fromClient;
  int fromSupport;
  Msgs({
    this.key,
    this.fromClient,
    this.fromSupport,
  });
  Msgs.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        fromClient = snapshot.value['fromClient'],
        fromSupport = snapshot.value['fromSupport'];
}
