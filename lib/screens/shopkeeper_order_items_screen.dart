import 'package:cloud_firestore/cloud_firestore.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  Order _order;
  List<OrderItem> _orderItems;
  String _requesteesId;
  String _shopkeeperId;
  bool _delivery;
  static final myController = TextEditingController();

  bool _sendDeliveryTime = false;
  bool _halfHour = false, _oneHour = false, _twoHours = false;

  InputDecoration _getInpDec(String labelText) {
    return InputDecoration(
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      // border: InputBorder.none,
      fillColor: Colors.lightBlueAccent,
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.black,
      ),
      errorStyle: TextStyle(color: Colors.black),
    );
  }

  void _onDonePreparing() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        context: context,
        builder: (ctx) {
          bool _isLoading = false;
          void _onSubmitResponseTime() async {
            setState(() {
              _isLoading = true;
            });
            if (_sendDeliveryTime) {
              var _sendData;
              if (_halfHour) {
                _sendData = 'Delivery in half hour';
              } else if (_oneHour) {
                _sendData = 'Delivery in one hour';
              } else {
                _sendData = 'Delivery in two hours';
              }
              await Firestore.instance
                  .collection('ordersS')
                  .document(_requesteesId)
                  .collection(_requesteesId)
                  .document(_order.orderId)
                  .updateData({
                'time': _sendData,
              });
            } else {
              var lastPickupTime = await Firestore.instance
                  .collection('pickupTimes')
                  .document(_shopkeeperId)
                  .get();
              DateTime sendDT;
              if (lastPickupTime.exists) {
                var lastPickupDateTime =
                    DateTime.fromMillisecondsSinceEpoch(lastPickupTime['time']);
                var nextPickUpDateTime =
                    lastPickupDateTime.add(Duration(minutes: 10));
                if (nextPickUpDateTime.isAfter(DateTime.now().toLocal())) {
                  sendDT = nextPickUpDateTime;
                } else {
                  sendDT = DateTime.now().toLocal().add(Duration(minutes: 10));
                }
              } else {
                sendDT = DateTime.now().toLocal().add(Duration(minutes: 10));
              }
              await Firestore.instance
                  .collection('ordersS')
                  .document(_requesteesId)
                  .collection(_requesteesId)
                  .document(_order.orderId)
                  .updateData({
                'time': 'Pick up at ' +
                    TimeOfDay.fromDateTime(sendDT).format(context),
              });
              await Firestore.instance
                  .collection('pickupTimes')
                  .document(_shopkeeperId)
                  .setData({
                'time': sendDT.millisecondsSinceEpoch,
              });
            }
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
          }

          if (_delivery) {
            return StatefulBuilder(
                builder: (BuildContext ctx, setState) => Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            CheckboxListTile(
                              title: Text('Send Delivery Time?',
                                  style: GoogleFonts.pacifico(fontSize: 18)),
                              value: _sendDeliveryTime,
                              onChanged: (newValue) {
                                setState(() {
                                  _sendDeliveryTime = !_sendDeliveryTime;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                            if (_sendDeliveryTime)
                              Column(
                                children: <Widget>[
                                  CheckboxListTile(
                                    title: Text('In half hour?',
                                        style:
                                            GoogleFonts.pacifico(fontSize: 15)),
                                    value: _halfHour,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _halfHour = !_halfHour;
                                        _oneHour = false;
                                        _twoHours = false;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                  CheckboxListTile(
                                    title: Text('In an hour?',
                                        style:
                                            GoogleFonts.pacifico(fontSize: 15)),
                                    value: _oneHour,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _oneHour = !_oneHour;
                                        _halfHour = false;
                                        _twoHours = false;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                  CheckboxListTile(
                                    title: Text('In two hours?',
                                        style:
                                            GoogleFonts.pacifico(fontSize: 15)),
                                    value: _twoHours,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _twoHours = !_twoHours;
                                        _halfHour = false;
                                        _oneHour = false;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                ],
                              ),
                            CheckboxListTile(
                              title: Text('Send Pick Up Time?',
                                  style: GoogleFonts.pacifico(fontSize: 18)),
                              value: !_sendDeliveryTime,
                              onChanged: (newValue) {
                                setState(() {
                                  _sendDeliveryTime = !_sendDeliveryTime;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                            if (_isLoading)
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: CircularProgressIndicator(),
                              )
                            else
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: RaisedButton.icon(
                                    onPressed: _onSubmitResponseTime,
                                    icon: Icon(Icons.done_outline),
                                    label: Text('Submit',
                                        style: GoogleFonts.pacifico(
                                            fontSize: 20))),
                              ),
                          ],
                        ),
                      ),
                    ));
          } else
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: _isLoading
                  ? Container(
                      padding: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 10),
                      child: RaisedButton.icon(
                          onPressed: _onSubmitResponseTime,
                          icon: Icon(Icons.done_outline),
                          label: Text('Send Pick up Time',
                              style: GoogleFonts.pacifico(fontSize: 20))),
                    ),
            );
        });
  }

  Widget build(BuildContext context) {
    _order = Provider.of<Orders>(context).getOrderAt(widget.index);
    _requesteesId =
        Provider.of<Orders>(context).getRequesteesIdAt(widget.index);
    _shopkeeperId = Provider.of<Auth>(context).getUserId;
    _orderItems = _order.items;
    _delivery = Provider.of<Auth>(context).doesDelivery;
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
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/login', (_) => false);
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
                                onPressed: _onDonePreparing,
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
