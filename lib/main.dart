import 'package:doorstep/screens/customer_make_order.dart';
import 'package:doorstep/screens/customer_orders_screen.dart';
import 'package:doorstep/screens/customer_screen.dart';
import 'package:doorstep/screens/login.dart';
import 'package:doorstep/screens/new_user.dart';
import 'package:doorstep/screens/shopkeeper_order_items_screen.dart';
import 'package:doorstep/screens/shopkeeper_screen.dart';
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
                initialRoute: '/',
  routes: {
    // When navigating to the "/" route, build the FirstScreen widget.
    '/': (context) => SplashScreen(),
    // When navigating to the "/second" route, build the SecondScreen widget.
    '/login': (context) => LoginPage(),
    '/newUser':(context)=>NewUser(),
    '/customer_screen':(context)=>CustomerScreen(),
    '/customer_orders_screen':(context)=>CustomerOrdersScreen(),
    '/customer_makes_order':(context)=>CustomerMakesOrder(),
    '/shopkeeper_screen':(context)=>ShopkeeperScreen(),
    '/shopkeeper_order_items_screen':(context)=>OrderItemsScreen(),
  },
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                // home: SplashScreen(),
              )),
    );
  }
}
