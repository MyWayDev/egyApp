import 'package:flutter/material.dart';
import 'package:mor_release/pages/items/items.tabs.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class BottomNavGuest extends StatefulWidget {
  final String user;
  final bool isAdmin;
  final List stores;
  final bool isGuest;

  const BottomNavGuest(this.user,
      {Key key, this.isAdmin: false, this.stores: const [], this.isGuest})
      : super(key: key);

  @override
  State<BottomNavGuest> createState() => _BottomNavGuest();
}

class _BottomNavGuest extends State<BottomNavGuest>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
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
            //NewMemberPage(),
            // ReportTabs(),

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
              /* Tab(
                icon: Icon(GroovinMaterialIcons.account_plus,
                    size: 32, color: Colors.pink[700]),
              ),
              Tab(
                icon: Icon(GroovinMaterialIcons.book_open,
                    size: 32, color: Colors.pink[700]),
              ),*/
            ],
            // setup the controller
            controller: tabController,
          ),
        ),
      );
    });
  }
}
