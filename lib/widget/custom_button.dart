import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/size_utils.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:get/get.dart';

class CustomButton extends StatefulWidget {
  final double? height;
  final VoidCallback? onTap;
  final double? width;
  final double? fontSize;
  final FontWeight fontWeight;
  final String text;
  final String? svg;
  final String? endSvg;
  final Color? buttonColor;
  final Color? disableButtonColor;
  final Color? buttonBorderColor;
  final Color? textColor;
  final Color? disableTextColor;
  final bool needBorderColor;
  final bool isDisabled;
  final bool isLoader;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    this.height,
    this.width,
    required this.text,
    this.svg,
    this.endSvg,
    this.buttonBorderColor,
    this.buttonColor,
    this.fontWeight = FontWeight.w600,
    this.fontSize,
    this.textColor,
    this.onTap,
    this.padding,
    this.isDisabled = false,
    this.isLoader = false,
    this.disableButtonColor,
    this.disableTextColor,
    this.needBorderColor = true,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final buttonButton =
        (widget.isDisabled) ? widget.disableButtonColor ?? AppColors.disableButtonColor : widget.buttonColor ?? AppColors.yellowButtonColor;
    return GestureDetector(
      onTap: (widget.isLoader || widget.isDisabled) ? null : widget.onTap,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: widget.padding ?? EdgeInsets.all(12.sp),
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
          color: buttonButton,
          border: Border.all(
            color: (widget.needBorderColor) ? buttonButton : Colors.transparent,
          ),
        ),
        child: Center(
          child: widget.isLoader
              ? CustomLoadingWidget(
                  color: Colors.white,
                  size: SizeUtils.verticalBlockSize * 3,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.svg != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            widget.svg!,
                            color: (widget.isDisabled)
                                ? widget.disableTextColor ?? AppColors.textColor.withOpacity(0.6)
                                : widget.textColor ?? Colors.white,
                            height: 24,
                          ),
                          SizedBox(
                            width: SizeUtils.horizontalBlockSize * 3,
                          )
                        ],
                      ),
                    Text(
                      widget.text.toString().tr,
                      style: TextStyle(
                        fontSize: widget.fontSize ?? 16.sp,
                        fontWeight: widget.fontWeight,
                        color:
                            (widget.isDisabled) ? widget.disableTextColor ?? AppColors.textColor.withOpacity(0.6) : widget.textColor ?? Colors.white,
                      ),
                    ),
                    if (widget.endSvg != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: SizeUtils.horizontalBlockSize * 3,
                          ),
                          SvgPicture.asset(
                            widget.endSvg!,
                            color: (widget.isDisabled)
                                ? widget.disableTextColor ?? AppColors.textColor.withOpacity(0.6)
                                : widget.textColor ?? Colors.white,
                            height: 20,
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
