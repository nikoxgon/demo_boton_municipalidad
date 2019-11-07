import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seam/services/authentication.dart';

import 'package:vibration/vibration.dart';

import './shared/selection.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Timer _timer;
  bool sendAlert = false;
  bool acceptAlert = false;

  Firestore fs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isEmailVerified = false;

  Text text;

  double lng = 0;
  double lat = 0;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();
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
    } catch (e) {
      print(e);
    }
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
                  setState(() {
                    lat = onValue.latitude;
                    lng = onValue.longitude;
                  });
                  DocumentReference user = await Auth().getUserId();
                  var _data = {
                    'latLng': GeoPoint(onValue.latitude, onValue.longitude),
                    'lat': onValue.latitude,
                    'lng': onValue.longitude,
                    'estado': 'Pendiente',
                    'userId': user
                  };
                  SnackBar(content: Text('Ingresado con exito.'));
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => SelectionPage(
                            data: _data,
                          )));
                });
                // print('-------- CANCELADO 1 -----------');
                _timer.cancel();
              }
            });
          } else if (!estado && _timer.isActive) {
            // print('-------- CANCELADO 2 -----------');
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

  // Widget _selectionButton() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       MaterialButton(
  //         child: Text('Domicilio'),
  //         onPressed: () {},
  //       ),
  //       MaterialButton(
  //         child: Text('Calle'),
  //         onPressed: () {},
  //       )
  //     ],
  //   );
  // }

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_white.png',
          height: 45,
        ),
        backgroundColor: Color.fromRGBO(228, 1, 51, 1),
        actions: <Widget>[
          new FlatButton(
              child: new Icon(FontAwesomeIcons.signOutAlt, color: Colors.white),
              onPressed: _signOut)
        ],
      ),
      body: _showAlarma(),
    );
  }
}
