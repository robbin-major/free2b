import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    this.side,
    this.shape,
    this.backgroundColor,
    this.leading,
    this.isLeading = true,
    this.trailing,
    this.height,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.padding,
    this.hintStyle,
    this.textStyle,
  });

  final MaterialStateProperty<BorderSide?>? side;
  final MaterialStateProperty<OutlinedBorder?>? shape;
  final MaterialStateProperty<Color?>? backgroundColor;
  final TextEditingController? controller;
  final Widget? leading;
  final Iterable<Widget>? trailing;
  final bool? isLeading;
  final double? height;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final MaterialStateProperty<EdgeInsetsGeometry?>? padding;
  final MaterialStateProperty<TextStyle?>? hintStyle;
  final MaterialStateProperty<TextStyle?>? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50.h,
      child: SearchBar(
        leading: (isLeading ?? false)
            ? leading ??
                Icon(
                  Icons.search,
                  color: AppColors.textColor,
                )
            : const SizedBox.shrink(),
        onSubmitted: onSubmitted,
        trailing: trailing,
        onChanged: onChanged,
        controller: controller,
        hintText: hintText,
        padding: padding,
        elevation: const MaterialStatePropertyAll(0),
        textStyle: textStyle ?? const MaterialStatePropertyAll(TextStyle(color: Colors.white)),
        hintStyle: hintStyle ?? MaterialStatePropertyAll(TextStyle(color: AppColors.textColor)),
        side: side,
        shape: shape ?? MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r))),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
