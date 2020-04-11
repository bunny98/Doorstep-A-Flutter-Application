import 'package:doorstep/screens/customer_screen.dart';
import 'package:doorstep/screens/shopkeeper_screen.dart';
import 'package:doorstep/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class LoginInputForm extends StatefulWidget {
  @override
  _LoginInputFormState createState() => _LoginInputFormState();
}

class _LoginInputFormState extends State<LoginInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  bool _onErrorOccured = false;
  var errorMessage;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _onSubmit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    //MAKE DATABASE REQUESTS
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Auth>(context).signIn(
        email: _authData['email'].trim(),
        password: _authData['password'].trim());
    errorMessage = Provider.of<Auth>(context).getErrorMessage;
    if (errorMessage != null) {
      setState(() {
        _onErrorOccured = true;
      });
    } else {
      setState(() {
        _onErrorOccured = false;
      });
      var typeOfShop = Provider.of<Auth>(context).getTypeOfShop;
      print("*********"+typeOfShop);
      if (typeOfShop != 'None')
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => ShopkeeperScreen()),
            (_) => false);
      else
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => CustomerScreen()),
            (_) => false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
              child: Container(
                // height: 90,
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.lightBlueAccent,
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (val) {
                    _authData['email'] = val;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
              child: Container(
                // height: 60,
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.lightBlueAccent,
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password too short!';
                    }
                  },
                  onSaved: (val) {
                    _authData['password'] = val;
                  },
                ),
              ),
            ),
            if (_onErrorOccured)
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 5,
                  left: 10,
                ),
                child: Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 15,
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            if (_isLoading)
              CircularProgressIndicator()
            else
              LoginButton(
                onTap: _onSubmit,
              ),
          ],
        )));
  }
}
