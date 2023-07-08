import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/models/lock.dart';
import 'package:mor_release/scoped/connected.dart';

import '../../../models/user.dart';

class StoreFloat extends StatefulWidget {
  final MainModel model;

  StoreFloat(this.model, {key}) : super(key: key);

  @override
  _StoreFloatState createState() => _StoreFloatState();
}

class _StoreFloatState extends State<StoreFloat> with TickerProviderStateMixin {
  AnimationController _controller1;
  Animation<Offset> _offsetAnimation1;

  AnimationController _animationController1;
  Lock lock;

  @override
  void initState() {
    _controller1 =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true);

    _offsetAnimation1 = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.1), // Increase motion range by changing second parameter
    ).animate(CurvedAnimation(parent: _controller1, curve: Curves.easeInOut));

    _animationController1 =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController1.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller1.dispose();

    _animationController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: <Widget>[
        _showNeedHelpButton(),
        widget.model.user.isGuest && !widget.model.guestInfo.isAllowed
            ? SlideTransition(
                position: _offsetAnimation1,
                child: ElevatedButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered))
                            return Colors.black.withOpacity(0.04);
                          if (states.contains(MaterialState.focused) ||
                              states.contains(MaterialState.pressed))
                            return Colors.grey.withOpacity(0.12);
                          return null; // Defer to the widget's default.
                        },
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.amber))),
                    ),
                    onPressed: () {
                      dialogDistrPoints(context, widget.model)
                          .whenComplete(() async {
                        await widget.model
                            .guestActivated(widget.model.guestInfo.key);
                      });
                    },
                    child: Text(
                      'لإختيار المدينة اضغط هنا',
                      style: TextStyle(
                          color: Colors.greenAccent,
                          background: Paint()
                            ..color = Colors.black
                            ..style = PaintingStyle.stroke),
                    )),
                // Change arrow direction to downward
              )
            : Container(),
      ],
    );
  }

  dialogDistrPoints(BuildContext context, MainModel model) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: ButtonBar(
                    children: <Widget>[
                      /*  OutlinedButton(
                          child: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pop();

                            dialogAreas(context, widget.model);
                          }),*/
                    ],
                  )),
            ],
            backgroundColor: Color(0xFF303030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                height: 380,
                width: 55,
                child: storesDialog(),
              ),
            ),
          );
        });
  }

  TextEditingController controller = new TextEditingController();
  dialogAreas(BuildContext context, MainModel model) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              /*  OutlineButton(
                  child: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pop();
                    dialogAreas(context, widget.model);
                  }),*/
              SizedBox(
                width: 50,
                height: 50,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                  // style: TextStyle(fontSize: 18.0),
                  //onChanged: onSearchTextChanged,
                ),
              ),

              /*    IconButton(
                alignment: AlignmentDirectional.centerEnd,
                icon: Icon(Icons.cancel, size: 20.0),
                onPressed: () {
                  controller.clear();
                  // onSearchTextChanged('');
                },
              ),*/
            ],
            backgroundColor: Color(0xFF303030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 380,
                  width: 55,
                  child: areasDialog(),
                )),
          );
        });
  }

  String type;
  bool isSelected = false;

  Widget storesDialog() {
    return Scrollbar(
        child: ListView.builder(
      itemCount: widget.model.stores.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            TextButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.amberAccent,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: widget.model.stores.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.model.stores[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    )
                  : Text('Data Loading error'),
              onPressed: () async {
                setState(() {
                  widget.model.setStoreId = widget.model.stores[index].storeId;
                  widget.model.distrPoint = widget.model.stores[index].region;
                  widget.model.distrPointName = widget.model.stores[index].name;
                  widget.model.docType = widget.model.stores[index].docType;
                  widget.model.setSpotId = widget.model.stores[index].spotId;
                });
                print('distrPoint:${widget.model.distrPoint}');
                //await widget.model.getPoints(widget.model.stores[index].region);
                print('setStore:${widget.model.setStoreId}');
                print('name:${widget.model.distrPointName}');
                print('DocType:==>${widget.model.docType}');
                print('setSpot:==>${widget.model.setSpotId}');
                await widget.model.getPoints(widget.model.stores[index].region);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ));
  }

  Widget areasDialog() {
    return Scrollbar(
        child: ListView.builder(
      itemCount: widget.model.areaList.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            TextButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlueAccent,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: widget.model.areaList.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.model.areaList[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    )
                  : Text('Data Loading error'),
              onPressed: () async {
                setState(() {
                  var _branch = widget.model.stores.firstWhere(
                      (s) => s.id == widget.model.areaList[index].branch);
                  widget.model.setStoreId = _branch.storeId;
                  widget.model.distrPoint = _branch.region;
                  widget.model.distrPointName = _branch.name;
                  widget.model.docType = _branch.docType;
                });

                //  await widget.model.getPoints(widget.model.stores[index].region);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ));
  }

  Widget _showNeedHelpButton() {
    return Padding(
      padding: widget.model.bulkOrder.length > 0 ||
              widget.model.itemorderlist.length > 0
          ? EdgeInsets.only(bottom: 26)
          : EdgeInsets.only(top: 16),
      child: Material(
        //Wrap with Material
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),

        elevation: 20.0,
        color: Colors.amber,
        clipBehavior: Clip.antiAliasWithSaveLayer, // Add This
        child: Opacity(
          opacity: widget.model.bulkOrder.length > 0 ||
                  widget.model.itemorderlist.length > 0
              ? .50
              : 1,
          child: MaterialButton(
            minWidth: 180.0,
            height: 30,
            color: Color(0xFF303030),
            child: Row(
              children: <Widget>[
                FadeTransition(
                  opacity: _animationController1,
                  child: Icon(GroovinMaterialIcons.map_marker_radius,
                      color: Colors.amber, size: 20),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                ),
                Text(
                  widget.model.distrPointNames,
                  style: TextStyle(
                      fontSize: 13,
                      // fontWeight: FontWeight.bold,
                      color: Colors.amber[50]),
                ),
              ],
            ),
            onPressed: widget.model.bulkOrder.length > 0 ||
                    widget.model.itemorderlist.length > 0
                ? () {}
                : () {
                    dialogDistrPoints(context, widget.model);
                  },
          ),
        ),
      ),
    );
  }
}

/*class GiftFloat extends StatefulWidget {
  final MainModel model;
  GiftFloat(this.model, {Key key}) : super(key: key);

  @override
  _GiftFloatState createState() => _GiftFloatState();
}

class _GiftFloatState extends State<GiftFloat>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Lock lock;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showNeedHelpButton();
  }

  String type;
  bool isSelected = false;

  Widget _showNeedHelpButton() {
    return CircleAvatar(
      child: Icon(Icons.card_giftcard),
    );
  }
}*/
