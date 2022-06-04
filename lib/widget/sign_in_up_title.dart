import 'package:flutter/material.dart';

class SignInUpTitle extends StatelessWidget {
  String title;
  SignInUpTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return
      Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textSelectionTheme.selectionColor,
          fontSize: 20,
          // fontFamily: Util.notoSans,
          fontWeight: FontWeight.w700,
        ),
      );
  }
}