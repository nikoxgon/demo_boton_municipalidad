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

  // print(res.status);
  if (res.isOkay) {
    // print('${res.routes.length} routes');
    for (var r in res.routes) {
      // print(r.summary);
      // print(r.bounds);
    }
  } else {
    // print(res.errorMessage);
  }

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
    // print('response ${responseForLocation.status}');

    if (responseForLocation.isOkay) {
      // print(responseForLocation.destinationAddress.length);
      for (var row in responseForLocation.results) {
        for (var element in row.elements) {
          // print(
              // 'distance ${element.distance.text} duration ${element.duration.text}');
        }
      }
    } else {
      // print('ERROR: ${responseForLocation.errorMessage}');
    }
  } finally {
    distanceMatrix.dispose();
  }
}
