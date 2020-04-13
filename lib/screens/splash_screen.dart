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
          Navigator.pushNamedAndRemoveUntil(
              context, '/shopkeeper_screen', (_) => false);
        else
          Navigator.pushNamedAndRemoveUntil(
              context, '/customer_screen', (_) => false);
      } else
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
