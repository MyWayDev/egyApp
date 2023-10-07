import 'package:badges/badges.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/pages/items/itemDetails/details.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/stock_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class IconBar extends StatefulWidget {
  final List<Item> itemData;
  final int index;
  final bool isGuest;
  IconBar(this.itemData, this.index, {this.isGuest = false});
  @override
  State<StatefulWidget> createState() {
    return _IconBar();
  }
}

@override
class _IconBar extends State<IconBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              !model.cartLocked
                  ? Stack(
                      children: <Widget>[
                        !model.iheld(widget.index)
                            ? IconButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => StockDialog(
                                      widget.itemData,
                                      widget.index,
                                      model.iCount(widget.index),
                                      isGuest: widget.isGuest,
                                    ),
                                  );
                                },
                                icon: model.iCount(widget.index) > 0
                                    ? Badge(
                                        position: BadgePosition(
                                          bottom: 14,
                                          start: 10,
                                          isCenter: false,
                                        ),
                                        alignment: Alignment.center,
                                        animationDuration:
                                            const Duration(microseconds: 450),
                                        animationType: BadgeAnimationType.scale,
                                        badgeContent: Text(
                                          '${model.iCount(widget.index)}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        badgeColor: !model.iheld(widget.index)
                                            ? Colors.red
                                            : Colors.amber[400],
                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.pink[900],
                                          size: 32.0,
                                        ),
                                      )
                                    : Icon(
                                        Icons.shopping_cart,
                                        color: Colors.pink[900],
                                        size: 32.0,
                                      ),
                              )
                            : Stack(
                                children: <Widget>[
                                  IconButton(
                                    icon: Badge(
                                      position: BadgePosition(
                                        bottom: 14,
                                        start: 10,
                                        isCenter: false,
                                      ),
                                      animationDuration:
                                          const Duration(microseconds: 450),
                                      animationType: BadgeAnimationType.scale,
                                      badgeColor: Colors.amber[400],
                                      badgeContent: Text(
                                        '${model.iCount(widget.index)}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.pink[900],
                                        size: 32.0,
                                      ),
                                    ),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (_) => StockDialog(
                                              widget.itemData,
                                              widget.index,
                                              model.iCount(widget.index)));
                                    },
                                  ),
                                  Positioned(
                                      right: 18,
                                      bottom: 33,
                                      child: Icon(
                                        GroovinMaterialIcons.arrow_down_bold,
                                        color: Colors.blue,
                                      )),
                                ],
                              )
                      ],
                    )
                  : IconButton(
                      icon: Badge(
                        alignment: Alignment.center,
                        animationDuration: const Duration(microseconds: 450),
                        animationType: BadgeAnimationType.scale,
                        badgeContent: Text(
                          '${model.iCount(widget.index)}',
                          style: TextStyle(color: Colors.white),
                        ),
                        badgeColor: Colors.grey,
                        child: Icon(
                          Icons.remove_shopping_cart,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      ),
                      // required
                      //badgeColor: Colors.pink[900],
                      onPressed: () {}),
              Padding(
                padding: EdgeInsets.only(
                    left: 6.0,
                    right: 6.0), //?make after  removing print icon right:6
              ),
              IconButton(
                  icon: Icon(Icons.info_outline),
                  iconSize: 30.0,
                  color: Colors.blueAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          widget.itemData[widget.index],
                          model.getCaouselItems(widget.itemData[widget.index]),
                        ),
                      ),
                    );
                  }),
            ],
          )
        ],
      );
    });
  }
}
