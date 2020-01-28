import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';
import 'package:seam/services/authentication.dart';

class DirectionProvider extends ChangeNotifier {
  BaseAuth auth;
  GoogleMapsDirections directionsApi =
      GoogleMapsDirections(apiKey: 'AIzaSyARNazLGuM9cfrvzhU2LUvCXFD2KtlMUKQ');

  Set<maps.Polyline> _route = Set();

  Set<maps.Polyline> get currentRoute => _route;

  findDirections(maps.LatLng from, maps.LatLng to) async {
    var origin = Location(from.latitude, from.longitude);
    var destination = Location(to.latitude, to.longitude);

    var result = await directionsApi.directionsWithLocation(
      origin,
      destination,
      travelMode: TravelMode.driving,
    );

    Set<maps.Polyline> newRoute = Set();

    if (result.isOkay) {
      var route = result.routes[0];
      var leg = route.legs[0];

      List<maps.LatLng> points = [];

      leg.steps.forEach((step) {
        points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
        points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
      });

      var line = maps.Polyline(
        points: points,
        polylineId: maps.PolylineId("mejor ruta"),
        color: Colors.blue,
        width: 4,
      );
      newRoute.add(line);


      _route = newRoute;
      notifyListeners();
    } else {
    }
  }

  getDistance(Location origen, Location destino) {
    directionsApi
        .directionsWithLocation(
      origen,
      destino,
      travelMode: TravelMode.driving,
    )
        .then((onValue) {
      var _distance = onValue.routes.first.legs.first.distance.value;
      return _distance;
    });
  }

  getPatrullaDistance(destino, avisoID) {
    var fs = Firestore.instance;
    var patrullas = fs
        .collection('patrullas')
        .where('estado', isEqualTo: 'activo')
        .snapshots();
    patrullas.listen((data) {
      data.documents.forEach((doc) {
        Location origen =
            Location(double.parse(doc['lat']), double.parse(doc['lng']));
        directionsApi
            .directionsWithLocation(
          origen,
          destino,
          travelMode: TravelMode.driving,
        )
            .then((DirectionsResponse onValue) async {
          fs
              .collection('avisos')
              .document(avisoID)
              .collection('patrullas')
              .add({
            'patrullaID': doc.documentID,
            'distancia': onValue.routes.first.legs.first.distance.value,
            'lat': onValue.routes.first.legs.first.startLocation.lat,
            'lng': onValue.routes.first.legs.first.startLocation.lng
          });
          fs.collection('patrullas').document(doc.documentID).setData({
            'avisoID': avisoID,
            'estado': 'pendiente'
          }, merge: true);
        });
      });
    });
  }

/*
  _getUser() async {
    try {
      var _authUser = await FirebaseAuth.instance.currentUser();
    } catch (e) {
    }
  }
  */
}
