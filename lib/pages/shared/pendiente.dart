import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  bool loading = true;
  String patrullaID;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    _searchPatrulla();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("avisos")
          .document(widget.data["documentID"])
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data.data["estado"] == "Creada") {
          return new Scaffold(
              appBar: new AppBar(
                title: Image.asset(
                  'assets/images/logo_white.png',
                  height: 45,
                ),
                centerTitle: true,
                backgroundColor: Color.fromRGBO(228, 1, 51, 1),
              ),
              body: _showAlarmSendMessage());
        } else {
          if (!loading) {
            return new MapaPage(
              data: widget.data,
              patrullaID: patrullaID
            );
          }
        }
      },
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
      if (action.documents.isNotEmpty) {
        action.documents.forEach((f) async {
          var patrulla = {
            "id": f.documentID,
            "lat": double.parse(f.data["lat"].toString()),
            "lng": double.parse(f.data["lng"].toString()),
            "correo": f.data["correo"],
            "distancia": 0
          };
          patrulla["distancia"] =
              await _googleMapsDistanceServices.getRouteDistance(
                  LatLng(double.parse(f.data["lat"].toString()),
                      double.parse(f.data["lng"].toString())),
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
          patrullaID = seleccionada.first["id"];
          Firestore.instance
              .collection("avisos")
              .document(user["id"])
              .updateData({"patrulla": seleccionada.first["correo"]}).then(
                  (onValue) {
            message = "PATRULLA ENCONTRADA. ESPERANDO CONFIRMACIÓN...";
            loading = false;
          });
        }
        );
      }
    });
  }
}
