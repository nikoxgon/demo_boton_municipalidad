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

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
}