import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Item {
  String key;
  var id;
  String itemId;
  bool held;
  String name;
  var price;
  var bp;
  var bv;
  List image;
  String imageUrl;
  var size;
  String unit;
  String promo;
  List promoImage;
  String promoImageUrl;
  bool catalogue;
  bool nw;
  bool disabled;
  bool discont;
  var brand;
  List cat;
  List grp;
  String usage;
  var weight;
  var guestPrice;

  Item(
      {this.key,
      this.id,
      this.itemId,
      this.held,
      this.name,
      this.price,
      this.bp,
      this.bv,
      this.image,
      this.imageUrl,
      this.size,
      this.unit,
      this.promo,
      this.promoImage,
      this.promoImageUrl,
      this.catalogue,
      this.nw,
      this.disabled,
      this.discont,
      this.brand,
      this.cat,
      this.grp,
      this.usage,
      this.weight,
      this.guestPrice});

  final formatterPrice = NumberFormat("#,###.##");
  String get priceFormat {
    String _price;
    _price = formatterPrice.format(price);
    return _price;
  }

  final formatterGuest = NumberFormat("#,###.##");
  String get guestPriceFormat {
    String _guestPrice;
    _guestPrice = formatterGuest.format(guestPrice);
    return _guestPrice;
  }

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.key,
        itemId = snapshot.value['itemId'] ?? "",
        name = snapshot.value['name'] ?? "",
        price = snapshot.value['price'] ?? 0,
        bp = snapshot.value['bp'] ?? 0,
        bv = snapshot.value['bv'] ?? 0.0,
        held = snapshot.value['held'] ?? false,
        image = snapshot.value['image'] ?? [],
        imageUrl = snapshot.value['imageUrl'] ?? "",
        size = snapshot.value['size'] ?? "",
        unit = snapshot.value['unit'] ?? "",
        promo = snapshot.value['promo'] ?? "",
        promoImage = snapshot.value['promoImage'],
        promoImageUrl = snapshot.value['promoImageUrl'] ?? "",
        catalogue = snapshot.value['catalogue'],
        nw = snapshot.value['new'],
        disabled = snapshot.value['disable'] ?? false,
        discont = snapshot.value['discontinued'],
        brand = snapshot.value['brand'],
        cat = snapshot.value['catagory'],
        grp = snapshot.value['group'],
        usage = snapshot.value['usage'],
        weight = snapshot.value['weight'] ?? 0.0,
        guestPrice = snapshot.value['guestPrice'] ?? 0.0;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json[''],
        key: json['ITEM_ID'],
        itemId: json['ITEM_ID'],
        name: json['ANAME'] ?? "",
        price: json['PRICE'],
        bp: json['BP'],
        bv: json['BV'],
        promo: json['PROMO'],
        catalogue: json['CATALOG'] ?? false,
        discont: json['DISCONTINUED'],
        nw: json['NEW'],
        size: json['WEIGHT'],
        unit: json['WEIGHT_UNIT'],
        disabled: json['ENABLED'],
        held: json['HELD'] ?? false);
  }
  factory Item.fromList(Map<dynamic, dynamic> list) {
    return Item(
        key: list['key'],
        id: list['id'],
        held: list['held'] ?? false,
        itemId: list['itemId'],
        name: list['name'] ?? "",
        price: list['price'],
        bp: list['bp'],
        bv: list['bp'],
        image: list['image'],
        imageUrl: list['imageUrl'],
        size: list['size'],
        unit: list['unit'],
        promo: list['promo'],
        promoImage: list['promoImage'],
        promoImageUrl: list['promoImageUrl'],
        catalogue: list['catalogue'] ?? false,
        nw: list['new'],
        disabled: list['disable'],
        discont: list['discontinued']);
  }
  toJsonUpdate() {
    return {
      "id": id,
      "price": price,
      "bp": bp,
      "bv": bv,
      "promo": promo,
      "promoImageUrl": promoImageUrl,
      "catalogue": catalogue ?? false,
      "new": nw,
      "disable": disabled,
      "discontinued": discont,
      "HELD": held
    };
  }

  toJson() {
    return {
      "key": id,
      "itemId": itemId,
      "name": name ?? "",
      "price": price,
      "bp": bp,
      "bv": bv,
      "image": image,
      "imageUrl": imageUrl,
      "size": size,
      "unit": unit,
      "promo": promo,
      "promoImageUrl": promoImageUrl,
      "promoImage": promoImage,
      "catalogue": catalogue,
      "new": nw,
      "disable": disabled,
      "discontinued": discont,
    };
  }
}

class Products {
  String itemId;
  String name;
  var price;
  var bp;
  var bv;
  var weight;
  String promo;
  bool enabled;
  bool catalog;
  Products({
    this.itemId,
    this.name,
    this.price,
    this.bp,
    this.bv,
    this.weight,
    this.promo,
    this.enabled,
    this.catalog,
  });
  factory Products.fromList(Map<dynamic, dynamic> list) {
    return Products(
      itemId: list['ITEM_ID'],
      name: list['ANAME'] ?? "",
      price: list['PRICE'],
      bp: list['BP'],
      bv: list['BV'],
      promo: list['PROMO'],
      catalog: list['CATALOG'],
      enabled: list['ENABLED'],
    );
  }
}

class AggrItem {
  String id;
  bool held;
  int qty;
  int qtyOut;

  AggrItem({
    this.id,
    this.qty,
    this.held,
    this.qtyOut,
  });
}