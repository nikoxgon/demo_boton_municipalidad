import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/root_page.dart';
import 'services/authentication.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(211, 52, 69, 1)
      ),
        debugShowCheckedModeBanner: false, home: RootPage(auth: Auth()));
  }
}
