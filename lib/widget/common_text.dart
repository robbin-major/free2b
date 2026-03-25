import 'package:flutter/material.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:get/get.dart';

class CommonText extends StatelessWidget {
  final double? fontSize;
  final FontWeight? fontWeight;
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final List<Shadow>? shadows;
  final TextDecoration? textDecoration;
  final TextOverflow? overflow;
  final int? maxLine;
  final Paint? foreground;
  final bool? isForeground;
  final bool? softWrap;
  final Color? decorationColor;

  const CommonText({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.textAlign,
    this.shadows,
    this.textDecoration,
    this.overflow,
    this.maxLine,
    this.foreground,
    this.isForeground = false,
    this.softWrap = true,
    this.decorationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      textAlign: textAlign,
      maxLines: maxLine,
      softWrap: softWrap,
      style: TextStyle(
        overflow: overflow,
        color: color ?? AppColors.textColor,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w400,
        shadows: shadows ?? [],
        decoration: textDecoration,
        decorationColor: decorationColor ?? AppColors.textColor,
      ),
    );
  }
}
