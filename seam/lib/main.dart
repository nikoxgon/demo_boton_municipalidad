import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/root_page.dart';
import 'providers/DirectionsProvider.dart';
import 'services/authentication.dart';

// void main() => runApp(TabBarDemo());
void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        builder: (_) => DirectionProvider(),
        child: MaterialApp(
            // title: 'Flutter login',

            debugShowCheckedModeBanner: false,
            // theme: _themeApp(),

            home: RootPage(auth: Auth())));
  }
}
