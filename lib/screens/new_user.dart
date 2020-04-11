import 'package:doorstep/widgets/signup_input_form.dart';
import 'package:doorstep/widgets/userOld.dart';
import 'package:doorstep/widgets/verticalText.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {

  @override
  Widget build(BuildContext context) {
    var _verticalTextPadding = MediaQuery.of(context).size.height * 0.18;
    return Scaffold(
      body: Container(
          // height: MediaQuery.of(context).size.height,
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
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: _verticalTextPadding),
                          child: VerticalText(
                            text: 'Sign Up',
                          )),
                      SignUpInputForm(),
                    ],
                  ),
                  UserOld(),
                  // NewNome(),
                  // NewEmail(),
                  // PasswordInput(),
                  // ButtonNewUser(),
                ],
              )
            ],
          )),
    );
  }
}
