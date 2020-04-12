import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../providers/shops.dart';
import '../providers/auth.dart';

class CustomerMap extends StatefulWidget {
  final void Function(ShopData) onMarkerTapped;
  CustomerMap({Key key, this.onMarkerTapped}) : super(key: key);
  @override
  _CustomerMapState createState() => _CustomerMapState();
}

class _CustomerMapState extends State<CustomerMap> {
  static CameraPosition _currLocCameraPostition;
  Location location = new Location();
  Completer<GoogleMapController> _controller = Completer();
  LatLng _target;
  List<ShopData> _nearByShops;
  ShopData _tappedShop;
  Set<Marker> _markers;

  void _onMarkerTapped(MarkerId markerId) {
    _tappedShop = _nearByShops[int.parse(markerId.value)];
    widget.onMarkerTapped(_tappedShop);
  }

  void _setMarkers(List<ShopData> _shops) {
    _markers = new Set();
    for (int i = 0; i < _shops.length; i++) {
      var _markerId = MarkerId('$i');
      if (_shops[i].typeOfShop == 'Grocery Shop') {
        _markers.add(Marker(
          markerId: _markerId,
          position: LatLng(_shops[i].latitude, _shops[i].longitude),
          infoWindow: InfoWindow(title: _shops[i].address),
          onTap: () {
            _onMarkerTapped(_markerId);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(150),
        ));
      } else if (_shops[i].typeOfShop == 'Pharmacy') {
        _markers.add(Marker(
          markerId: _markerId,
          position: LatLng(_shops[i].latitude, _shops[i].longitude),
          infoWindow: InfoWindow(title: _shops[i].address),
          onTap: () {
            _onMarkerTapped(_markerId);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(50),
        ));
      } else {
        _markers.add(Marker(
          markerId: _markerId,
          position: LatLng(_shops[i].latitude, _shops[i].longitude),
          infoWindow: InfoWindow(title: _shops[i].address),
          onTap: () {
            _onMarkerTapped(_markerId);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(0),
        ));
      }
    }
  }

  void _fetchShopsAndSetMarkers() {
    _target = Provider.of<Auth>(context).getCurrLatLng;
    _currLocCameraPostition = CameraPosition(target: _target, zoom: 15.5);
    _nearByShops = Provider.of<Shops>(context).getNearbyShops;
    _setMarkers(_nearByShops);
  }

  @override
  Widget build(BuildContext context) {
    _fetchShopsAndSetMarkers();
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: _currLocCameraPostition,
          markers: _markers,
        ),
      ]),
    );
  }
}
