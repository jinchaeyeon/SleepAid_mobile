import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';

class CustomSwitchButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchButton({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  _CustomSwitchButton createState() => _CustomSwitchButton();
}

class _CustomSwitchButton extends State<CustomSwitchButton> with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  LinearGradient switchOffGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.switchOffStart, AppColors.switchOffMiddle, AppColors.switchOffEnd],
  );

  LinearGradient switchOnGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.buttonStart, AppColors.buttonEnd],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft, end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false ? widget.onChanged(true) : widget.onChanged(false);
          },
          child: Container(
            width: 45,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _circleAnimation.value == Alignment.centerLeft ? switchOffGradient : switchOnGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _circleAnimation.value == Alignment.centerRight
                    ? const Padding(
                        padding: EdgeInsets.only(left: 45 - 17)
                      )
                    : Container(),
                Align(
                  alignment: _circleAnimation.value,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(width: 0.5, color: AppColors.borderGrey.withOpacity(0.3))),
                  ),
                ),
                _circleAnimation.value == Alignment.centerLeft
                    ? const Padding(
                        padding: EdgeInsets.only(right: 45 - 17)
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
