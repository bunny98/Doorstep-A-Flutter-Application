import 'package:doorstep/providers/auth.dart';
import 'package:doorstep/providers/shops.dart';
import 'package:doorstep/screens/customer_orders_screen.dart';
import 'package:doorstep/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/order_item.dart';
import '../providers/orders.dart';

class CustomerMakesOrder extends StatefulWidget {
  final ShopData shop;
  CustomerMakesOrder({Key key, this.shop}) : super(key: key);
  _CustomerMakesOrderState createState() => _CustomerMakesOrderState();
}

class _CustomerMakesOrderState extends State<CustomerMakesOrder> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  static OrderItem _currItem;
  static String _currUserId;
  List<OrderItem> order;
  List<Widget> _orderTuples = new List();
  bool _isLoading = false;

  Widget _orderTuple = Container(
      child: Column(children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
            width: 200,
            height: 50,
            child: TextFormField(
              decoration: _getInpDec('Item'),
              validator: (val) {
                if (val.isEmpty) return 'Cannot be empty!';
              },
              onSaved: (val) {
                _currItem.item = val;
              },
            )),
        Container(
            width: 100,
            height: 50,
            child: TextFormField(
              decoration: _getInpDec('Quantity'),
              validator: (val) {
                if (val.isEmpty) return 'Cannot be empty!';
              },
              onSaved: (val) {
                _currItem.quantity = val;
              },
            ))
      ],
    ),
    SizedBox(
      height: 10,
    ),
  ]));

  static InputDecoration _getInpDec(String labelText) {
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

  void initState() {
    _orderTuples.add(_orderTuple);
    order = new List();
    _currItem = new OrderItem();
    Future.delayed(Duration.zero).then((_) {
      _currUserId = Provider.of<Auth>(context).getUserId;
    });
    super.initState();
  }

  void _onOrderItemAdded() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    print('***************ADDING ' + _currItem.item);
    order
        .add(new OrderItem(item: _currItem.item, quantity: _currItem.quantity));
    setState(() {
      _orderTuples.add(_orderTuple);
    });
  }

  void _onSubmit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    print('***************ADDING ' + _currItem.item);
    order
        .add(new OrderItem(item: _currItem.item, quantity: _currItem.quantity));
    setState(() {
      _isLoading = true;
    });
    // Provider.of<Orders>(context).setFromUserId(_currUserId);
    Provider.of<Orders>(context).setToUserId(widget.shop.userId);
    await Provider.of<Orders>(context).uploadOrder(order, widget.shop.address);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).popAndPushNamed('/customer_orders_screen');
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 30),
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Colors.brown[50]),
      child: SingleChildScrollView(
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
                    Icons.shopping_cart,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/customer_orders_screen');
                  }),
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
          padding: EdgeInsets.only(top: 30),
          child: Form(
              key: _formKey,
              child: Column(
                children: _orderTuples,
              )),
        ),
        Container(
          padding: EdgeInsets.only(top: 20),
          child: RaisedButton.icon(
              onPressed: _onOrderItemAdded,
              icon: Icon(Icons.add_circle_outline),
              label:
                  Text('Add Item', style: GoogleFonts.pacifico(fontSize: 18))),
        ),
        if (_isLoading)
          Container(
            padding: EdgeInsets.only(top: 20),
            child: CircularProgressIndicator(),
          )
        else
          Container(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton.icon(
                onPressed: _onSubmit,
                icon: Icon(Icons.shopping_basket),
                label: Text('Place Order',
                    style: GoogleFonts.pacifico(fontSize: 18))),
          ),
      ])),
    ));
  }
}
