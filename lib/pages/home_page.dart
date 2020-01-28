import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seam/pages/encuesta.dart';
import 'package:seam/services/authentication.dart';

import 'package:vibration/vibration.dart';

import './shared/selection.dart';
import 'shared/showMap.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.userEmail, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String userEmail;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer _timer;
  bool sendAlert = false;
  bool acceptAlert = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isEmailVerified = false;
  Text text;
  Map<String, bool> checkboxValues = {
    "Muy Buena": true,
    "Buena": false,
    "Regular": false,
    "Mala": false,
    "Pesima": false
  };

  @override
  void initState() {
    if (!mounted) return;
    // print(widget.userEmail);
    _checkEmailVerification();
    super.initState();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifica tu cuenta"),
          // backgroundColor: Color.fromRGBO(21, 19, 18, 1),
          titleTextStyle: TextStyle(color: Colors.black54),
          content: new Text(
              "Porfavor verifica tu cuenta con el link enviado a tu correo."),
          contentTextStyle: TextStyle(color: Colors.black54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Reenviar"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Omitir"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {}
  }

  Widget _showButton() {
    if (!sendAlert) {
      return RawMaterialButton(
        fillColor: Color.fromRGBO(228, 1, 51, 1),
        highlightColor: Colors.red.shade700,
        elevation: 10,
        constraints: BoxConstraints(
            minWidth: 250, minHeight: 250, maxWidth: 250, maxHeight: 250),
        child:
            Icon(FontAwesomeIcons.exclamation, color: Colors.white, size: 130),
        highlightElevation: 0,
        shape: CircleBorder(
            side: BorderSide(
          color: Colors.grey.shade400,
          width: 5,
        )),
        onHighlightChanged: (estado) {
          if (estado) {
            _timer = Timer.periodic(Duration(seconds: 1), (callback) async {
              if (_timer.tick > 2) {
                // AudioCache audioCache =
                //    new AudioCache(fixedPlayer: audioPlayer);
                // audioCache.load('audio/beep.mp3').then((onValue) {
                //  audioCache.loop('audio/beep.mp3',
                //      mode: PlayerMode.LOW_LATENCY);
                // });
                Vibration.vibrate();
                await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                    .then((onValue) async {
                  await Geolocator()
                      .placemarkFromCoordinates(
                          onValue.latitude, onValue.longitude)
                      .then((val) {
                    // print(val);
                    var _data = {
                      'latLng': GeoPoint(onValue.latitude, onValue.longitude),
                      'lat': onValue.latitude,
                      'lng': onValue.longitude,
                      'direccion': val.first.name,
                      'estado': 'Creado',
                      'userId': widget.userEmail
                    };
                    SnackBar(content: Text('Ingresado con exito.'));
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => SelectionPage(
                              data: _data,
                            )));
                  });
                });
                _timer.cancel();
              }
            });
          } else if (!estado && _timer.isActive) {
            _timer.cancel();
          }
        },
        onPressed: () {},
      );
    } else {
      return null;
    }
  }

  Widget _showButtonTextAlarm() {
    if (!sendAlert) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        child: Text(
          'PARA EMERGENCIAS PRESIONE EL BOTON POR AL MENOS 3 SEGUNDOS',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return null;
    }
  }

  Widget _showAlarma() {
    return Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _showButton(),
            _showButtonTextAlarm(),
            // _showAlarmSendMessage(),
            // _showMapNavegation(),
            // _showMapCall(),
            // _selectionButton()
          ].where((children) => children != null).toList(),
        ));
  }

  Widget _verificarAviso() {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("avisos")
                .where("estado", isEqualTo: "Asignado")
                .where("userId", isEqualTo: widget.userEmail)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // print(snapshot.data.documents.isEmpty);
              if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                return _showAlarma();
              } else {
                // print(snapshot.data.documents.first.data);
                return new MapaPage(
                    data: {
                      "documentID": snapshot.data.documents.first.documentID,
                      "patrullaEmail":
                          snapshot.data.documents.first.data["patrulla"]
                    },
                    patrullaID:
                        snapshot.data.documents.first.data["patrulla_id"],
                    avisoID: snapshot.data.documents.first.documentID);
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                fullscreenDialog: true,
                  opaque: false,
                  pageBuilder: (BuildContext context, _, __) =>
                      EncuestaPage()));
            },
            child: Image.asset(
              'assets/images/logo_white.png',
              height: 45,
            )),
        backgroundColor: Color.fromRGBO(228, 1, 51, 1),
        actions: <Widget>[
          new FlatButton(
              child: new Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
              onPressed: _signOut)
        ],
      ),
      body: _verificarAviso(),
    );
  }
}
