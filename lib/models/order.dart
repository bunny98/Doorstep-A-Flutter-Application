import './order_item.dart';
class Order {
  List<OrderItem> items;
  String orderId;
  Order({this.items, this.orderId});
}