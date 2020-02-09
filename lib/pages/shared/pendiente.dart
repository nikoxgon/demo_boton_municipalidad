import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seam/pages/shared/showMap.dart';
import 'package:seam/services/authentication.dart';
import 'package:seam/services/directionsService.dart';
import 'package:url_launcher/url_launcher.dart';

class PendientePage extends StatefulWidget {
  PendientePage({Key key, this.data, this.auth}) : super(key: key);

  final BaseAuth auth;
  final Map<String, dynamic> data;
  @override
  State<StatefulWidget> createState() => new _PendientePageState();
}

class _PendientePageState extends State<PendientePage> {
  GoogleMapsDistanceServices _googleMapsDistanceServices;
  String message;
  String message2;
  bool loading;
  bool nopatrullas;
  String patrullaID;

  @override
  void initState() {
    if (!mounted) return;
    _googleMapsDistanceServices = GoogleMapsDistanceServices();
    loading = true;
    nopatrullas = false;
    message = 'BUSCANDO PATRULLA MAS CERCANA...';
    message2 = '';
    super.initState();
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
        if (!snapshot.hasData && snapshot.data.data.isEmpty) {
          return Container(width: 0.0, height: 0.0);
        } else if (snapshot.data.data["estado"] == "Creado") {
          _searchPatrulla();
          return new Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Column(
                children: <Widget>[
                  Container(
                    height: 20.0,
                  ),
                  _showAlarmSendMessage(),
                ],
              ));
        } else if (snapshot.data.data["estado"] == "Asignado") {
          if (!loading) {
            return new MapaPage(data: widget.data, patrullaID: patrullaID);
          } else {
            return new Center(
              child: CircularProgressIndicator(),
            );
          }
        } else {
          return new Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _showAlarmSendMessage() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0))),
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    'ALERTA Y UBICACION ENVIADA',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                nopatrullas ? 
                Container( height: 0, width: 0)
                :
                SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                    )),
                Column(
                  children: <Widget>[
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      message2,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                Container(
                  child: Card(
                    elevation: 8.0,
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      leading: Icon(FontAwesomeIcons.desktop),
                      title: Text(
                        'Llamar a la central',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          call('+56964953030');
                        },
                        mini: true,
                        backgroundColor: Colors.green,
                        child: Icon(
                          FontAwesomeIcons.phone,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }

  void call(String number) => launch("tel:$number");

  void _searchPatrulla() {
    GeoPoint __latlng = widget.data["latLng"];
    LatLng _latlng = LatLng(__latlng.latitude, __latlng.longitude);
    var aviso = {
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
              .document(aviso["id"])
              .updateData({
            "patrulla": seleccionada.first["correo"],
            "patrulla_id": seleccionada.first["id"]
          }).then((onValue) {
            setState(() {
              message = 'PATRULLA ENCONTRADA.';
              message2 = 'ESPERANDO CONFIRMACIÓN...';
              loading = false;
            });
          });
        });
      } else {
        setState(() {
          nopatrullas = true;
          message = 'NO HAY PATRULLAS DISPONIBLES.';
        });
      }
    });
  }
}
