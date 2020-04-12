import 'package:doorstep/models/order_item.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders with ChangeNotifier {
  List<Order> _orders;
  List<String> _shopAdds;
  List<String> _requesteesId;
  String fromUserId;
  String toUserId;

  List<Order> get getOrders {
    return _orders;
  }

  List<String> get getShopNames {
    return _shopAdds;
  }

  void addNewShopAdd(String shopAdd){
    _shopAdds.add(shopAdd);
    notifyListeners();
  }

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
      _orders.add(new Order(items: currOrder));
    });
    print('********************FETCHED ORDER LENGTH ' +
        _orders.length.toString());
    notifyListeners();
  }
}
