import 'package:doorstep/providers/auth.dart';
import 'package:doorstep/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class CustomerOrdersScreen extends StatefulWidget {
  _CustomerOrdersScreenState createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  // List<Order> _myOrders;
  List<String> _shopAdds;

  Widget build(BuildContext context) {
    // _myOrders = Provider.of<Orders>(context).getOrders;
    _shopAdds = Provider.of<Orders>(context).getShopNames;
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
                          Icons.shopping_cart,
                          size: 25,
                        ),
                        onPressed: () {}),
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
                  'My Orders',
                  style: GoogleFonts.pacifico(fontSize: 25),
                ),
              ),
              if (_shopAdds.length == 0)
                Center(
                  child: Text('No Orders',
                      style: GoogleFonts.pacifico(fontSize: 20)),
                )
              else
                Flexible(
                    child: ListView.builder(
                        itemCount: _shopAdds.length,
                        itemBuilder: (ctx, i) {
                          return Container(
                            // height: 50,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                _shopAdds[i],
                                style: GoogleFonts.aBeeZee(fontSize: 20),
                              )),
                            ),
                          );
                        }))
            ])));
  }
}
