import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seam/pages/shared/showMap.dart';
import 'package:seam/services/authentication.dart';
import 'package:seam/services/directionsService.dart';

class PendientePage extends StatefulWidget {
  PendientePage({Key key, this.data, this.auth}) : super(key: key);

  final BaseAuth auth;
  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _PendientePageState();
}

class _PendientePageState extends State<PendientePage> {
  GoogleMapsDistanceServices _googleMapsDistanceServices =
      GoogleMapsDistanceServices();
  String message = 'BUSCANDO PATRULLA MAS CERCANA...';
  @override
  Widget build(BuildContext context) {
    _searchPatrulla();
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
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
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
        builder: (BuildContext context) => MapaPage(
              data: widget.data,
            )));
  }

  void _searchPatrulla() {
    GeoPoint __latlng = widget.data["latLng"];
    LatLng _latlng = LatLng(__latlng.latitude, __latlng.longitude);
    var user = {
      "id": widget.data["documentID"],
      "lat": _latlng.latitude,
      "lng": _latlng.longitude
    };
    List patrullas = new List();
    List seleccionada = new List();
    var snapshot = Firestore.instance
        .collection("patrullas")
        .where("estado", isEqualTo: "activo")
        .getDocuments();
    snapshot.then((action) {
      action.documents.forEach((f) async {
        var patrulla = {
          "id": f.documentID,
          "lat": double.parse(f.data["lat"]),
          "lng": double.parse(f.data["lng"]),
          "correo": f.data["correo"],
          "distancia": 0
        };
        patrulla["distancia"] =
            await _googleMapsDistanceServices.getRouteDistance(
                LatLng(
                    double.parse(f.data["lat"]), double.parse(f.data["lng"])),
                _latlng);
        patrullas.add(patrulla);
      });
      Future.delayed(Duration(seconds: 2), () {
        patrullas.forEach((f) {
          if (seleccionada.length == 0) {
            seleccionada.add(f);
          } else {
            if (seleccionada.first["distancia"] > f["distancia"]) {
              seleccionada.clear();
              seleccionada.add(f);
            }
          }
        });
        print(seleccionada);
        Firestore.instance.collection("avisos").document(user["id"]).updateData({
          "patrulla": seleccionada.first["correo"]
        }).then((onValue){
            message = "PATRULLA ENCONTRADA. ESPERANDO CONFIRMACIÓN...";
        });
      });
    });
  }
}
