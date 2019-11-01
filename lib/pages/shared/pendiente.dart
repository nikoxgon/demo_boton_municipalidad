import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'map.dart';

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
          'assets/images/logo_white.png',
          height: 50,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _showAlarmSendMessage(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _showMap(),
        backgroundColor: Colors.green,
        child: Icon(FontAwesomeIcons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _showAlarmSendMessage() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(
                'ALARMA Y UBICACION ENVIADA',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),
            SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                )),
            Text(
              'ESPERANDO CONFIRMACION....',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
