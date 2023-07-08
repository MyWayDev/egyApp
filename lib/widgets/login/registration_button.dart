import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class RegistrationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(88, 36),
                maximumSize: Size(99, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                onPrimary: Theme.of(context).primaryColor,
                primary: Colors.pink[100],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "      تسجيل",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(
                    GroovinMaterialIcons.account_plus,
                    size: 36.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              onPressed: () => //Navigator.pushNamed(context, '/phoneAuth'),
                  Navigator.pushNamed(context, '/registration'),
            ),
          ),
        ],
      ),
    );
  }
}
