import 'package:doorstep/screens/customer_screen.dart';
import 'package:doorstep/screens/shopkeeper_screen.dart';
import 'package:doorstep/widgets/button.dart';
import 'package:doorstep/widgets/sign_up_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
// import 'package:google_maps_place_picker/google_maps_place_picker.dart';

class SignUpInputForm extends StatefulWidget {
  @override
  _SignUpInputFormState createState() => _SignUpInputFormState();
}

class _SignUpInputFormState extends State<SignUpInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();
  bool _isShopKeeper = false;
  bool _isLoading = false;
  bool _errorOccured = false;
  bool _homeDelivery = false;
  var _shopType = 'Grocery Shop';
  var errorMessage;
  var _inputFieldHeight;
  var _inputFieldWidth;
  // PickResult _selectedPlace;
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
    'address': '',
    'latitude': '',
    'longitude': '',
    'typeOfShop': '',
    'homeDelivery': '',
  };

  void _onLocationChanged(LatLng val) {
    _authData['latitude'] = val.latitude.toString();
    _authData['longitude'] = val.longitude.toString();
  }

  void _onSubmit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _authData['typeOfShop'] = _isShopKeeper ? _shopType : 'None';
    _formKey.currentState.save();
    // _authData.forEach((key, val) {
    //   print(key + '******' + val);
    // });
    setState(() {
      _isLoading = true;
    });
    //MAKE DATABASE REQUESTS
    await Provider.of<Auth>(context).signUp(
        email: _authData['email'].trim(),
        password: _authData['password'].trim(),
        address: _authData['address'].trim(),
        latitude: _authData['latitude'].trim(),
        longitude: _authData['longitude'].trim(),
        name: _authData['name'].trim(),
        typeOfShop: _authData['typeOfShop'].trim(),
        delivery: _homeDelivery);
    errorMessage = Provider.of<Auth>(context).getErrorMessage;
    if (errorMessage != null) {
      setState(() {
        _errorOccured = true;
      });
    } else {
      setState(() {
        _errorOccured = false;
      });
      if (_authData['typeOfShop'] != 'None')
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

  InputDecoration _getInpDec(String labelText) {
    return InputDecoration(
      // focusedBorder:
      //     OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      // enabledBorder:
      //     OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      border: InputBorder.none,
      fillColor: Colors.lightBlueAccent,
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.white70,
      ),
      errorStyle: TextStyle(color: Colors.white60),
    );
  }

  @override
  Widget build(BuildContext context) {
    _inputFieldHeight = MediaQuery.of(context).size.height * 0.08;
    _inputFieldWidth = MediaQuery.of(context).size.width * 0.75;
    // print(_isShopKeeper);
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 40, right: 5, left: 10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    'Are you a shopkeeper?',
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    activeTrackColor: Colors.white,
                    value: _isShopKeeper,
                    onChanged: (val) {
                      setState(() {
                        if (val)
                          _isShopKeeper = true;
                        else
                          _isShopKeeper = false;
                      });
                    },
                  )
                ])),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
              child: Container(
                height: _inputFieldHeight,
                width: _inputFieldWidth,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _getInpDec('Name'),
                  validator: (val) {
                    if (val.isEmpty) return 'You Must have some name man!';
                  },
                  onSaved: (val) {
                    _authData['name'] = val;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
              child: Container(
                height: _inputFieldHeight,
                width: _inputFieldWidth,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _getInpDec('Email'),
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
              padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
              child: Container(
                height: _inputFieldHeight,
                width: _inputFieldWidth,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _getInpDec('Password'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password too short!';
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
              child: Container(
                height: _inputFieldHeight,
                width: _inputFieldWidth,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  obscureText: true,
                  decoration: _getInpDec('Confirm Password'),
                  validator: (value) {
                    if (_passwordController.text != value) {
                      return 'Passwords do not match!';
                    }
                  },
                  onSaved: (val) {
                    _authData['password'] = val;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
              child: Container(
                height: _inputFieldHeight,
                width: _inputFieldWidth,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _getInpDec(
                      _isShopKeeper ? 'Shop Number' : 'House Number'),
                  validator: (val) {
                    if (val.isEmpty) {
                      return 'Can\'t be empty!';
                    }
                  },
                  onSaved: (val) {
                    _authData['address'] = val;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                right: 5,
                left: 10,
              ),
              child: Container(
                height: 25,
                width: _inputFieldWidth,
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 15,
                    child: FlatButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => SignUpMap(
                                    onLocationChanged: _onLocationChanged,
                                  )));
                        },
                        icon: Icon(
                          Icons.map,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Pick your location',
                          style: TextStyle(color: Colors.white),
                        ))),
              ),
            ),
            if (_isShopKeeper)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 5, left: 10),
                child: Row(children: [
                  Text(
                    'Type of Shop: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  DropdownButton<String>(
                      value: _shopType,
                      focusColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          _shopType = newValue;
                        });
                      },
                      items: <String>[
                        'Grocery Shop',
                        'Pharmacy',
                        'Hardware Shop',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList())
                ]),
              ),
            if (_isShopKeeper)
              Padding(
                  padding: const EdgeInsets.only(top: 0, right: 5, left: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Do you deliver?',
                          style: TextStyle(color: Colors.white),
                        ),
                        Switch(
                          activeTrackColor: Colors.white,
                          value: _homeDelivery,
                          onChanged: (val) {
                            setState(() {
                              if (val)
                                _homeDelivery = true;
                              else
                                _homeDelivery = false;
                            });
                          },
                        )
                      ])),
            if (_errorOccured)
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
              Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                  ),
                  child: LoginButton(
                    onTap: _onSubmit,
                  ))
          ],
        ));
  }
}
