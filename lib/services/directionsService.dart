import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = "AIzaSyARNazLGuM9cfrvzhU2LUvCXFD2KtlMUKQ";

class GoogleMapsServices {
  Future<Map<String, dynamic>> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    var data = {
      "tiempo": values["routes"][0]["legs"][0]["duration"]["text"],
      "distancia": values["routes"][0]["legs"][0]["distance"]["text"],
      "ruta": values["routes"][0]["overview_polyline"]["points"]
    };
    // print("Tiempo estimado: " + values["routes"][0]["legs"][0]["duration"]["text"]);
    // print("Distancia: " + values["routes"][0]["legs"][0]["distance"]["text"]);
    // print(values["routes"][0]["overview_polyline"]["points"]);
    return data;
  }
}

class GoogleMapsDistanceServices {
  Future<String> getRouteDistance(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${l1.latitude},${l1.longitude}&destinations=${l2.latitude},${l2.longitude}&key=$apiKey";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    // print(values);
    return values["rows"][0]["elements"][0]["distance"]["text"];
  }
}
