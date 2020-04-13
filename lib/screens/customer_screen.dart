import 'package:doorstep/providers/orders.dart';
import 'package:doorstep/screens/customer_make_order.dart';
import 'package:doorstep/screens/customer_orders_screen.dart';
import 'package:doorstep/screens/login.dart';
import 'package:doorstep/widgets/customer_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/auth.dart';
import '../providers/shops.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  bool _buildMap = false;
  bool _hasClickedMarker = false;
  ShopData _tappedShop;
  TextStyle _headings =
      GoogleFonts.paprika(fontWeight: FontWeight.bold, fontSize: 15);

  void _onMarkerTapped(ShopData tappedShop) {
    print('*******' + tappedShop.address + '********');
    setState(() {
      _hasClickedMarker = true;
      _tappedShop = tappedShop;
    });
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      AuthData user = Provider.of<Auth>(context).getAuthData;
      Provider.of<Shops>(context).setCurrLoc(user.latitude, user.longitude);
      Provider.of<Shops>(context).fetchShops().then((_) {
        setState(() {
          _buildMap = true;
        });
      });
      setState(() {
        _tappedShop = new ShopData(
            address: user.address,
            delivery: user.delivery,
            latitude: user.latitude,
            longitude: user.longitude,
            typeOfShop: user.typeOfShop,
            userId: user.userId);
      });
      Provider.of<Orders>(context).setFromUserId(user.userId);
      Provider.of<Orders>(context).fetchCustomerOrdersSnaps();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/customer_orders_screen');
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
            Stack(
              children: <Widget>[
                // Padding(
                //     padding: EdgeInsets.only(top: 20),
                //     child: Text(
                //       'Pick a Shop',
                //       style: _headings,
                //     )),
                if (_buildMap)
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    height: MediaQuery.of(context).size.height - 78,
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.white, width: 2))),
                    child: CustomerMap(
                      onMarkerTapped: _onMarkerTapped,
                    ),
                  )
                else
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_tappedShop != null)
                  Positioned(
                      bottom: 60,
                      left: MediaQuery.of(context).size.width * 0.17,
                      child: Center(
                          child: Container(
                        height: MediaQuery.of(context).size.height * 0.16,
                        width: MediaQuery.of(context).size.height * 0.3,
                        child: Card(
                          color: _tappedShop.typeOfShop == 'Grocery Shop'
                              ? Colors.greenAccent
                              : _tappedShop.typeOfShop == 'Pharmacy'
                                  ? Colors.yellowAccent[700]
                                  : _tappedShop.typeOfShop == 'Hardware Shop'
                                      ? Colors.pink[400]
                                      : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 8.0,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _hasClickedMarker
                                    ? Text(
                                        'Picked Shop: ' + _tappedShop.address,
                                        style: GoogleFonts.aBeeZee(
                                            color: Colors.white),
                                      )
                                    : Text(
                                        'Your Location: ' + _tappedShop.address,
                                        style: GoogleFonts.aBeeZee(
                                            color: Colors.white)),
                                _hasClickedMarker
                                    ? Container(
                                        child: RaisedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          CustomerMakesOrder(
                                                            shop: _tappedShop,
                                                          )));
                                            },
                                            icon: Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.black,
                                            ),
                                            label: Text(
                                              'Order Now',
                                              style: GoogleFonts.aBeeZee(
                                                  color: Colors.black),
                                            )))
                                    : SizedBox(
                                        height: 0,
                                      ),
                              ]),
                        ),
                      )))
              ],
            )
          ])),
    );
  }
}
