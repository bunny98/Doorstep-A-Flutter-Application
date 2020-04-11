import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/customer_screen.dart';
import '../screens/shopkeeper_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      var val = await Provider.of<Auth>(context).checkWhetherLoggedIn();
      if (val) {
        var typeOfShop = Provider.of<Auth>(context).getTypeOfShop;
        if (typeOfShop != 'None')
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (ctx) => ShopkeeperScreen()),
              (_) => false);
        else
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (ctx) => CustomerScreen()),
              (_) => false);
      } else
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => LoginPage()), (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
