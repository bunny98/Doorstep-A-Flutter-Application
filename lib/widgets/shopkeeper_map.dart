import 'dart:async';
import 'package:doorstep/models/requested_order.dart';
import 'package:doorstep/providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class ShopkeeperMap extends StatefulWidget {
  final void Function(int) onMarkerTapped;
  ShopkeeperMap({Key key, this.onMarkerTapped}) : super(key: key);
  @override
  _ShopkeeperMapState createState() => _ShopkeeperMapState();
}

class _ShopkeeperMapState extends State<ShopkeeperMap> {
  static CameraPosition _currLocCameraPostition;
  Location location = new Location();
  Completer<GoogleMapController> _controller = Completer();
  LatLng _target;
  List<RequestedOrder> _requestedOrders;
  Set<Marker> _markers;

  void _onMarkerTapped(MarkerId markerId) {
    widget.onMarkerTapped(int.parse(markerId.value));
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _target = Provider.of<Auth>(context).getCurrLatLng;
  //   _currLocCameraPostition = CameraPosition(target: _target, zoom: 15.5);
  //   _requestedOrders = Provider.of<Orders>(context).getRequesteesOrders;
  //   Set<Marker> _newMarkers = new Set();
  //   if (_requestedOrders.length > 0 && _requestedOrders != null) {
  //     print('**********REXECUTING!*********');
  //     _newMarkers.clear();
  //     _newMarkers.add(Marker(
  //         markerId: MarkerId('My Location'),
  //         position: _target,
  //         icon: BitmapDescriptor.defaultMarkerWithHue(150),
  //         infoWindow: InfoWindow(title: 'My Location')));
  //     for (int i = 0; i < _requestedOrders.length; i++) {
  //       var markerId = MarkerId('$i');
  //       var marker = new Marker(
  //         markerId: markerId,
  //         position: _requestedOrders[i].loc,
  //         infoWindow: InfoWindow(title: _requestedOrders[i].houseNum),
  //         onTap: () => _onMarkerTapped(markerId),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(0),
  //       );
  //       _newMarkers.add(marker);
  //     }
  //   } else {
  //     _newMarkers.clear();
  //     _newMarkers.add(Marker(
  //         markerId: MarkerId('My Location'),
  //         position: _target,
  //         icon: BitmapDescriptor.defaultMarkerWithHue(150),
  //         infoWindow: InfoWindow(title: 'My Location')));
  //   }
  //   setState(() {
  //     _markers = _newMarkers;
  //   });
  // }

  void _setRequestedOrdersMarkers() {
    _markers = new Set();
    _markers.add(Marker(
        markerId: MarkerId('My Location'),
        position: _target,
        icon: BitmapDescriptor.defaultMarkerWithHue(150),
        infoWindow: InfoWindow(title: 'My Location')));
    for (int i = 0; i < _requestedOrders.length; i++) {
      var markerId = MarkerId('$i');
      var marker = new Marker(
        markerId: markerId,
        position: _requestedOrders[i].loc,
        infoWindow: InfoWindow(title: _requestedOrders[i].houseNum),
        onTap: () => _onMarkerTapped(markerId),
        icon: BitmapDescriptor.defaultMarkerWithHue(0),
      );
      _markers.add(marker);
    }
  }

  void _setCurrLocMarker() {
    _markers = new Set();
    _markers.add(Marker(
        markerId: MarkerId('My Location'),
        position: _target,
        icon: BitmapDescriptor.defaultMarkerWithHue(150),
        infoWindow: InfoWindow(title: 'My Location')));
  }

  @override
  Widget build(BuildContext context) {
    _target = Provider.of<Auth>(context).getCurrLatLng;
    _currLocCameraPostition = CameraPosition(target: _target, zoom: 15.5);
    _requestedOrders = Provider.of<Orders>(context).getRequesteesOrders;
    if (_requestedOrders != null) {
      _setRequestedOrdersMarkers();
    } else {
      _setCurrLocMarker();
    }
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
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
