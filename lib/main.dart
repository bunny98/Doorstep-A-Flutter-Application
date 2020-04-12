import 'package:doorstep/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './providers/shops.dart';
import './providers/orders.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Shops()),
        ChangeNotifierProvider.value(value: Orders()),
      ],
      child: Consumer3<Auth, Shops, Orders>(
          builder: (ctx, auth, shops, orders, _) => MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: SplashScreen(),
              )),
    );
  }
}
