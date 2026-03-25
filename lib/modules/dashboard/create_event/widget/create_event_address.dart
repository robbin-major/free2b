import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/create_event/controller/create_event_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/widget/custom_textfeild.dart';
import 'package:get/get.dart';
import '../../../../utils/size_utils.dart';
import '../../../../widget/for_use_country_pick/src/country_state_city_picker.dart';

class CreateEventAddress extends StatefulWidget {
  CreateEventAddress({Key? key}) : super(key: key);

  @override
  State<CreateEventAddress> createState() => _CreateEventAddressState();
}

class _CreateEventAddressState extends State<CreateEventAddress> {
  final CreateEventController _createEventController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          commonCustomTextField(
            controller: _createEventController.addressController.value,
            labelText: AppString.address.tr,
            hintText: AppString.enterAddressHere.tr,
          ).paddingSymmetric(vertical: 5.h),
          commonCustomTextField(
            controller: _createEventController.zipCodeController.value,
            labelText: AppString.zipCode.tr,
            hintText: AppString.enterZipCode.tr,
          ).paddingSymmetric(vertical: 5.h),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: SizeUtils.fSize_13(),
              color: AppColors.textColor,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              label: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppString.type.tr,
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              // labelText: "Category",
              filled: true,
              fillColor: AppColors.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              // Add more decoration..
            ),
            hint: Text(
              AppString.selectYourType.tr,
              style: TextStyle(
                color: AppColors.textColor.withAlpha(60),
                fontWeight: FontWeight.w500,
                fontSize: SizeUtils.fSize_13(),
                letterSpacing: 0.5,
              ),
            ),
            items: _createEventController.categoryType
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item.tr,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: SizeUtils.fSize_13(),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ))
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select type.';
              }
              return null;
            },
            onChanged: (value) {
              _createEventController.categoryTypeController.value.text = value.toString();
            },
            onSaved: (value) {
              _createEventController.categoryTypeController.value.text = value.toString();
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ).paddingOnly(bottom: 5.h, top: 5.h),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: SizeUtils.fSize_13(),
              color: AppColors.textColor,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              label: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppString.category.tr,
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              // labelText: "Category",
              filled: true,
              fillColor: AppColors.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
                borderSide: BorderSide(color: AppColors.disableButtonColor),
              ),
              // Add more decoration..
            ),
            hint: Text(
              AppString.selectYourCategory.tr,
              style: TextStyle(
                color: AppColors.textColor.withAlpha(60),
                fontWeight: FontWeight.w500,
                fontSize: SizeUtils.fSize_13(),
                letterSpacing: 0.5,
              ),
            ),
            items: _createEventController.categoryItems.map((item) {
              return DropdownMenuItem(
                value: item,
                //disable default onTap to avoid closing menu when selecting an item
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    final isSelected = _createEventController.selectedCategory.contains(item);
                    return ListTile(
                      onTap: () {
                        isSelected ? _createEventController.selectedCategory.remove(item) : _createEventController.selectedCategory.add(item);

                        setState(() {});
                        menuSetState(() {});
                        _createEventController.selectedCategory
                            .addIf(_createEventController.selectedCategory == _createEventController.categoryItems, item);
                        print("000${_createEventController.selectedCategory}");
                      },
                      trailing: isSelected ? const Icon(Icons.check_box_outlined) : const Icon(Icons.check_box_outline_blank),
                      title: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            value: _createEventController.selectedCategory.isEmpty ? null : _createEventController.selectedCategory.last,
            selectedItemBuilder: (context) {
              return _createEventController.categoryItems.map(
                (item) {
                  return Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _createEventController.selectedCategory.join(', '),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  );
                },
              ).toList();
            },
            validator: (value) {
              if (value == null) {
                return 'Please select type.';
              }
              return null;
            },
            onChanged: (value) {
              print("object");
              print("onChanged :${_createEventController.selectedCategory} ::::::::::: $value");
            },
            onSaved: (value) {
              // log("onSaved :${_createEventController.selectedItems} ::::::::::: $value");
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ).paddingOnly(bottom: 5.h, top: 5.h),
          // DropdownButtonFormField2<String>(
          //   isExpanded: true,
          //   style: TextStyle(
          //     fontWeight: FontWeight.w500,
          //     fontSize: SizeUtils.fSize_13(),
          //     color: AppColors.textColor,
          //     letterSpacing: 0.5,
          //   ),
          //   decoration: InputDecoration(
          //     label: Padding(
          //       padding: EdgeInsets.only(left: 12),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Text(
          //             AppString.category.tr,
          //             style: TextStyle(color: AppColors.textColor),
          //           ),
          //         ],
          //       ),
          //     ),
          //     // labelText: "Category",
          //     filled: true,
          //     fillColor: AppColors.backgroundColor,
          //     contentPadding: const EdgeInsets.symmetric(vertical: 16),
          //     disabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(8.r)),
          //       borderSide: BorderSide(color: AppColors.disableButtonColor),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(8.r)),
          //       borderSide: BorderSide(color: AppColors.disableButtonColor),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(8.r)),
          //       borderSide: BorderSide(color: AppColors.disableButtonColor),
          //     ),
          //     // Add more decoration..
          //   ),
          //   hint: Text(
          //     AppString.selectYourCategory.tr,
          //     style: TextStyle(
          //       color: AppColors.textColor.withAlpha(60),
          //       fontWeight: FontWeight.w500,
          //       fontSize: SizeUtils.fSize_13(),
          //       letterSpacing: 0.5,
          //     ),
          //   ),
          //   items: _createEventController.categoryItems
          //       .map((item) => DropdownMenuItem<String>(
          //             value: item,
          //             child: Text(
          //               item.tr,
          //               style: TextStyle(
          //                 color: AppColors.textColor,
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: SizeUtils.fSize_13(),
          //                 letterSpacing: 0.5,
          //               ),
          //             ),
          //           ))
          //       .toList(),
          //   validator: (value) {
          //     if (value == null) {
          //       return 'Please select Category.';
          //     }
          //     return null;
          //   },
          //   onChanged: (value) {
          //     //Do something when selected item is changed.
          //     _createEventController.categoryController.value.text = value.toString();
          //   },
          //   onSaved: (value) {
          //     _createEventController.categoryController.value.text = value.toString();
          //   },
          //   buttonStyleData: const ButtonStyleData(
          //     padding: EdgeInsets.only(right: 8),
          //   ),
          //   iconStyleData: const IconStyleData(
          //     icon: Icon(
          //       Icons.arrow_drop_down,
          //       color: Colors.black45,
          //     ),
          //     iconSize: 24,
          //   ),
          //   dropdownStyleData: DropdownStyleData(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //   ),
          //   menuItemStyleData: const MenuItemStyleData(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //   ),
          // ).paddingOnly(bottom: 5.h, top: 5.h),

          CountryStateCityPicker(
                  country: _createEventController.countryController.value,
                  state: _createEventController.stateController.value,
                  city: _createEventController.cityController.value,
                  dialogColor: Colors.grey.shade200,
                  textFieldDecoration: InputDecoration(
                      fillColor: Colors.blueGrey.shade100,
                      filled: true,
                      suffixIcon: const Icon(Icons.arrow_downward_rounded),
                      border: const OutlineInputBorder(borderSide: BorderSide.none)))
              .paddingOnly(bottom: 5.h),
          // commonCustomTextField(
          //   controller: _createEventController.aptController.value,
          //   labelText: AppString.aptSuiteOther,
          //   hintText: AppString.enterAptSuiteOtherHere,
          // ).paddingSymmetric(vertical: 5.h),
        ],
      ),
    );
  }

  Widget commonCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool enabled = true,
  }) {
    return CustomTextField(
      controller: controller,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(color: AppColors.textColor),
      fillColor: AppColors.backgroundColor,
      labelText: labelText.tr,
      hintText: hintText.tr,
      enabled: enabled,
    );
  }
}
