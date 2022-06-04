import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';

class SignInUpButton extends StatefulWidget {
  final String? buttonText;
  final Color? textColor;
  final Color? borderColor;
  final Color? innerColor;
  final bool isGradient;
  final Color? gradientFirst;
  final Color? gradientSecond;

  SignInUpButton(
      {this.buttonText, this.textColor, this.borderColor, this.innerColor, this.isGradient = true, this.gradientFirst, this.gradientSecond});

  @override
  State<StatefulWidget> createState() => _SignInUpButton();
}

class _SignInUpButton extends State<SignInUpButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 51,
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: widget.borderColor??AppColors.black),
        borderRadius: BorderRadius.all(Radius.circular(50)),
        gradient: widget.isGradient
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.gradientFirst??AppColors.black,
                  widget.gradientSecond??AppColors.black
                ],
              )
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.innerColor??AppColors.black,
                  widget.innerColor??AppColors.black],
              ),
      ),
      child: Center(
        child: Text(
          widget.buttonText??"BUTTON",
          style: TextStyle(color: widget.textColor, fontSize: 15, fontWeight: FontWeight.w400),//fontFamily: Util.notoSans,
        ),
      ),
    );
  }
}
