library google_maps_webservice.directions.example;

import 'dart:async';
import 'dart:io';

import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/distance.dart';

final directions = GoogleMapsDirections(
    apiKey: Platform.environment['AIzaSyARNazLGuM9cfrvzhU2LUvCXFD2KtlMUKQ']);
final GoogleDistanceMatrix distanceMatrix = GoogleDistanceMatrix(
    apiKey: Platform.environment['AIzaSyARNazLGuM9cfrvzhU2LUvCXFD2KtlMUKQ']);

Future<void> direction() async {
  DirectionsResponse res =
      await directions.directionsWithAddress('Paris, France', 'Rennes, France');
  if (res.isOkay) {
    for (Route r in res.routes) {
      print(r);
    }
  } else {}

  directions.dispose();
}

Future<void> distance() async {
  List<Location> origins = [
    Location(23.721160, 90.394435),
    Location(23.732322, 90.385142),
  ];
  List<Location> destinations = [
    Location(23.726346, 90.377117),
    Location(23.748519, 90.403121),
  ];

  DistanceResponse responseForLocation =
      await distanceMatrix.distanceWithLocation(
    origins,
    destinations,
  );

  try {
    if (responseForLocation.isOkay) {
      for (var row in responseForLocation.results) {
        for (Element element in row.elements) {
          print(element);
        }
      }
    } else {}
  } finally {
    distanceMatrix.dispose();
  }
}
