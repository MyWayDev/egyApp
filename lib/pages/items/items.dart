import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart' as intl;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/gift.dart';
import 'package:mor_release/models/lock.dart';
import 'package:mor_release/pages/items/itemDetails/footer.dart';
import 'package:mor_release/pages/order/widgets/storeFloat.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../models/item.dart';
import '../items/item.card.dart';
import 'package:mor_release/scoped/connected.dart';

class ItemsPage extends StatefulWidget {
  final MainModel model;
  ItemsPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _ItemsPage();
  }
}

@override
class _ItemsPage extends State<ItemsPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  final formatWeight = new intl.NumberFormat("#,###.##");
  //String db = 'production';
  String path =
      "flamelink/environments/egyProduction/content/items/en-US"; //! VERY IMPORTANT change back to production before release
  List<Item> itemData = [];
  List<Item> searchResult = [];
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  var subAdd;
  var subChanged;
  TextEditingController controller = new TextEditingController();
  Lock lock;
  double width = 100.0, height = 100.0;
  Offset position;
  //bool defaultDB = true;
  bool _loading = true;
  void isLoading(bool o) {
    setState(() {
      _loading = o;
    });
  }

  double perBp;
  AppBar appBar;
  @override
  void initState() {
    super.initState();
    databaseReference = database.reference().child(path);
    Query query = databaseReference.orderByChild('catalogue').equalTo(true);
    widget.model.getStores();
    widget.model.getAreasList();
    // !TODO ADD QUERY TO FILTER PRODUCTS NOT IN CATALOGE..
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();
    _animation = Tween<double>(
      begin: -100, // starting value
      end: 110, // ending value
    ).animate(_animationController);
  }

  bool userType() {
    bool _isAllowed = false;

    if (widget.model?.user != null) {
      if (widget.model.user.isGuest) {
        _isAllowed = widget.model.guestInfo?.isAllowed ?? false;
      } else {
        _isAllowed = widget.model.user.isAllowed ?? false;
      }
    }

    return _isAllowed;
  }

  Future<String> getgiftImageUrl(MainModel model) async {
    List<Gift> gift = await model.giftList();
    return gift[0].imageUrl;
  }

  @override
  void dispose() {
    position = Offset(0, _animation.value);
    subAdd?.cancel();
    subChanged?.cancel();

    _animationController.dispose();
    super.dispose();
  }

  String type;
  bool isSelected = false;

