import 'package:doorstep/models/order.dart';
import 'package:doorstep/models/order_item.dart';
import 'package:doorstep/providers/auth.dart';
import 'package:doorstep/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';

class OrderItemsScreen extends StatefulWidget {
  final index;
  OrderItemsScreen({Key key, this.index}) : super(key: key);
  _OrderItemsScreenState createState() => _OrderItemsScreenState();
}

class _OrderItemsScreenState extends State<OrderItemsScreen> {
  Order _order;
  List<OrderItem> _orderItems;

  Widget build(BuildContext context) {
    _order = Provider.of<Orders>(context).getOrderAt(widget.index);
    _orderItems = _order.items;
    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 30),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.brown[50]),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Doorstep',
                    style: GoogleFonts.pacifico(fontSize: 25),
                  ),
                  Row(children: [
                    IconButton(
                        icon: Icon(
                          Icons.exit_to_app,
                          size: 25,
                        ),
                        onPressed: () async {
                          await Provider.of<Auth>(context).signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (ctx) => LoginPage()),
                              (_) => false);
                        }),
                  ]),
                ],
              ),
              Container(
                child: Text(
                  'Order Items',
                  style: GoogleFonts.pacifico(fontSize: 20),
                ),
              ),
              Flexible(
                  child: ListView.builder(
                      itemCount: _orderItems.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == _orderItems.length) {
                          return Container(
                            padding: EdgeInsets.only(top: 10),
                            child: RaisedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.done_outline),
                                label: Text('Done Preparing?',
                                    style: GoogleFonts.pacifico(fontSize: 18))),
                          );
                        }
                        return Container(
                          // height: 50,
                          padding: EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              'Item: ' +
                                  _orderItems[i].item +
                                  '\nQuantity: ' +
                                  _orderItems[i].quantity,
                              style: GoogleFonts.aBeeZee(fontSize: 20),
                            )),
                          ),
                        );
                      })),
            ])));
  }
}
