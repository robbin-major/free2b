import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.title,
    this.automaticallyImplyLeading,
    this.actions,
    this.centerTitle,
    this.appBarSize,
    this.bottom,
    this.leading,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.fontColor,
    this.leadingWidth,
  }) : super(key: key);
  final String title;
  final double? leadingWidth;
  final bool? automaticallyImplyLeading;
  final bool? centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? appBarSize;
  final Widget? leading;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      leadingWidth: leadingWidth,
      leading: (automaticallyImplyLeading ?? true) && leading == null
          ?
          // GestureDetector(
          //         onTap: () {
          //           Navigation.pop();
          //         },
          //         child: Container(
          //           width: 15.w,
          //           child: Icon(
          //             Icons.arrow_back_ios_rounded,
          //             color: AppColors.blackColor,
          //             size: 2.5.h,
          //           ),
          //         ),
          //       )
          IconButton(
              onPressed: () {
                Navigation.pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.textColor,
                // size: 2.5.h,
              ),
            )
          : leading,
      elevation: 0,
      backgroundColor: color,
      title: Text(
        title.tr,
        style: TextStyle(
          color: fontColor ?? AppColors.textColor,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? 20.sp,
        ),
      ),
      centerTitle: centerTitle ?? true,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarSize ?? 50);
}
