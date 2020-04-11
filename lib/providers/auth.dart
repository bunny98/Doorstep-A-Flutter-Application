import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AuthData {
  String userId;
  String errorMessage;
  String userName;
  double latitude;
  double longitude;
  String address;
  String typeOfShop;
  bool delivery;

  AuthData(
      {this.address,
      this.errorMessage,
      this.latitude,
      this.longitude,
      this.typeOfShop,
      this.userId,
      this.userName,
      this.delivery});
}

class Auth with ChangeNotifier {
  AuthData auth;

  onNewAuth(AuthData auth) {
    this.auth = auth;
    notifyListeners();
  }

  AuthData get getAuthData {
    return auth;
  }

  String get getErrorMessage {
    return auth.errorMessage;
  }

  String get getTypeOfShop {
    return auth.typeOfShop;
  }

  LatLng get getCurrLatLng{
    return LatLng(auth.latitude, auth.longitude);
  }

  bool get doesDelivery {
    return auth.delivery;
  }

  Future<bool> checkWhetherLoggedIn() async {
    bool _isLoggedIn;
    await FirebaseAuth.instance.currentUser().then((user) async {
      if (user == null) {
        _isLoggedIn = false;
      } else {
        await Firestore.instance
            .collection("users")
            .document(user.uid)
            .get()
            .then((result) {
          onNewAuth(new AuthData(
            userId: user.uid,
            userName: result['name'],
            latitude: double.parse(result['latitude']),
            longitude: double.parse(result['longitude']),
            address: result['address'],
            typeOfShop: result['typeOfShop'],
            delivery: result['homeDelivery'],
            errorMessage: null,
          ));
          _isLoggedIn = true;
        });
      }
    });
    return _isLoggedIn;
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut().catchError((e) {
        auth.errorMessage = e.code;
      });
      auth.userId = null;
      auth.errorMessage = null;
      auth.address = null;
      auth.userName = null;
      auth.typeOfShop = null;
      // auth.latitude = null;
      // auth.longitude = null;
      auth.delivery = null;
    } catch (e) {}
    notifyListeners();
  }

  Future signIn({String email, String password}) async {
    try {
      auth = new AuthData();
      FirebaseUser currUser = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password)
              .catchError((e) {
        print("SIGNIN ERROR: " + e.code);
        auth.errorMessage = e.code;
      }))
          .user;
      auth.userId = currUser.uid;
      auth.errorMessage = null;
      await Firestore.instance
          .collection('users')
          .document(currUser.uid)
          .get()
          .then((result) {
        auth.userName = result['name'];
        auth.address = result['address'];
        auth.latitude = double.parse(result['latitude']);
        auth.longitude = double.parse(result['longitude']);
        auth.typeOfShop = result['typeOfShop'];
        auth.delivery = result['homeDelivery'];
      });
    } catch (e) {}
    notifyListeners();
  }

  Future signUp(
      {String email,
      String password,
      String name,
      String address,
      String longitude,
      String latitude,
      String typeOfShop,
      bool delivery}) async {
    try {
      auth = new AuthData();
      FirebaseUser currUser = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password)
              .catchError((e) {
        print("Singup ERROR" + e.code);
        auth.errorMessage = e.code;
      }))
          .user;
      print('**********SIGNED UP********');
      auth.userId = currUser.uid;
      auth.errorMessage = null;
      auth.address = address;
      auth.latitude = double.parse(latitude);
      auth.longitude = double.parse(longitude);
      auth.typeOfShop = typeOfShop;
      auth.userName = name;
      auth.delivery = delivery;
      print('************ASSIGNED AUTH**********');
      await Firestore.instance
          .collection('users')
          .document(currUser.uid)
          .setData({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'typeOfShop': typeOfShop,
        'homeDelivery': delivery,
      }).catchError((e) {
        print("WRITING USER INFO ERROR" + e.code);
      });
    } catch (e) {}
    notifyListeners();
  }
}