/*Widget build(BuildContext context) {
  return new FutureBuilder(
    future: getgiftImageUrl(),
    builder: (BuildContext context, AsyncSnapshot<Image> image) {
      if (image.hasData) {
        return image.data;  // image is ready
      } else {
        return new Container();  // placeholder
      }
    },
  );
}*/

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      model.itemData = itemData;
      model.searchResult = searchResult;
      return ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
          child: Scaffold(
            appBar: appBar,
            floatingActionButton: FloatingActionButton.extended(
              label: Padding(
                child: Column(
                  children: <Widget>[
                    model.orderSum() > 0
                        ? Wrap(
                            spacing: 24,
                            runSpacing: 10,
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Chip(
                                elevation: 5,
                                shadowColor: Colors.black,
                                backgroundColor: Colors.grey[350],
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.green[700],
                                  child: Text('جنيه',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.4,
                                          fontWeight: FontWeight.bold)),
                                ),
                                label: Text(
                                  formatter.format(model.orderSum()),
                                  style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              !widget.model.user.isGuest
                                  ? Chip(
                                      elevation: 5,
                                      shadowColor: Colors.black,
                                      backgroundColor: Colors.grey[350],
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.pink[900],
                                        child: Text('نقاط',
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.normal)),
                                      ),
                                      label: Text(
                                        model.orderBp().toString(),
                                        style: TextStyle(
                                            color: Colors.pink[900],
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Container(),
                              Chip(
                                elevation: 5,
                                shadowColor: Colors.black,
                                backgroundColor: Colors.grey[350],
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Text('كغ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold)),
                                ),
                                label: Text(
                                  formatWeight.format(model.orderWeight()),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    // MyBlinkingButton()
                    StoreFloat(model)
                  ],
                ),
                padding: EdgeInsets.only(right: 35),
              ),

              isExtended: true,
              elevation: 30,
              //onPressed:,
              icon: Icon(
                Icons.arrow_right,
                color: Colors.transparent,
              ),
              backgroundColor: Colors.transparent, onPressed: () {},
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            resizeToAvoidBottomInset: false,
            body: Stack(children: <Widget>[
              Column(
                children: <Widget>[
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
                  userType()
                      ? Expanded(
                          child: searchResult.isNotEmpty ||
                                  controller.text.isNotEmpty
                              ? ListView.builder(
                                  itemCount: searchResult.length,
                                  itemBuilder: (context, i) {
                                    return ItemCard(
                                      searchResult,
                                      i,
                                      isGuest: model.user.isGuest,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: itemData.length,
                                  itemBuilder: (context, index) {
                                    return ItemCard(itemData, index,
                                        isGuest: model.user.isGuest);
                                  },
                                ),

                          /* GridView.count(
                              crossAxisCount: 2,
                              children: List.generate(itemData.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => StockDialog(itemData,
                                            index, model.iCount(index)));
                                  },
                                  // Get.to(ProductDetail(product: product[index])),
                                  child: !model.cartLocked
                                      ? Stack(
                                          fit: StackFit.passthrough,
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          children: <Widget>[
                                            buildCard(itemData[index]),
                                            !model.iheld(index)
                                                ? Stack(
                                                    children: [
                                                      Positioned(
                                                          bottom: -3,
                                                          right: 15,
                                                          child: Icon(
                                                            GroovinMaterialIcons
                                                                .cart,
                                                            color: Colors.grey,
                                                            size: model.iCount(
                                                                        index) ==
                                                                    0
                                                                ? 0
                                                                : 32,
                                                          )),
                                                      BadgeIconButton(
                                                        itemCount:
                                                            model.iCount(index),
                                                        icon: Icon(
                                                          Icons.shopping_cart,
                                                          color:
                                                              Colors.pink[900],
                                                          size: 1.0,
                                                        ),
                                                        badgeColor: !model
                                                                .iheld(index)
                                                            ? Colors.red
                                                            : Colors.amber[400],
                                                        badgeTextColor:
                                                            Colors.white,
                                                        onPressed: () async {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                StockDialog(
                                                              itemData,
                                                              index,
                                                              model.iCount(
                                                                  index),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : Stack(
                                                    children: <Widget>[
                                                      BadgeIconButton(
                                                        itemCount:
                                                            model.iCount(index),
                                                        icon: Icon(
                                                          GroovinMaterialIcons
                                                              .cart_plus,
                                                          color:
                                                              Colors.pink[900],
                                                          size: 1.0,
                                                        ),
                                                        badgeColor:
                                                            Colors.amber[400],
                                                        badgeTextColor:
                                                            Colors.white,
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  StockDialog(
                                                                      itemData,
                                                                      index,
                                                                      model.iCount(
                                                                          index)));
                                                        },
                                                      ),
                                                      Positioned(
                                                          child: Icon(
                                                        GroovinMaterialIcons
                                                            .lock,
                                                        color: Colors.blue,
                                                      )),
                                                    ],
                                                  ),
                                          ],
                                        )
                                      : BadgeIconButton(
                                          itemCount: model.iCount(index),
                                          icon: Icon(
                                            Icons.remove_shopping_cart,
                                            color: Colors.grey,
                                            size: 30.0,
                                          ),
                                        ),
                                );
                              }),
                            )*/

                          /*//** */ ListView.builder(
                            itemCount: itemData.length,
                            itemBuilder: (context, index) {
                              return buildCard(
                                  itemData[index]); //ItemCard(itemData, index);
                            },
                          ),*/
                        )
                      : Container(
                          padding: const EdgeInsets.only(top: 285.0),
                          width: 100.0,
                          height: 200.0,
                          child: AnimatedBuilder(
                            child: child,
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _animation.value),
                                child: Icon(
                                  GroovinMaterialIcons.arrow_down_bold,
                                  color: Colors.pink,
                                  size: 58.0,
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
              /* DraggableFloatingActionButton(
                  data: 'dfab_demo',
                  offset: Offset(100, 205),
                  backgroundColor: Colors.amberAccent,
                  child: Text(
                    perBp.toString(),
                  ),
                  onPressed: () async {
                    print(model.userInfo.distrId);
                    perBp = await getPersonalPoints(model.userInfo.distrId);
                  },
                  appContext: context,
                  appBar: appBar),*/
            ]),
          ));
    });
  }

  onSearchTextChanged(String text) {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    itemData.where((i) => !i.disabled).forEach((item) {
      if (item.name.toLowerCase().contains(text.toLowerCase()) ||
          item.itemId.contains(text)) searchResult.add(item);
    });
    setState(() {});
  }

  void _onItemEntryAdded(Event event) {
    //List<Item> items = [];
    isLoading(true);
    itemData.add(Item.fromSnapshot(event.snapshot));
    // items.where((i) => !i.disabled).forEach((f) => itemData.add(f));
    //print("itemData length:${itemData.length}");
    setState(() {});
    isLoading(false);
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = itemData.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      itemData[itemData.indexOf(oldEntry)] = Item.fromSnapshot(event.snapshot);
    });
  }
}

/*

  Flushbar flushAction(BuildContext context) {
    Flushbar f = Flushbar(
      isDismissible: false,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.bounceIn,
      forwardAnimationCurve: Curves.fastOutSlowIn,

      mainButton: FlatButton(
        onPressed: () {
          _isMap = true;
          Navigator.of(context).pop();
        },
        child: Icon(
          GroovinMaterialIcons.close_circle_outline,
          color: Colors.red,
        ),
      ),
      margin: EdgeInsets.all(1),
      borderRadius: 8,
      title: 'Order From',
      messageText: Container(
        padding: EdgeInsets.all(8.0),
        child: Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: ModalProgressHUD(
              color: Colors.transparent,
              inAsyncCall: widget.model.isloading,
              opacity: 0.1,
              progressIndicator: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
              ),
              child: getRegions()),
        ),
      ),
      //  message: 'Silahkan Lakukan Pembayaran Melalui',
      icon: Icon(
        GroovinMaterialIcons.map_marker_radius,
        color: Colors.amberAccent,
        size: 28,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    );
    return f;
  }
*/
