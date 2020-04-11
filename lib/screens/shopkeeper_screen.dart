import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../screens/login.dart';

class ShopkeeperScreen extends StatefulWidget {
  @override
  _ShopkeeperScreenState createState() => _ShopkeeperScreenState();
}

class _ShopkeeperScreenState extends State<ShopkeeperScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: IconButton(
              icon: Icon(
                Icons.exit_to_app,
                size: 25,
              ),
              onPressed: () async {
                await Provider.of<Auth>(context).signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (ctx) => LoginPage()),
                    (_) => false);
              })),
    );
  }
}
