import 'package:doorstep/models/order_item.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Orders with ChangeNotifier {
  List<Order> _orders = new List();
  String fromUserId;
  String toUserId;

  void addNewOrder(List<OrderItem> order) {
    _orders.add(new Order(items: order));
    notifyListeners();
  }

  void setFromUserId(String uid) {
    fromUserId = uid;
  }

  void setToUserId(String uid) {
    toUserId = uid;
  }

  Future uploadOrder(List<OrderItem> order) async {
    int i = 0;
    var docAdd = <String, dynamic>{};
    order.forEach((or) {
      docAdd.addAll({
        '$i': {
          'item': or.item,
          'quantity': or.quantity,
        }
      });
      i++;
    });
    print(docAdd);
    await Firestore.instance
        .collection('ordersR')
        .document(toUserId)
        .collection(toUserId)
        .add(docAdd);
    await Firestore.instance
        .collection('ordersS')
        .document(fromUserId)
        .collection(fromUserId)
        .add(docAdd);
  }
}
