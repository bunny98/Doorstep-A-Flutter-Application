import 'package:doorstep/models/requested_order.dart';
import 'package:doorstep/providers/orders.dart';
import 'package:doorstep/screens/customer_make_order.dart';
import 'package:doorstep/screens/login.dart';
import 'package:doorstep/screens/shopkeeper_order_items_screen.dart';
import 'package:doorstep/widgets/shopkeeper_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/auth.dart';
import '../providers/shops.dart';
import 'package:provider/provider.dart';

class ShopkeeperScreen extends StatefulWidget {
  @override
  _ShopkeeperScreenState createState() => _ShopkeeperScreenState();
}

class _ShopkeeperScreenState extends State<ShopkeeperScreen> {
  bool _buildMap = false;
  bool _hasClickedMarker = false;
  bool _noOrdersReceived = false;
  int indexOfHouseClicked;
  List<RequestedOrder> _requesteesOrders;
  RequestedOrder _tappedHouse;
  TextStyle _headings =
      GoogleFonts.paprika(fontWeight: FontWeight.bold, fontSize: 15);

  void _onMarkerTapped(int i) {
    setState(() {
      _hasClickedMarker = true;
      _tappedHouse = _requesteesOrders[i];
      indexOfHouseClicked = i;
    });
    print('*******' + _tappedHouse.houseNum + '********');
  }

  // void initState() {
  //   super.initState();
  //   SchedulerBinding.instance.addPostFrameCallback((_) async {});
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AuthData user = Provider.of<Auth>(context).getAuthData;
    Provider.of<Orders>(context).setFromUserId(user.userId);
    Provider.of<Orders>(context).fetchShopKeeperOrders();
    _requesteesOrders = Provider.of<Orders>(context).getRequesteesOrders;
    setState(() {
      _buildMap = true;
      _tappedHouse = new RequestedOrder(
          houseNum: user.address, loc: LatLng(user.latitude, user.longitude));
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
                    child: ShopkeeperMap(
                      onMarkerTapped: _onMarkerTapped,
                    ),
                  )
                else
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_tappedHouse != null)
                  Positioned(
                      bottom: 60,
                      left: MediaQuery.of(context).size.width * 0.17,
                      child: Center(
                          child: Container(
                        height: MediaQuery.of(context).size.height * 0.16,
                        width: MediaQuery.of(context).size.height * 0.3,
                        child: Card(
                          color: Colors.pink[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 8.0,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _hasClickedMarker
                                    ? Text(
                                        'Picked House: ' +
                                            _tappedHouse.houseNum,
                                        style: GoogleFonts.aBeeZee(
                                            color: Colors.white),
                                      )
                                    : Text(
                                        'Your Location: ' +
                                            _tappedHouse.houseNum,
                                        style: GoogleFonts.aBeeZee(
                                            color: Colors.white)),
                                _hasClickedMarker
                                    ? Container(
                                        child: RaisedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          OrderItemsScreen(
                                                            index:
                                                                indexOfHouseClicked,
                                                          )));
                                            },
                                            icon: Icon(
                                              Icons.format_list_bulleted,
                                              color: Colors.black,
                                            ),
                                            label: Text(
                                              'View Order',
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
