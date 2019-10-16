import 'package:demo_boton/pages/root_page.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';

// void main() => runApp(TabBarDemo());
void main() => runApp(Demo());

_themeApp() {
  return new ThemeData(
      primaryColor: Color.fromRGBO(54, 58, 129, 1),
      accentColor: Color.fromRGBO(204, 185, 176, 1),
      buttonColor: Color.fromARGB(228, 1, 51, 1),
      dialogBackgroundColor: Color.fromRGBO(21, 19, 18, 1),
      tabBarTheme: TabBarTheme(
        labelColor: Color.fromRGBO(54, 58, 129, 1),
        unselectedLabelColor: Color.fromRGBO(204, 185, 176, 1)
      ),
      indicatorColor: Color.fromRGBO(54, 58, 129, 1),
      hintColor: Colors.white70);
}

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
