import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/functions.dart';

class SignInUpInput extends StatefulWidget {
  TextEditingController? controller;
  FocusNode? firstNode;
  FocusNode? secondNode;
  TextInputAction? textInputAction;
  TextInputType? textInputType;
  String? hintText;
  bool isPassword;
  bool isEmail;

  SignInUpInput(
      {this.controller,
      this.firstNode,
      this.secondNode,
      this.textInputAction,
      this.textInputType,
      this.hintText,
      this.isPassword = false,
      this.isEmail = false});

  @override
  State<StatefulWidget> createState() => _SignInUpInput();
}

class _SignInUpInput extends State<SignInUpInput> {
  String errorText = "";
  String controllerText = "";

  // static const Pattern validEmail = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const String validEmail = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp validEmailStr = RegExp(validEmail);

  // static const Pattern validPassword = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,}$';
  static const String validPassword = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{8,}$';
  RegExp validPasswordStr = RegExp(validPassword);

  String validate(String value) {
    if (widget.isEmail) {
      if (value.trim().isEmpty || !validEmailStr.hasMatch(value)) {
        errorText = '이메일 형식이 아닙니다.';
      } else if (value.isEmpty) {
        errorText = '';
      }
    }

    if (widget.isPassword) {
      if (value.trim().length < 7 || ((!validPasswordStr.hasMatch(value)))) {
        errorText = '비밀번호는 8자 이상 영문, 숫자를 포함해서 입력해 주세요.';
      } else if (value.isEmpty) {
        errorText = '';
      }
    }

    return errorText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      controller: widget.controller,
      focusNode: widget.firstNode,
      onFieldSubmitted: (value) {
        fieldFocusChange(context, widget.firstNode, widget.secondNode);
      },
      textInputAction: widget.textInputAction,
      maxLines: 1,
      maxLength: 50,
      keyboardType: widget.textInputType,
      // onChanged: (_) {
      //   setState(() {
      //     validate(widget.controller.text);
      //   });
      // },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: AppColors.inputYellow,
      cursorHeight: 25,
      obscureText: widget.isPassword ? true : false,
      // validator: validate,
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.only(left: 4, bottom: 14),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 14,
          // fontFamily: Util.notoSans,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: Theme.of(context).dividerColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: AppColors.inputYellow),
        ),
        // errorText: errorText,
        errorStyle: TextStyle(
          decorationColor: AppColors.inputInfoYellow,
          color: AppColors.inputInfoYellow,
          fontSize: 12,
          // fontFamily: Util.notoSans,
          fontWeight: FontWeight.w400,
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.inputYellow,
          ),
        ),
      ),
    );
  }
}
