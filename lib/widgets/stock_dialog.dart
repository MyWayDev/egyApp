import 'dart:async';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/pages/items/itemDetails/details.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class StockDialog extends StatefulWidget {
  final List<Item> itemData;
  final int qty;
  final int index;
  final bool pop;
  final bool isGuest;
  StockDialog(this.itemData, this.index, this.qty,
      {this.pop = false, this.isGuest = false});
  @override
  State<StatefulWidget> createState() {
    return _StockDialog();
  }
}

@override
class _StockDialog extends State<StockDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void isLoading(bool o) {
    setState(() {
      _loading = o;
    });
  }

  bool _loading = false;

  final ModelData _data = ModelData.empty();

  Future<bool> isGetStock(MainModel model, String itemId) async {
    bool _loading;
    int x = await model.getStock(itemId);
    x != null ? _loading = false : _loading = true;
    return _loading;
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return !model.cartLocked
          ? _stockDialog(context, widget.itemData, widget.index, widget.qty)
          : Container();
    });
  }

  Widget _stockDialog(
      BuildContext context, List<Item> itemData, int index, int qty) {
    return ModalProgressHUD(
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            height: 250.0,
            width: 145.0,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
            child: Column(children: <Widget>[
              Container(
                child: Flexible(
                  flex: 1,
                  child: Column(children: <Widget>[
                    ScopedModelDescendant<MainModel>(builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return Column(
                        children: [
                          Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                !widget.isGuest
                                    ? Text(
                                        ' نقاط ${itemData[index].bp.toString()}',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[900]),
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: widget.isGuest ? 60 : 1),
                                  child: CircleAvatar(
                                    minRadius: 40,
                                    maxRadius: 40,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: NetworkImage(
                                        itemData[index].imageUrl,
                                        scale: 0.3),
                                  ),
                                ),
                                !widget.isGuest
                                    ? Text(
                                        'جنيه ${itemData[index].priceFormat}',
                                        style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'جنيه ${itemData[index].guestPriceFormat}',
                                        style: TextStyle(
                                            color: Colors.green[900],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ]),
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: model.iheld(widget.index)
                                ? Stack(children: <Widget>[
                                    IconButton(
                                      onPressed: () => {},
                                      icon: Badge(
                                        position: BadgePosition(
                                          bottom: 14,
                                          start: 10,
                                          isCenter: false,
                                        ),
                                        animationDuration:
                                            const Duration(microseconds: 450),
                                        animationType: BadgeAnimationType.scale,
                                        badgeContent: Text(
                                          '$qty',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        // required

                                        child: Icon(
                                          Icons.shopping_cart,
                                          color: Colors.pink[900],
                                          size: 36.0,
                                        ),

                                        // required
                                        badgeColor: Colors.amber[400],
                                      ),
                                    ),
                                    Positioned(
                                        right: 18,
                                        bottom: 33,
                                        child: Icon(
                                            GroovinMaterialIcons
                                                .arrow_down_bold,
                                            color: Colors.blue,
                                            size: 21)),
                                  ])
                                : Badge(
                                    showBadge: qty == 0 ? false : true,
                                    badgeContent: Text(
                                      '$qty',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    // required
                                    child: Icon(
                                      Icons.shopping_cart,
                                      color: Colors.pink[900],
                                      size: 36.0,
                                    ), // required
                                    badgeColor: Colors.red,
                                  ),
                          ),
                        ],
                      );
                    }),
                  ]),
                ),
              ),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _data.number = int.parse(value);
                },
              ),
              ScopedModelDescendant<MainModel>(builder:
                  (BuildContext context, Widget child, MainModel model) {
                model.settingsData();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        size: 33.0,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        int _stock =
                            await model.getStock(itemData[index].itemId);
                        var qtyOrder = model.getItemBulkQty(itemData[index]) +
                            model.getItemOrderQty(itemData[index]);
                        if (_data.number > 0 && itemData[index].held) {
                          isLoading(true);
                          _stock >= (qtyOrder - _data.number)
                              ? model.removeItemOrder(
                                  itemData[index], _data.number, false)
                              : model.removeItemOrder(
                                  itemData[index], _data.number, true);
                          Navigator.pop(context);
                        } else if (_data.number > 0) {
                          model.removeItemOrder(itemData[index], _data.number);
                          Navigator.pop(context);
                        }
                        isLoading(false);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        size: 33.0,
                        color: Colors.green,
                      ),
                      onPressed: () async {
                        var qtyOrder = _data.number +
                            model.getItemBulkQty(itemData[index]) +
                            model.getItemOrderQty(itemData[index]);
                        bool _limited =
                            model.limited(int.parse(itemData[index].key));
                        if (_data.number > 0) {
                          bool t = true;
                          isLoading(t);
                          bool x =
                              await isGetStock(model, itemData[index].itemId);
                          int _stock =
                              await model.getStock(itemData[index].itemId);
                          if (itemData[index].held &&
                              !model.user.isGuest &&
                              _stock - model.settings.safetyStock < qtyOrder &&
                              qtyOrder <= model.settings.maxOrder) {
                            model.addItemOrder(
                                itemData[index], _data.number, true);
                            model.itemorderlist.forEach((i) =>
                                print('itemStatus: ${i.itemId}=>${i.held}'));
                            Navigator.pop(context);
                            isLoading(x);
                          } else {
                            if (!_limited) {
                              if (_data.number != 0 &&
                                  _stock >= 1 &&
                                  _stock >=
                                      _data.number +
                                          model
                                              .getItemBulkQty(itemData[index]) +
                                          model.getItemOrderQty(
                                              itemData[index]) &&
                                  _stock - model.settings.safetyStock >=
                                      _data.number +
                                          model.getItemOrderQty(
                                              itemData[index]) &&
                                  _data.number +
                                          model.getItemOrderQty(
                                              itemData[index]) <=
                                      model.settings.maxOrder) {
                                model.addItemOrder(
                                    itemData[index], _data.number, false);
                                model.itemorderlist.forEach((i) => print(
                                    'itemStatus: ${i.itemId}=>${i.held}'));
                                Navigator.pop(context);
                                isLoading(x);
                              } else {
                                Navigator.pop(context);
                                _stockAlert(
                                    context,
                                    _stock,
                                    model.settings.maxOrder,
                                    model.settings.safetyStock,
                                    model.getItemOrderQty(itemData[index]));
                              }
                            } else {
                              if (_data.number != 0 &&
                                  _stock >= 1 &&
                                  _stock >=
                                      _data.number +
                                          model
                                              .getItemBulkQty(itemData[index]) +
                                          model.getItemOrderQty(
                                              itemData[index]) &&
                                  _stock - model.settings.safetyStock >=
                                      _data.number +
                                          model.getItemOrderQty(
                                              itemData[index]) &&
                                  _data.number +
                                          model.getItemOrderQty(
                                              itemData[index]) <=
                                      model.settings.maxLimited) {
                                model.addItemOrder(
                                    itemData[index], _data.number, false);
                                model.itemorderlist.forEach((i) => print(
                                    'itemStatus: ${i.itemId}=>${i.held}'));
                                Navigator.pop(context);
                                isLoading(x);
                              } else {
                                Navigator.pop(context);
                                _stockAlert(
                                    context,
                                    _stock,
                                    model.settings.maxLimited,
                                    model.settings.safetyStock,
                                    model.getItemOrderQty(itemData[index]));
                              }
                            }
                          }
                        }
                        if (widget.pop) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Details(
                                  itemData[index],
                                  model.getCaouselItems(itemData[index]),
                                ),
                              ));
                        }
                      },
                    ),
                  ],
                );
              }),
            ])),
      ),
      inAsyncCall: _loading,
      opacity: 0.6,
      progressIndicator: LinearProgressIndicator(),
    );
  }

  Future<Widget> _stockAlert(BuildContext context, int stock, int maxOrder,
      int safetyStock, int ordered) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('')),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: _data.number + ordered > maxOrder || _data.number < 0
                    ? Text(
                        ' $maxOrder الحد الاقصى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    : stock - safetyStock < 1
                        ? Text(
                            'الكميه المتاحه 0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Text(
                            ' الكميه المتاحه ${stock - safetyStock}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }
}

class ModelData {
  String text;
  int number;

  ModelData(this.text, this.number);

  ModelData.empty() {
    text = "";
    number = 0;
  }
}
