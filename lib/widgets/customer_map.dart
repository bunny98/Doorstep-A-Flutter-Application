import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../providers/shops.dart';
import '../providers/auth.dart';

class CustomerMap extends StatefulWidget {
  void Function(LatLng) onLocationChanged;
  CustomerMap({Key key, this.onLocationChanged}) : super(key: key);
  @override
  _CustomerMapState createState() => _CustomerMapState();
}

class _CustomerMapState extends State<CustomerMap> {
  Location location = new Location();
  Completer<GoogleMapController> _controller = Completer();
  static CameraPosition _currLocCameraPostition;
  LatLng _target;

  @override
  Widget build(BuildContext context) {
    _target = Provider.of<Auth>(context).getCurrLatLng as LatLng;
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: _currLocCameraPostition,
        markers: Set<Marker>.of(<Marker>[
          Marker(
              markerId: MarkerId('Curr Location'),
              position: _target,
              onDragEnd: (val) async {
                var controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(val.latitude, val.longitude),
                        zoom: 16.5)));
                widget.onLocationChanged(LatLng(val.latitude, val.longitude));
              })
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        label: Text('Done'),
        icon: Icon(Icons.done),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
