import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:seam/services/directionsService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

class MapaPage extends StatefulWidget {
  // final maps.LatLng fromPoint = maps.LatLng(-34.187387, -70.675984);
  final maps.LatLng toPoint = maps.LatLng(-34.180663, -70.708399);

  MapaPage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<StatefulWidget> createState() => new _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  bool loading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapsDistanceServices _googleMapsDistanceServices =
      GoogleMapsDistanceServices();
  String _distance = "Obteniendo Ubicación...";
  String _tiempo = "";
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  static LatLng latLng;
  double accuracy;
  LocationData currentLocation;

  @override
  void initState() {
    getLocation();
    loading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: loading
              ? Container()
              : GoogleMap(
                  polylines: polyLines,
                  markers: _markers,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 12,
                  ),
                  onCameraMove: onCameraMove,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 19, horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Text("Distancia: " + _distance,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    Text("Tiempo estimado: " + _tiempo,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
          ),
        )
      ],
    ));
  }

  void call(String number) => launch("tel:$number");

  getLocation() async {
    var location = new Location();
    location.onLocationChanged().listen((currentLocation) {
      setState(() {
        latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
        accuracy = currentLocation.accuracy;
      });
      sendRequest();

      // print("getLocation:$latLng");
      // _onAddMarkerButtonPressed();
      loading = false;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("111"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    });
  }

  void onCameraMove(CameraPosition position) {
    latLng = position.target;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void sendRequest() async {
    LatLng destination = LatLng(-34.180663, -70.708399);
    Map<String, dynamic> _data =
        await _googleMapsServices.getRouteCoordinates(latLng, destination);
    Firestore.instance
        .collection('avisos')
        .document(widget.data["documentID"])
        .updateData({"lat": latLng.latitude, "lng": latLng.longitude});
    // "latLng": new GeoPoint(latLng.latitude, latLng.longitude)
    _distance = _data["distancia"];
    _tiempo = _data["tiempo"];
    print(widget.data["documentID"]);

    createRoute(_data["ruta"]);
    _addMarker(destination, "KTHM Collage");
  }

  void createRoute(String encondedPoly) {
    _polyLines.clear();
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  }

  Future<void> _addMarker(LatLng location, String address) async {
    _markers.clear();
    final Uint8List markerIconPerson =
        await getBytesFromAsset('assets/markers/person.png', 100);
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/markers/car.png', 100);
    _markers.add(Marker(
        markerId: MarkerId("111"),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(markerIcon)));
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.fromBytes(markerIconPerson)));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    // print(lList.toString());

    return lList;
  }
}
