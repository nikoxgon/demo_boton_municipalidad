import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_boton/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:vibration/vibration.dart';

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
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioCache audioCache;

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
        fillColor: Colors.red.shade500,
        highlightColor: Colors.red.shade800,
        elevation: 2,
        constraints: BoxConstraints(
            minWidth: 250, minHeight: 250, maxWidth: 250, maxHeight: 250),
        child:
            Icon(FontAwesomeIcons.exclamation, color: Colors.white, size: 130),
        highlightElevation: 10,
        shape: CircleBorder(
            side: BorderSide(
          color: Colors.grey.shade400,
          width: 5,
        )),
        onHighlightChanged: (estado) {
          if (estado) {
            Vibration.vibrate();
            _timer = Timer.periodic(Duration(seconds: 1), (callback) async {
              if (_timer.tick > 2) {
                // AudioCache audioCache =
                //    new AudioCache(fixedPlayer: audioPlayer);
                // audioCache.load('audio/beep.mp3').then((onValue) {
                //  audioCache.loop('audio/beep.mp3',
                //      mode: PlayerMode.LOW_LATENCY);
                // });
                await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                    .then((onValue) {
                  final fb = Firestore.instance;
                  fb.collection('latlng').add({
                    'lat': onValue.latitude,
                    'lng': onValue.longitude
                  }).then((val) {
                    Vibration.cancel();
                    setState(() {
                      sendAlert = true;
                      lat = onValue.latitude;
                      lng = onValue.longitude;
                      // audioPlayer.stop();
                    });
                    SnackBar(content: Text('Ingresado con exito.'));
                  }).catchError((onError) {
                    SnackBar(content: Text('Error.'));
                    // print(onError);
                  });
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

  Widget _showAlarmSendMessage() {
    if (sendAlert && !acceptAlert) {
      return Card(
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
                width: 300, height: 300, child: CircularProgressIndicator()),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: IconButton(
              icon: Icon(FontAwesomeIcons.map),
              onPressed: () {
                setState(() {
                  acceptAlert = true;
                });
              },
            ),
          )
        ]),
      );
    } else {
      return null;
    }
  }

  Widget _showMapNavegation() {
    if (acceptAlert) {
      Completer<GoogleMapController> _controller = Completer();
      final CameraPosition _kGooglePlex = CameraPosition(
        target: LatLang(lat, lng),
        zoom: 14.4746,
      );
      return Expanded(
          flex: 7,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ));
    } else {
      return null;
    }
  }

  void call(String number) => launch("tel:$number");

  Widget _showMapCall() {
    if (acceptAlert) {
      return Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                child: Text(
                  'Si necesita llamar al movil, \n solo apriete el boton',
                  style: TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: FloatingActionButton(
                  onPressed: () {
                    call('+56964953030');
                  },
                  child: Icon(Icons.call),
                  backgroundColor: Colors.green,
                  tooltip: 'Llamar Patrulla',
                ),
              )
            ],
          ));
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
            _showAlarmSendMessage(),
            _showMapNavegation(),
            _showMapCall()
          ].where((children) => children != null).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/logo_independencia.png',
          height: 40,
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          new FlatButton(
              child:
                  new Icon(FontAwesomeIcons.signOutAlt, color: Colors.indigo),
              onPressed: _signOut)
        ],
      ),
      body: _showAlarma(),
    );
  }
}
