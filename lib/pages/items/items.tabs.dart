import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/catalog.dart';
import 'package:mor_release/pages/items/items.dart';
import 'package:mor_release/pages/order/order.dart';
import 'package:mor_release/pages/user/login_screen.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/track/track.tabs.dart';
import 'package:mor_release/widgets/login/rest_Credintials.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:badges/badges.dart';

import '../../cat.dart';
import '../../main.dart';

//////////////////////////////////////////////////////
///
///!notification badge over icon example code

class ItemsTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      model.userDetails();

      return MaterialApp(
          theme: ThemeData(
            primarySwatch: model.user.isGuest ? Colors.blueGrey : Colors.pink,
          ),
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              drawer: Drawer(
                  child: Column(children: <Widget>[
                AppBar(
                  title: Text('القائمه'),
                ),
                /* ListTile(
                leading: Icon(Icons.email),
                title: Text('email'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EmailPage()));
                }),*/

                ListTile(
                    leading: Icon(Icons.image),
                    title: Text('الكتالوج'),
                    onTap: () {
                      //print(model.settings.pdfUrl);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder:
                                  (context) => /* Catalog(
                                    pdfUrl: model.settings.pdfUrl,
                                  )));*/
                                      Cat(
                                        model.settings.pdfUrl,
                                      )));
                    }),
                !model.user.isGuest
                    ? ListTile(
                        leading: Icon(Icons.password),
                        title: Text('تحديث كلمة السر'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => RestCredintials(),
                          );
                          //print(model.settings.pdfUrl);

                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => EmailVerify()));
                        })
                    : Container(),
                ListTile(
                    leading: Icon(Icons.backspace),
                    title: Text('خروج'),
                    onTap: () {
                      model.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }),
              ])),
              appBar: AppBar(
                ///////////////////////Top Tabs Navigation Widget//////////////////////////////
                title: TabBar(
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(
                        Icons.home,
                        size: 26.0,
                        color: Colors.grey[350],
                      ),
                    ),
                    model.bulkOrder.length != 0
                        ? Tab(
                            child: Stack(
                              alignment: AlignmentDirectional.topStart,
                              children: <Widget>[
                                Badge(
                                  showBadge: model.bulkOrder.length == 0
                                      ? false
                                      : true,
                                  alignment: Alignment.center,
                                  animationDuration:
                                      const Duration(microseconds: 450),
                                  animationType: BadgeAnimationType.scale,
                                  badgeContent: Text(
                                    '${model.itemCount() < 0 ? 0 : model.itemCount()}',
                                    style: TextStyle(color: Colors.white),
                                  ), // required
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.grey[350],
                                    size: 26.0,
                                  ), // required
                                  //badgeColor: Colors.red, // default: Colors.red
                                  // default: Colors.white
                                  //hideZeroCount: true, // default: true
                                ),
                                Positioned(
                                  child: Opacity(
                                      opacity: 1,
                                      child: Badge(
                                        alignment: Alignment.center,
                                        animationDuration:
                                            const Duration(microseconds: 450),
                                        animationType: BadgeAnimationType.scale,
                                        badgeColor: Colors.purple[800],
                                        badgeContent: Text(
                                          '${model.bulkOrder.length < 0 ? 0 : model.bulkOrder.length}',
                                          style: TextStyle(color: Colors.white),
                                        ), // required
                                        child: Icon(
                                          Icons.local_shipping,
                                          color: Colors.grey[350],
                                          size: 0.1,
                                        ), // required
                                        //badgeColor: Colors.red, // default: Colors.red
                                        // default: Colors.white
                                        //hideZeroCount: true, // default: true
                                      )),
                                ),
                              ],
                            ),
                          )
                        : Tab(
                            child: Badge(
                              position: BadgePosition(
                                bottom: 12,
                                start: 5,
                                isCenter: false,
                              ),
                              badgeColor: Colors.white,
                              showBadge: model.itemCount() == 0 ? false : true,
                              alignment: Alignment.center,
                              animationDuration:
                                  const Duration(microseconds: 450),
                              animationType: BadgeAnimationType.scale,
                              badgeContent: Text(
                                '${model.itemCount() < 0 ? 0 : model.itemCount()}',
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontWeight: FontWeight.bold),
                              ), // required
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.grey[350],
                                size: 26.0,
                              ), // required
                              //badgeColor: Colors.red, // default: Colors.red
                              // default: Colors.white
                              //hideZeroCount: true, // default: true
                            ),
                            /* icon: new Stack(children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          size: 35.0,
                        ),
                        Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: )
                      ]),*/
                          ),
                    Tab(
                      icon: Icon(
                        GroovinMaterialIcons.file_find,
                        size: 26.0,
                        color: Colors.grey[350],
                      ),
                    ),
                    /* Tab(
                    child: BadgeIconButton(
                  itemCount: model.noteCount,
                  badgeColor: Colors.lightBlueAccent,
                  icon: Icon(
                    Icons.notifications,
                    size: 26.0,
                    color: Colors.grey[350],
                  ),
                ))*/
                    //! commented
                  ],
                ),
              ),
              ////////////////////////Bottom Tabs Navigation widget/////////////////////////
              body: TabBarView(
                children: <Widget>[
                  ItemsPage(model), // SwitchPage(ItemsPage()),
                  OrderPage(model), //SwitchPage(OrderPage()),
                  //   model.bulkOrder.length != 0 ? OrderPage(model) : null,
                  TrackTabs(),
                  /* LocalNotification(
                token: model.token,
              ),*/ //! commented

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
          ));
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

  /* Widget _currentUser(BuildContext context, MainModel model) {
    return new FutureBuilder(
      future: model.loggedUser(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData)
          return Text(snapshot.data);
        else
          return Text('*');
      },
    );
  }*/
}

enum db { production, stage }
