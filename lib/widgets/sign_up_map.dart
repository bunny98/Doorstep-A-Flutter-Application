import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:google_map_location_picker/generated/i18n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_map_location_picker/generated/i18n.dart'
//     as location_picker;
// import 'package:google_map_location_picker/google_map_location_picker.dart';

// import 'package:place_picker/place_picker.dart';
// import '../APIKeys.dart';

class SignUpMap extends StatefulWidget {
  void Function(LatLng) onLocationChanged;
  SignUpMap({Key key, this.onLocationChanged}) : super(key: key);
  @override
  _SignUpMapState createState() => _SignUpMapState();
}

class _SignUpMapState extends State<SignUpMap> {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Completer<GoogleMapController> _controller = Completer();
  static CameraPosition _currLocCameraPostition;
  LatLng _target;
  // LocationResult _pickedLocation;

  Future<void> _getMyLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }
    _locationData = await location.getLocation();
    _target = LatLng(_locationData.latitude, _locationData.longitude);
    widget.onLocationChanged(_target);
    // print(_locationData.latitude.toString() +
    //     " " +
    //     _locationData.longitude.toString());
    _currLocCameraPostition = CameraPosition(target: _target, zoom: 16.5);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getMyLocation(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          else {
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
                      draggable: true,
                      position: _target,
                      onDragEnd: (val) async {
                        var controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(val.latitude, val.longitude),
                                zoom: 16.5)));
                        widget.onLocationChanged(
                            LatLng(val.latitude, val.longitude));
                      })
                ]),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).pop(),
                label: Text('Done'),
                icon: Icon(Icons.done),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          }
        });
  }
}
