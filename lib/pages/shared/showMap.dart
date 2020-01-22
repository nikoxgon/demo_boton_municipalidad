import 'dart:async';
import 'dart:math';
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

  MapaPage({Key key, this.data, this.patrullaID}) : super(key: key);

  final Map<String, dynamic> data;
  final String patrullaID;

  @override
  State<StatefulWidget> createState() => new _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  bool loading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  String _distance = "...";
  String _tiempo = "...";
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  LatLng latLng;
  double accuracy;
  LocationData currentLocation;
  Location location = new Location();
  String _mapStyle;

  // CENTER VIEW POINTS
  maps.GoogleMapController _mapController;
  double centerleft;
  double centertop;
  double centerright;
  double centerbottom;
  maps.LatLng destination;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    getMapStyle();
    getLocation();
    loading = true;
  }

  @override
  void dispose() {
    super.dispose();
  }



  void getMapStyle() {
    rootBundle.loadString('assets/map/mapstyle.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          child: loading
              ? Container()
              : maps.GoogleMap(
                  polylines: polyLines,
                  markers: _markers,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  mapType: maps.MapType.normal,
                  initialCameraPosition: maps.CameraPosition(
                    target: latLng,
                    zoom: 12,
                  ),
                  onMapCreated: (maps.GoogleMapController controller) {
                    _mapController = controller;
                    _mapController.setMapStyle(_mapStyle);
                    _centerView();
                    _controller.complete(_mapController);
                  },
                ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              color: Colors.white70,
              elevation: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                  child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                leading: Container(
                  padding: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(width: 1, color: Colors.white24))),
                  child: Icon(
                    Icons.directions_car,
                    color: Color.fromRGBO(228, 1, 51, 1),
                    size: 40,
                  ),
                ),
                title: Text(
                  "Distancia Restante: " + _distance,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                subtitle: Text(
                  "Tiempo Estimado: " + _tiempo,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black45),
                ),
                trailing: FloatingActionButton(
                  onPressed: () {
                    call('+56964953030');
                  },
                  elevation: 2,
                  child: Icon(Icons.call),
                  backgroundColor: Colors.green,
                ),
              )),
            ))
      ],
    ));
  }

  void call(String number) => launch("tel:$number");

  _centerView() async {
    await _mapController.getVisibleRegion().then((onValue) {
      centerleft = min(latLng.latitude, destination.latitude);
      centerright = max(latLng.latitude, destination.latitude);
      centertop = max(latLng.longitude, destination.longitude);
      centerbottom = min(latLng.longitude, destination.longitude);

      var bounds = maps.LatLngBounds(
        southwest: maps.LatLng(centerleft, centerbottom),
        northeast: maps.LatLng(centerright, centertop),
      );
      var cameraUpdate = maps.CameraUpdate.newLatLngBounds(bounds, 120);
      _mapController.animateCamera(cameraUpdate);
    });
  }

  getLocation() async {
    location.onLocationChanged().listen((currentLocation) {
      setState(() {
        if (!mounted) return;
        if (latLng ==
            maps.LatLng(currentLocation.latitude, currentLocation.longitude)) {
          return;
        } else {
          latLng =
              maps.LatLng(currentLocation.latitude, currentLocation.longitude);
          Firestore.instance
              .collection('avisos')
              .document(widget.data["documentID"])
              .updateData({"lat": latLng.latitude, "lng": latLng.longitude});
          sendRequest();
          loading = false;
        }
      });
    });
  }

  List<maps.LatLng> _convertToLatLng(List points) {
    List<maps.LatLng> result = <maps.LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(maps.LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void sendRequest() async {
    if (widget.patrullaID == null) {
      Firestore.instance
          .collection("patrullas")
          .where("correo", isEqualTo: widget.data["patrullaEmail"].toString())
          .snapshots()
          .first
          .then((onValue) async {
        destination = maps.LatLng(onValue.documents.first.data["lat"],
            onValue.documents.first.data["lng"]);
        Map<String, dynamic> _data =
            await _googleMapsServices.getRouteCoordinates(latLng, destination);
        _distance = _data["distancia"];
        _tiempo = _data["tiempo"];
        createRoute(_data["ruta"]);
        _addMarker(destination);
        _centerView();
      });
    } else {
      Firestore.instance
          .collection("patrullas")
          .document(widget.patrullaID)
          .snapshots()
          .first
          .then((onValue) async {
        destination = maps.LatLng(onValue.data["lat"], onValue.data["lng"]);
        Map<String, dynamic> _data =
            await _googleMapsServices.getRouteCoordinates(latLng, destination);
          _distance = _data["distancia"];
          _tiempo = _data["tiempo"];
        createRoute(_data["ruta"]);
        _addMarker(destination);
        _centerView();
      });
    }
  }

  void createRoute(String encondedPoly) {
    _polyLines.clear();
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Color.fromRGBO(228, 1, 51, 1),
        ));
  }

  Future<void> _addMarker(maps.LatLng location) async {
    _markers.clear();
    final Uint8List markerIconPerson =
        await getBytesFromAsset('assets/markers/pin_person.png', 120);
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/markers/pin_car.png', 120);
    _markers.add(Marker(
        markerId: MarkerId("Usuario"),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(markerIconPerson)));
    _markers.add(Marker(
        markerId: MarkerId("Patrulla"),
        position: location,
        icon: BitmapDescriptor.fromBytes(markerIcon)));
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

    return lList;
  }
}
