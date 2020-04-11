import 'package:doorstep/screens/login.dart';
import 'package:doorstep/widgets/customer_map.dart';
import 'package:flutter/material.dart';
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
  LatLng _target;
  TextStyle _headings =
      GoogleFonts.paprika(fontWeight: FontWeight.bold, fontSize: 15);

  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      _target = Provider.of<Auth>(context).getCurrLatLng;
      Provider.of<Shops>(context)
          .setCurrLoc(_target.latitude, _target.longitude);
      Provider.of<Shops>(context).fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(color: Colors.brown[50]),
          child: Column(
            children: <Widget>[
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
              Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Pick a Shop',
                    style: _headings,
                  )),
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                height: MediaQuery.of(context).size.height * 0.5,
                child: CustomerMap(),
              )
            ],
          )),
    );
  }
}
