import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';


class CustomCheckbox extends StatefulWidget {
  final Function onChange;
  final bool isChecked;
  final String labelText;

  CustomCheckbox({required this.isChecked, required this.onChange, required this.labelText});

  @override
  State<StatefulWidget> createState() => _CustomCheckbox();
}

class _CustomCheckbox extends State<CustomCheckbox> {
  bool _isSelected = false;

  @override
  void initState() {
    _isSelected = widget.isChecked ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
          widget.onChange(_isSelected);
        });
      },
      child: Row(
        children: [
          GestureDetector(
            child: AnimatedContainer(
              margin: EdgeInsets.all(4),
              duration: Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              decoration: BoxDecoration(
                color: _isSelected ? AppColors.buttonBlue : Theme.of(context).toggleableActiveColor,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AppColors.subTextBlack, width: 0.5)),
              width: 18,
              height: 18,
              child: _isSelected
                  ? Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              )
                  : null,
            ),
          ),
          SizedBox(width: 8),
          Text(
            widget.labelText,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
