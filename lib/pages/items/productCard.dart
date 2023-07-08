import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/models/item.dart';

buildCard(Item product) {
  return !product.disabled
      ? Padding(
          padding: EdgeInsets.all(2),
          child: Card(
            elevation: 3,
            child: Container(
              height: 136,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
              child: GridTile(
                header: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Text(
                              '%\ -${product.promo.toString()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink[900],
                                  fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Text(
                              '${product.itemId}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ]),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: imageIcon(product),
                    )
                  ],
                ),
                footer: _buildPriceRating(product),
                child: Container(),
              ),
            ),
          ),
        )
      : Container();
}

Padding _buildPriceRating(Item product) {
  return Padding(
    padding: EdgeInsets.all(6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _titlePrice(product),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                product.name,
                textDirection: TextDirection.rtl,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          ],
        ),

        // showStarRating(3.0, product.color)
      ],
    ),
  );
}

Text description(Item product) {
  return Text(
    product.name,
    maxLines: 2,
  );
}

Column _titlePrice(Item product) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            ' ${product.price}جنيه\ ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'نقاط\ ${product.bp.toString()}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
                fontSize: 13),
          ),
        ),
      ]);
}

Image imageIcon(Item product) {
  return Image(
      image: CachedNetworkImageProvider(
    product.imageUrl,
    scale: 2.9,
  ));
  /*Image.network(
    product.imageUrl,
    scale: 2.9,
    height: 120,
    width: 120,
  );*/
}
