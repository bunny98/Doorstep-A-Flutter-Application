import 'package:flutter/material.dart';

class VerticalText extends StatefulWidget {
  final text;
  VerticalText({Key key, this.text}) : super(key: key);
  @override
  _VerticalTextState createState() => _VerticalTextState();
}

class _VerticalTextState extends State<VerticalText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Container(
          child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ))),
    );
  }
}
