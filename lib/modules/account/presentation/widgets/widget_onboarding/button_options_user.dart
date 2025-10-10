import 'package:flutter/material.dart';

class ButtonOptionsUser extends StatefulWidget {
  final Function() onTap;
  final double height;
  final double width;
  final Color color;
  final String text;
  final Color colorText;

  const ButtonOptionsUser({
    Key? key,
    required this.onTap,
    required this.height,
    required this.width,
    required this.color,
    required this.text,
    required this.colorText,
  }) : super(key: key);

  @override
  State<ButtonOptionsUser> createState() => _ButtonOptionsUserState();
}

class _ButtonOptionsUserState extends State<ButtonOptionsUser> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(20.0),
              ),
              //  color: Colors.blue,
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                      fontSize: 16,
                      color: widget.colorText
                  ),
                ),
              )
          ),
          const SizedBox(
            height: 15,
          )
        ],
      )
    );
  }
}
