import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmaTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AlarmaTabState();
}

class AlarmaTabState extends State<AlarmaTab> {
  @override
  Widget build(BuildContext context) {
    Text text;
    AudioPlayer audioPlayer = new AudioPlayer();
    AudioCache audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.load('audio/beep.mp3');
    return Scaffold(
      appBar: AppBar(
        title: text,
      ),
      body: Center(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            fillColor: Colors.red.shade500,
            elevation: 30,
            highlightColor: Colors.red.shade800,
            highlightElevation: 100,
            shape: CircleBorder(),
            onPressed: () async {
              Vibration.vibrate(duration: 10000);
              audioCache.loop('audio/beep.mp3', mode: PlayerMode.LOW_LATENCY);
              await Geolocator()
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                  .then((onValue) {
                final fb = Firestore.instance;
                fb.collection('latlng').add({
                  'lat': onValue.latitude,
                  'lng': onValue.longitude
                }).then((val) {
                  SnackBar(content: Text('Ingresado con exito.'));
                }).catchError((onError) {
                  SnackBar(content: Text('Error.'));
                  print(onError);
                });
                setState(() {
                  text = Text(onValue.latitude.toString());
                  Vibration.cancel();
                  audioPlayer.stop();
                });
              });
            },
            constraints: BoxConstraints(
                minWidth: 300, minHeight: 300, maxWidth: 500, maxHeight: 500),
            child: Icon(Icons.phonelink_ring, color: Colors.white, size: 100),
          ),
        ],
      )),
    );
  }
}
