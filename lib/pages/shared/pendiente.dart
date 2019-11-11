import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:provider/provider.dart';
import 'package:seam/providers/DirectionsProvider.dart';

import 'map.dart';

class PendientePage extends StatefulWidget {
  PendientePage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _PendientePageState();
}

class _PendientePageState extends State<PendientePage> {
  String message = 'BUSCANDO PATRULLA MAS CERCANA...';
  @override
  Widget build(BuildContext context) {
    _searchPatrullas();
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/images/logo_white.png',
          height: 45,
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(228, 1, 51, 1),
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
                'ALERTA Y UBICACION ENVIADA',
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
              message,
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

  _searchPatrullas() {
    var fs = Firestore.instance;
    var origen = Location(widget.data['lat'], widget.data['lng']);
    var patrullas = fs
        .collection('patrullas')
        .where('estado', isEqualTo: 'activo')
        .snapshots()
    
  }

  _getPatrullaSeleccionada(origen, patrullas) {
    var api = Provider.of<DirectionProvider>(context);
    patrullas.then((onValue) {
      String patrullaId;
      int patrullaDistancia = 0;
      onValue.documents
        .forEach((values) async {
          var destino = Location(values.data['lat'], values.data['lng']);
          int distancia = await api.getDistance(origen, destino);
          print(values.documentID);
          print(distancia);
          if (patrullaDistancia == 0) {
            patrullaId = values.documentID;
            patrullaDistancia = distancia;
          } else {
            if (distancia < patrullaDistancia) {
              patrullaId = values.documentID;
              patrullaDistancia = distancia;
            }
          }
        });
      print(patrullaId);
      this.message = 'ESPERANDO CONFIRMACION...';
    }).catchError((onError) {
      print(onError);
    });
  }
}
