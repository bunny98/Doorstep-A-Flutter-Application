import 'package:doorstep/widgets/first.dart';
import 'package:doorstep/widgets/login_input_form.dart';
import 'package:doorstep/widgets/textLogin.dart';
import 'package:doorstep/widgets/verticalText.dart';
import 'package:doorstep/widgets/button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    var _verticalTextPadding = MediaQuery.of(context).size.height * 0.18;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, Colors.lightBlueAccent]),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                          padding: EdgeInsets.only(top: _verticalTextPadding),
                          child: VerticalText(
                            text: 'Sign In',
                          )),
                  TextLogin(),
                ]),
                // InputEmail(),
                // PasswordInput(),
                // LoginButton(),
                LoginInputForm(),
                FirstTime(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonLogin {
}