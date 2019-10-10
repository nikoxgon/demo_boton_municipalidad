import 'package:demo_boton/pages/root_page.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';
import 'alarma.dart';
import 'misdatos.dart';
import 'login.dart';

// void main() => runApp(TabBarDemo());
void main() => runApp(Demo());

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _ThemeApp(),
      initialRoute: '/login',
      routes: {'/login': (context) => SignInPage()},
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Alarma'),
                Tab(text: 'Mis Datos'),
                Tab(text: 'Tabla'),
              ],
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.indigoAccent.shade100,
            ),
            title: Text('Boton de panico'),
            backgroundColor: Colors.indigoAccent.shade700,
          ),
          body: TabBarView(
            children: [
              AlarmaTab(),
              MisDatosTab(),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}

_ThemeApp() {
  return new ThemeData(
      primaryColor: Color.fromRGBO(54, 58, 129, 1),
      accentColor: Color.fromRGBO(246, 175, 50, 1),
      hintColor: Colors.white70);
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        // title: 'Flutter login',
        debugShowCheckedModeBanner: false,
        theme: _ThemeApp(),
        home: new RootPage(auth: new Auth()));
  }
}
