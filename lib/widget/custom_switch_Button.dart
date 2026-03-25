import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';

class CustomSwitchButton extends StatelessWidget {
  final bool? isSelected;
  final GestureTapCallback? onTap;
  final BoxBorder? border;

  const CustomSwitchButton({
    super.key,
    this.isSelected,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 23.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: isSelected == true ? AppColors.yellowButtonColor : AppColors.textColor,
          border: isSelected == true ? Border.all(color: Colors.transparent) : border,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 4,
              left: isSelected == true ? 22.0 : 3.0,
              right: isSelected == true ? 3.0 : 22.0,
              bottom: 4,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected == true ? AppColors.textColor : AppColors.yellowButtonColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
