import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginBanner extends StatelessWidget {
  final String bannerUrl;
  //Map<String, String> title = {('title' 'dafd'): ('header' 'adfad')};
  LoginBanner(this.bannerUrl);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return new ClipPath(
        clipper: MyClipper(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: model.appLocked
                  ? CachedNetworkImageProvider(
                      'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2Fsized%2F375_9999_100%2Flock-red.png?alt=media&token=da76137e-b12d-43f9-86ca-6f075808aa24',
                      scale: 3,
                    )
                  : CachedNetworkImageProvider(this.bannerUrl,
                      scale:
                          0.5), //AssetImage("assets/images/adbanner.png"), //!! need to change it to networkImagae & make it dynamic
              // fit: BoxFit.cover,
              /* */
            ),
          ),
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: 85.0),
          child: Column(
            children: <Widget>[
              Text(
                "v5.2R1",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 186, 186, 106),
                ),
              ),
              Text(
                "",
                style: TextStyle(
                    fontSize: 70.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.90);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(100.0, 100.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
/* */
