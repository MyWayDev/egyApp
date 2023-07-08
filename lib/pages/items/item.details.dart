import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemDetails extends StatelessWidget {
  final Item item;

  ItemDetails(this.item);

  /*_showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone...'),
            actions: <Widget>[
              FlatButton(
                child: Text('Discard'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, false);
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(item.name),
            ),
            body: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image(image: CachedNetworkImageProvider(item.imageUrl ?? '')),

                Container(
                    padding: EdgeInsets.all(10.0), child: Text(item.name)),

                ///here price tag
                /* Container(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Text('Delete'),
                      onPressed: () => _showWarningDialog(context),
                    ))*/
                Container(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        item.usage,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
