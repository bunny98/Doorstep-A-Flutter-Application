import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../providers/shops.dart';
import '../providers/auth.dart';

class CustomerMap extends StatefulWidget {
  CustomerMap({Key key}) : super(key: key);
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
    _target = Provider.of<Auth>(context).getCurrLatLng;
    _currLocCameraPostition = CameraPosition(target: _target, zoom: 15.5);
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: _currLocCameraPostition,
        // markers: Set<Marker>.of(<Marker>[
        //   Marker(
        //     markerId: MarkerId('Curr Location'),
        //     position: _target,
        //   )
        // ]),
      ),
    );
  }
}
