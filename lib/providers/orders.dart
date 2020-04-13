import 'dart:async';

import 'package:doorstep/models/order_item.dart';
import 'package:doorstep/models/requested_order.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class Orders with ChangeNotifier {
  List<Order> _orders;
  List<String> _shopAdds;
  List<String> _requesteesId;
  List<String> _receivedTimes;
  List<RequestedOrder> _requestedOrders;
  String fromUserId;
  String toUserId;
  StreamSubscription<QuerySnapshot> receivedOrdersStream;
  bool _shouldListen = true;
  bool _noOrderRecieved = false;

  bool get getIfNoOrdersRecieved {
    return _noOrderRecieved;
  }

  List<Order> get getOrders {
    return _orders;
  }

  List<String> get getShopNames {
    return _shopAdds;
  }

  List<String> get getReceivedTimes{
    return _receivedTimes;
  }

  List<RequestedOrder> get getRequesteesOrders {
    return _requestedOrders;
  }

  String getRequesteesIdAt(int i){
    return _requesteesId[i];
  }

  Order getOrderAt(int i) {
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
    var objId = randomAlphaNumeric(10);
    docAdd.addAll({
      'shopName': shopAdd,
      'userId': fromUserId,
      'time': 'None',
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
        .document(objId)
        .setData(docAdd);
     await Firestore.instance
        .collection('ordersS')
        .document(fromUserId)
        .collection(fromUserId)
        .document(objId)
        .setData(docAdd);
  }

  // Future fetchCustomerOrders() async {
  //   _orders = new List();
  //   _shopAdds = new List();
  //   var ref = await Firestore.instance
  //       .collection('ordersS')
  //       .document(fromUserId)
  //       .collection(fromUserId)
  //       .getDocuments();
  //   ref.documents.forEach((doc) {
  //     var currOrder = new List<OrderItem>();
  //     doc.data.forEach((key, val) {
  //       if (key == 'shopName')
  //         _shopAdds.add(val);
  //       else if (key != 'userId')
  //         currOrder
  //             .add(new OrderItem(item: val['item'], quantity: val['quantity']));
  //     });
  //     _orders.add(new Order(items: currOrder, orderId: doc.documentID));
  //   });
  //   print('********************FETCHED ORDER LENGTH ' +
  //       _orders.length.toString());
  //   notifyListeners();
  // }

  bool _isAlreadyPresent(DocumentSnapshot doc) {
    bool _isPresent = false;
    _orders.forEach((or) {
      if (doc.documentID == or.orderId) _isPresent = true;
    });
    return _isPresent;
  }

  Future fetchCustomerOrdersSnaps() async {
    _orders = new List();
    _shopAdds = new List();
    _receivedTimes = new List();
    var snapshots = Firestore.instance
        .collection('ordersS')
        .document(fromUserId)
        .collection(fromUserId)
        .snapshots();
    receivedOrdersStream = snapshots.listen((data) {
      if (data.documents.length > 0) {
        int i = -1;
        data.documents.forEach((doc) {
          if (!_isAlreadyPresent(doc)) {
            var currOrder = new List<OrderItem>();
            doc.data.forEach((key, val) {
              if (key == 'shopName')
                _shopAdds.add(val);
              else if (key == 'time') {
                _receivedTimes.add(val);
              } else if (key != 'userId') {
                currOrder.add(new OrderItem(
                    item: val['item'], quantity: val['quantity']));
              }
            });
            _orders.add(new Order(items: currOrder, orderId: doc.documentID));
            print('***************' + 'ADDED My ORDER!' + _orders.length.toString()+'***************');
            print('***************' + 'ADDED REQ TIME!' + _receivedTimes.length.toString()+'***************');
            print('***************' + 'ADDED SHOP NAME ORDER!' + _shopAdds.length.toString()+'***************');
            notifyListeners();
          }
          else{
            i++;
            if(doc['time']!=_receivedTimes[i]){
              print('***************' + 'Changed Received Time!' + '***************');
              _receivedTimes[i] = doc['time'];
              notifyListeners();
            }
          }
        });
      }
    });
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
              else if (key != 'shopName' && key != 'time')
                currOrder.add(new OrderItem(
                    item: val['item'], quantity: val['quantity']));
            });
            _orders.add(new Order(items: currOrder, orderId: doc.documentID));
            print('***************' + 'ADDED ORDER!' + '***************');
            fetchRequesteesLatLng();
          }
        });
      }
    });
  }

  Future<void> fetchRequesteesLatLng() async {
    List<RequestedOrder> _newRequestedOrders = new List();

    for (int i = 0; i < _requesteesId.length; i++) {
      var ref = await Firestore.instance
          .collection('users')
          .document(_requesteesId[i])
          .get();
      double lat = double.parse(ref['latitude']);
      double lng = double.parse(ref['longitude']);
      String houseNumber = ref['address'];
      _newRequestedOrders.add(
          new RequestedOrder(houseNum: houseNumber, loc: LatLng(lat, lng)));
    }

    if (_requestedOrders == null && _newRequestedOrders.length > 0) {
      print('***************' +
          'Changed _requestOrders from null' +
          '***************');
      _requestedOrders = _newRequestedOrders;
      print(_requestedOrders.length);
      notifyListeners();
    } else {
      if (_requestedOrders.length != _newRequestedOrders.length) {
        print('***************' + 'Changed _requestOrders' + '***************');
        _requestedOrders = _newRequestedOrders;
        print(_requestedOrders.length);
        notifyListeners();
      }
    }
  }
}
