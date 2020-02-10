import 'package:flutter/material.dart';

import '../encuesta.dart';

class Appbar extends StatelessWidget with PreferredSizeWidget {
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
