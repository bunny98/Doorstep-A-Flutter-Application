import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestedOrder{
  LatLng loc;
  String houseNum;
  RequestedOrder({this.houseNum, this.loc});
}