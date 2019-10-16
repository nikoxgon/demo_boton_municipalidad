import 'package:demo_boton/pages/root_page.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';

// void main() => runApp(TabBarDemo());
void main() => runApp(Demo());

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        // title: 'Flutter login',
        debugShowCheckedModeBanner: false,
        // theme: _themeApp(),
        
        home: new RootPage(auth: new Auth()));
  }
}
