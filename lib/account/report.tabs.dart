import 'package:badges/badges.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/account/guest_report.dart';
import 'package:mor_release/account/new_report.dart';
import 'package:mor_release/account/ratio_member.dart';
import 'package:mor_release/account/report.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class ReportTabs extends StatelessWidget {
  /* final AppBar _appBar = AppBar(
    bottomOpacity: 0.0,
    backgroundColor: Colors.pink[900],
    elevation: 20,
    ///////////////////////Top Tabs Navigation Widget//////////////////////////////
    title: TabBar(
      indicatorColor: Colors.yellow[300],
      indicatorWeight: 6,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: <Widget>[
        Tab(
          icon: Icon(
            GroovinMaterialIcons.account_check,
            size: 32.0,
            color: Colors.white,
          ),
        ),
        Tab(
          icon: Icon(
            GroovinMaterialIcons.account_plus,
            color: Colors.greenAccent[400],
            size: 32.0,
          ),
        ),
        Tab(
          icon: Icon(
            GroovinMaterialIcons.account_star,
            size: 32.0,
            color: Colors.yellow,
          ),
        ),
        Tab(
          icon: Icon(
            GroovinMaterialIcons.account_group,
            size: 32.0,
            color: Colors.purple[200],
          ),
        ),
        /* Tab(
          icon: Icon(
            GroovinMaterialIcons.account_network,
            size: 32.0,
            color: Colors.lightBlue[200],
          ),
        ),
        Tab(
          icon: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned(
                right: 3,
                child: IconButton(
                  onPressed: () {},

                  //BonusHistory(model.userInfo.distrId, model.settings.apiUrl),
                  icon: Icon(
                    GroovinMaterialIcons.file_document,
                    size: 31.0,
                    color: Colors.white38,
                  ),
                ),
              ),
              Positioned(
                  bottom: 5,
                  left: 9,
                  child: Icon(
                    GroovinMaterialIcons.history,
                    size: 25.0,
                    color: Colors.pink[50],
                  )),
            ],
          ),
        ),*/
      ],
    ),
  );*/

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(45.0),
              child: AppBar(
                bottomOpacity: 0.0,
                backgroundColor: Colors.pink[900],
                elevation: 20,
                ///////////////////////Top Tabs Navigation Widget//////////////////////////////
                title: TabBar(
                  indicatorColor: Colors.yellow[300],
                  indicatorWeight: 6,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(
                        GroovinMaterialIcons.account_check,
                        size: 32.0,
                        color: Colors.white,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        GroovinMaterialIcons.account_plus,
                        color: Colors.greenAccent[400],
                        size: 32.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        GroovinMaterialIcons.account_star,
                        size: 32.0,
                        color: Colors.yellow,
                      ),
                    ),
                    /* Tab(
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
                        GroovinMaterialIcons.account_group,
                        size: 32.0,
                        color: Colors.purple[200],
                      ),
                    )),*/
                    /* Tab(
          icon: Icon(
            GroovinMaterialIcons.account_network,
            size: 32.0,
            color: Colors.lightBlue[200],
          ),
        ),
        Tab(
          icon: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned(
                right: 3,
                child: IconButton(
                  onPressed: () {},

                  //BonusHistory(model.userInfo.distrId, model.settings.apiUrl),
                  icon: Icon(
                    GroovinMaterialIcons.file_document,
                    size: 31.0,
                    color: Colors.white38,
                  ),
                ),
              ),
              Positioned(
                  bottom: 5,
                  left: 9,
                  child: Icon(
                    GroovinMaterialIcons.history,
                    size: 25.0,
                    color: Colors.pink[50],
                  )),
            ],
          ),
        ),*/
                  ],
                ),
              )),
          body: TabBarView(
            dragStartBehavior: DragStartBehavior.down,
            children: <Widget>[
              Report(model.userInfo.distrId),
              NewReport(model.userInfo.distrId,
                  'https://mywayegypt-api.azurewebsites.net/api'),
              RatioReport(model.userInfo.distrId,
                  'https://mywayegypt-api.azurewebsites.net/api'),
              /* GuestReport(model.userInfo.distrId,
                  'https://mywayegypt-api.azurewebsites.net/api'),*/

              // TrackInvoice(model.userInfo.distrId),
              //  Report(model.userInfo.distrId),
              //  Report(model.userInfo.distrId),
              // ExpansionTileSample() // SwitchPage(ItemsPage()),
              //OrderPage(), //SwitchPage(OrderPage()),
              //ProductList(),
            ],
          ),
          /* bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                  title: new Text('Account'),
                  icon: new Icon(Icons.account_box)),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.mail), title: new Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile'))
            ],
          ),*/
        ),
      );
    });
  }
/*new BottomNavigationBarItem(
        title: new Text('Home'),
        icon: new Stack(
          children: <Widget>[
            new Icon(Icons.home),
            new Positioned(  // draw a red marble
              top: 0.0,
              right: 0.0,
              child: new Icon(Icons.brightness_1, size: 8.0, 
                color: Colors.redAccent),
            )
          ]
        ),
      )*/

}
