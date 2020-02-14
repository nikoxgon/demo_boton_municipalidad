import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seam/services/authentication.dart';

import '../encuesta.dart';

class Appbar extends StatelessWidget with PreferredSizeWidget {
  Appbar({@required this.auth, @required this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
                fullscreenDialog: true,
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => EncuestaPage()));
          },
          child: Image.asset(
            'assets/images/logo_white.png',
            height: 45,
          )),
      backgroundColor: Theme.of(context).primaryColor,
      actions: <Widget>[
        new FlatButton(
            child: new Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
            onPressed: _signOut)
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {}
  }
}
