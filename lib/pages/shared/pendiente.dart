import 'package:demo_boton/pages/shared/map.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PendientePage extends StatefulWidget {
  PendientePage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _PendientePageState();
}

class _PendientePageState extends State<PendientePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/logo_independencia.png',
          height: 40,
        ),
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
      ),
      body: _showAlarmSendMessage(),
    );
  }

  Widget _showAlarmSendMessage() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'ALARMA Y UBICACION ENVIADA',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'ESPERANDO CONFIRMACION....',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                  width: 100, height: 100, child: CircularProgressIndicator()),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                onPressed: () => _showMap(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(FontAwesomeIcons.map),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Mostrar Mapa'),
                      )
                    ]),
              ),
            )
          ]),
    );
  }

  void _showMap() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => MapPage(
              data: widget.data,
            )));
  }
}
