import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/pages/items/icon_bar.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/pages/items/itemDetails/details.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class ItemCard extends StatelessWidget {
  final List<Item> itemData;

  final int index;
  final bool isGuest;

  ItemCard(this.itemData, this.index, {this.isGuest = false});
  printPromo() {
    print('${itemData[index].promoImageUrl}');
  }

  @override
  Widget build(BuildContext context) {
    return !itemData[index].disabled
        ? Card(
            color: Colors.white,
            // color: Color(0xFFFFFFF1),
            elevation: 20.0,
            child: Column(children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      // color: Color.fromARGB(255, 66, 165, 245),
                      //  constraints: BoxConstraints.tight(Size(100, 100)),
                      child: Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          Image(
                              image: CachedNetworkImageProvider(
                            itemData[index].imageUrl ?? '',

                            //'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F${itemData[index].image[0].toString()}_${itemData[index].itemId}.png?alt=media&token=274fc65f-8295-43d5-909c-e2b174686439',
                            scale: 2.78,
                          )),

                          // : Container(),

                          itemData[index].promoImageUrl == " "
                              ? Container()
                              : Positioned(
                                  left: 3.0,
                                  child: Opacity(
                                      opacity: 0.70,
                                      child: Image(
                                          image: CachedNetworkImageProvider(
                                        itemData[index]
                                            .promoImageUrl, //  'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1540155801359_tag-50.png?alt=media',
                                        scale: 1.1,
                                      )

                                          //
                                          ))),
                        ],
                      ),
                    ),
                    Container(
                      child: Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.0),
                            ),

                            Text(
                              itemData[index].itemId,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color(0xFFFF8C00), //Colors.amber[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.0),
                            ),

                            Text(
                              itemData[index].name,
                              // textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.bold),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.0),
                            ),
                            itemData[index].size != null ||
                                    itemData[index].unit != null
                                ? Text(
                                    itemData[index].size.toString() +
                                        '  ' +
                                        itemData[index].unit,
                                    style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(''),

                            ////////////////////////////////////////////////////////
                            ScopedModelDescendant<MainModel>(builder:
                                (BuildContext context, Widget child,
                                    MainModel model) {
                              return Flex(
                                mainAxisSize: MainAxisSize.min,
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      IconBar(
                                        itemData,
                                        index,
                                        isGuest: isGuest,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),

                            Flex(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: !isGuest
                                      ? MainAxisAlignment.spaceEvenly
                                      : MainAxisAlignment.center,
                                  children: <Widget>[
                                    !isGuest
                                        ? Text(
                                            'جنيه ${itemData[index].priceFormat}',
                                            style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Text(
                                            'جنيه ${itemData[index].guestPriceFormat}',
                                            style: TextStyle(
                                                color: Colors.green[900],
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.bold),
                                          ),
                                    !isGuest
                                        ? Text(
                                            'نقاط  ${itemData[index].bp.toString()}',
                                            style: TextStyle(
                                                color: Colors.red[900],
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //
              ),
            ]),
          )
        : Container();
  }
}
