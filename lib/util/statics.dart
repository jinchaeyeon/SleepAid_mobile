import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_images.dart';

class Statics{

}

Gradient sliderGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: <Color>[AppColors.graphStart, AppColors.graphMiddle, AppColors.graphEnd],
);

String format(String value) {
  String formatValue = value.toString().substring(0, value.toString().length - 2);
  return formatValue;
}


PreferredSize appBar(BuildContext context, String title, {bool isRound = true}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(140),
    child: Container(
      width: double.maxFinite,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
        ),
        borderRadius: isRound? const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ): BorderRadius.zero,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0, right: 0, bottom: 0, top: 0,
            child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack
                  ),
                )
            ),
          ),
          Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                height: 123,
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 36,
                ),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.back, color: Theme.of(context).primaryIconTheme.color,
                          fit: BoxFit.contain, width: 12, height: 21,

                        ),
                      ),
                    ),
                  ],
                ),
              )
          )

        ],
      ),
    ),
  );
}