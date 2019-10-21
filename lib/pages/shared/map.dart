import 'dart:math';

import 'package:demo_boton/providers/DirectionsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

class MapPage extends StatefulWidget {
  final maps.LatLng fromPoint = maps.LatLng(-34.187387, -70.675984);
  final maps.LatLng toPoint = maps.LatLng(-34.180663, -70.708399);

  MapPage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<StatefulWidget> createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  maps.GoogleMapController _mapController;

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/logo_independencia.png',
          height: 40,
        ),
        backgroundColor: Color.fromRGBO(211, 52, 69, 1),
      ),
      body: _showMapNavegation(),
      // body: Column(
      //   children: <Widget>[_showMapNavegation(), _showMapCall()],
      // ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.zoom_out_map),
        onPressed: _centerView,
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _showMapNavegation() {
    return Consumer<DirectionProvider>(
        builder: (BuildContext context, DirectionProvider api, Widget child) {
      return maps.GoogleMap(
        initialCameraPosition: maps.CameraPosition(
          target: widget.fromPoint,
          zoom: 12,
        ),
        markers: _createMarkers(),
        polylines: _currentRoute(api.currentRoute),
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      );
    });
  }

  Set<maps.Polyline> _currentRoute(route) {
    return route;
  }

  void _onMapCreated(maps.GoogleMapController controller) {
    _mapController = controller;

    _centerView();
  }

  _centerView() async {
    await _mapController.getVisibleRegion().then((onValue) {
      var left = min(widget.fromPoint.latitude, widget.toPoint.latitude);
      var right = max(widget.fromPoint.latitude, widget.toPoint.latitude);
      var top = max(widget.fromPoint.longitude, widget.toPoint.longitude);
      var bottom = min(widget.fromPoint.longitude, widget.toPoint.longitude);

      var bounds = maps.LatLngBounds(
        southwest: maps.LatLng(left, bottom),
        northeast: maps.LatLng(right, top),
      );
      var cameraUpdate = maps.CameraUpdate.newLatLngBounds(bounds, 50);
      _mapController.animateCamera(cameraUpdate);

      var api = Provider.of<DirectionProvider>(context);
      api.findDirections(widget.fromPoint, widget.toPoint);
    });
  }

  Set<maps.Marker> _createMarkers() {
    var tmp = Set<maps.Marker>();

    tmp.add(
      maps.Marker(
        markerId: maps.MarkerId("fromPoint"),
        position: widget.fromPoint,
        icon: maps.BitmapDescriptor.defaultMarkerWithHue(100),
        infoWindow: maps.InfoWindow(title: "Destino A"),
      ),
    );
    tmp.add(
      maps.Marker(
        markerId: maps.MarkerId("toPoint"),
        position: widget.toPoint,
        infoWindow: maps.InfoWindow(title: "Destino B"),
      ),
    );
    return tmp;
  }

  void call(String number) => launch("tel:$number");

  Widget _showMapCall() {
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
  }
}
