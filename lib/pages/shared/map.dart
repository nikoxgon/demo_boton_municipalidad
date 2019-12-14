import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seam/providers/DirectionsProvider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

class MapPage extends StatefulWidget {
  // final maps.LatLng fromPoint = maps.LatLng(-34.187387, -70.675984);
  final maps.LatLng toPoint = maps.LatLng(-34.180663, -70.708399);

  MapPage({Key key, this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<StatefulWidget> createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  maps.GoogleMapController _mapController;
  // CENTER VIEW POINTS
  double center_left;
  double center_top;
  double center_right;
  double center_bottom;
  // END CENTER VIEW POINTS

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Image.asset(
          'assets/images/logo_white.png',
          height: 45,
        ),
        backgroundColor: Color.fromRGBO(228, 1, 51, 1),
        centerTitle: true,
      ),
      // body: _showMapNavegation(),
      body: Consumer<DirectionProvider>(
          builder: (BuildContext context, DirectionProvider api, Widget child) {
        return Column(
          children: <Widget>[_showMapNavegation(api), _showMapCall()],
        );
      }),
      /*
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.zoom_out_map),
        onPressed: _centerView,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      */
    );
  }

  Widget _showMapNavegation(api) {
    return Expanded(
      flex: 13,
      child: maps.GoogleMap(
        initialCameraPosition: maps.CameraPosition(
          target: _getInitialCamera,
          zoom: 12,
        ),
        markers: _createMarkers(),
        polylines: _currentRoute(api.currentRoute),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Set<maps.Polyline> _currentRoute(route) {
    return route;
  }

  get _getInitialCamera {
    return new maps.LatLng(widget.data['lat'], widget.data['lng']);
  }

  void _onMapCreated(maps.GoogleMapController controller) {
    _mapController = controller;

    _centerView();
  }

  _centerView() async {
    await _mapController.getVisibleRegion().then((onValue) {
      if (center_bottom == null) {
        var api = Provider.of<DirectionProvider>(context);
        api.findDirections(_getInitialCamera, widget.toPoint);
      }
      center_left = min(widget.data['lat'], widget.toPoint.latitude);
      center_right = max(widget.data['lat'], widget.toPoint.latitude);
      center_top = max(widget.data['lng'], widget.toPoint.longitude);
      center_bottom = min(widget.data['lng'], widget.toPoint.longitude);

      var bounds = maps.LatLngBounds(
        southwest: maps.LatLng(center_left, center_bottom),
        northeast: maps.LatLng(center_right, center_top),
      );
      var cameraUpdate = maps.CameraUpdate.newLatLngBounds(bounds, 50);
      _mapController.animateCamera(cameraUpdate);
    });
  }

  Set<maps.Marker> _createMarkers() {
    var tmp = Set<maps.Marker>();

    // tmp.add(
    //   maps.Marker(
    //     markerId: maps.MarkerId("fromPoint"),
    //     position: _getInitialCamera,
    //     icon: maps.BitmapDescriptor.defaultMarkerWithHue(100),
    //     infoWindow: maps.InfoWindow(title: "Destino A"),
    //   ),
    // );
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
        flex: 2,
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
