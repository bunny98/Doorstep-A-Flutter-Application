import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geodesy/geodesy.dart';

class ShopData {
  String userId;
  double latitude;
  double longitude;
  String address;
  String typeOfShop;
  bool delivery;

  ShopData(
      {this.address,
      this.latitude,
      this.longitude,
      this.typeOfShop,
      this.userId,
      this.delivery});
}

class Shops with ChangeNotifier {
  LatLng currLatLng;
  List<ShopData> _shops;
  Geodesy geodesy = Geodesy();

  void setCurrLoc(LatLng currLatLng) {
    this.currLatLng = currLatLng;
    notifyListeners();
  }

  List<ShopData> get getNearbyShops {
    return _shops;
  }

  Future fetchShops() async {
    _shops = List();
    await Firestore.instance.collection('users').getDocuments().then((snap) {
      if (snap.documents.length > 0) {
        snap.documents.forEach((doc) {
          print('**********' + doc['name'].toString());
          var lat = double.parse(doc['latitude']);
          var lng = double.parse(doc['longitude']);
          var loc = LatLng(lat, lng);
          var distance =
              geodesy.distanceBetweenTwoGeoPoints(currLatLng, loc) / 1000;
          print("********DISTANCE*****" + distance.toString());
          if (distance <= 3 && distance>0) {
            _shops.add(ShopData(
              address: doc['address'],
              latitude: double.parse(doc['latitude']),
              longitude: double.parse(doc['longitude']),
              delivery: doc['homeDelivery'],
              typeOfShop: doc['typeOfShop'],
              userId: doc.documentID,
            ));
          }
        });
      }
    });
    print('************'+_shops.length.toString()+'*********');
  }
}
