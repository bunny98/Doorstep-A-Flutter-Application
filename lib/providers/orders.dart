import 'dart:async';

import 'package:doorstep/models/order_item.dart';
import 'package:doorstep/models/requested_order.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders with ChangeNotifier {
  List<Order> _orders;
  List<String> _shopAdds;
  List<String> _requesteesId;
  List<RequestedOrder> _requestedOrders;
  String fromUserId;
  String toUserId;
  StreamSubscription<QuerySnapshot> receivedOrdersStream;
  bool _shouldListen = true;

  List<Order> get getOrders {
    return _orders;
  }

  List<String> get getShopNames {
    return _shopAdds;
  }

  List<RequestedOrder> get getRequesteesOrders {
    return _requestedOrders;
  }

  Order getOrderAt(int i){
    return _orders[i];
  }

  void toggleShouldListen() {
    _shouldListen = !_shouldListen;
  }

  void addNewShopAdd(String shopAdd) {
    _shopAdds.add(shopAdd);
    notifyListeners();
  }

  void addNewOrder(List<OrderItem> order) {
    _orders.add(new Order(items: order, orderId: null));
    notifyListeners();
  }

  void setFromUserId(String uid) {
    fromUserId = uid;
  }

  void setToUserId(String uid) {
    toUserId = uid;
  }

  Future uploadOrder(List<OrderItem> order, String shopAdd) async {
    int i = 0;
    var docAdd = <String, dynamic>{};
    docAdd.addAll({
      'shopName': shopAdd,
      'userId': fromUserId,
    });
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

  Future fetchCustomerOrders() async {
    _orders = new List();
    _shopAdds = new List();
    var ref = await Firestore.instance
        .collection('ordersS')
        .document(fromUserId)
        .collection(fromUserId)
        .getDocuments();
    ref.documents.forEach((doc) {
      var currOrder = new List<OrderItem>();
      doc.data.forEach((key, val) {
        if (key == 'shopName')
          _shopAdds.add(val);
        else if (key != 'userId')
          currOrder
              .add(new OrderItem(item: val['item'], quantity: val['quantity']));
      });
      _orders.add(new Order(items: currOrder, orderId: doc.documentID));
    });
    print('********************FETCHED ORDER LENGTH ' +
        _orders.length.toString());
    notifyListeners();
  }

  bool _isAlreadyPresent(DocumentSnapshot doc) {
    bool _isPresent = false;
    _orders.forEach((or) {
      if (doc.documentID == or.orderId) _isPresent = true;
    });
    return _isPresent;
  }

  Future fetchShopKeeperOrders() async {
    _orders = new List();
    _requesteesId = new List();
    var snapshots = Firestore.instance
        .collection('ordersR')
        .document(fromUserId)
        .collection(fromUserId)
        .snapshots();
    receivedOrdersStream = snapshots.listen((data) {
      if (data.documents.length > 0 && _shouldListen) {
        data.documents.forEach((doc) {
          if (!_isAlreadyPresent(doc)) {
            var currOrder = new List<OrderItem>();
            doc.data.forEach((key, val) {
              if (key == 'userId')
                _requesteesId.add(val);
              else if (key != 'shopName')
                currOrder.add(new OrderItem(
                    item: val['item'], quantity: val['quantity']));
            });
            _orders.add(new Order(items: currOrder, orderId: doc.documentID));
            print('***************' + 'ADDED ORDER!' + '***************');
          }
        });
        fetchRequesteesLatLng();
      }
    });
  }

  Future<void> fetchRequesteesLatLng() {
    List<RequestedOrder> _newRequestedOrders = new List();
    _requesteesId.forEach((id) async {
      var ref = await Firestore.instance.collection('users').document(id).get();
      double lat = double.parse(ref['latitude']);
      double lng = double.parse(ref['longitude']);
      String houseNumber = ref['address'];
      _newRequestedOrders.add(
          new RequestedOrder(houseNum: houseNumber, loc: LatLng(lat, lng)));
      print('***************' + 'ADDED LATLNG!' + '***************');
      if (_requestedOrders == null) {
        _requestedOrders = _newRequestedOrders;
        notifyListeners();
      } else {
        if (_requestedOrders.length != _newRequestedOrders.length) {
          _requestedOrders = _newRequestedOrders;
          notifyListeners();
        }
      }
    });
  }
}
