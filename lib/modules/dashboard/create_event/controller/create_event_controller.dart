// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/home/model/category_model.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import '../../../../utils/app_string.dart';
import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/for_use_category/lib/multiselect_dropdown.dart';
import '../../home/home_service.dart';
import '../../home/model/event_model.dart';

class CreateEventController extends GetxController {
  RxDouble progress = 0.0.obs;
  TextEditingController titleController = TextEditingController();
  RxList<TextEditingController> descriptionController = <TextEditingController>[].obs;
  RxList<String> descriptionList = <String>[].obs;
  Rx<TextEditingController> zipCodeController = TextEditingController().obs;

  Rx<TextEditingController> categoryTypeController = TextEditingController().obs;

  // Rx<TextEditingController> categoryController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;

  DateTime? date;
  TimeOfDay? time;
  RxString dateOfBirth = ''.obs;
  RxString timeToday = ''.obs;
  RxInt dob = DateTime.now().millisecondsSinceEpoch.obs;
  RxInt convertTime = 0.obs;
  RxString pictureGallery = "".obs;
  RxBool isLoader = false.obs;
  RxBool isShowSnackBar = true.obs;

  List<String> categoryItems = [];
  List<String> selectedCategory = [];
  List<Category> selectedCategoryID = [];
  List<CategoryModel> categories = [];
  RxList<EventModel> eventData = <EventModel>[].obs;

  final List<String> categoryType = [
    AppString.citywideEvent,
    AppString.communityEvent,
    AppString.privateEvent,
  ];

  Future getCategoryData() async {
    try {
      FirebaseFirestore.instance.collection('category').get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            // print(doc.data());
            categoryItems.add(doc["name"]);
          },
        );
      });
    } catch (error, st) {
      print("GET  ERROR $error --- $st");
      rethrow;
    }
  }

  Future getEvent() async {
    eventData.value.clear();

    eventData.value = await HomeScreenService.getEventData();
    eventData.value.removeWhere((element) {

      DateTime parseDate = DateFormat("dd-MM-yyyy").parse(
        Utils.getFormattedDate(date: element.startDate.toString(), format: "dd-MM-yyyy"),
      );
      return parseDate.isBefore(DateTime.now().add(Duration(days: -1)));
    });
  }

  @override
  void onInit() {
    HomeScreenService.fetchCategories().then((value) {
      value.forEach((e) => print(e.name));
      categories = value;
      print(categories[1].catId);
    });
    getCategoryData();
    addTextField(); // Add initial text field
    getEvent();
    // TODO: implement onInit
    super.onInit();
  }

  Future<DateTime?> datePicker(context) async {
    DateTime today = DateTime.now();

    date = await showDatePicker(
      context: context,
      currentDate: today,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2054),
    );
    print("date :::: $date");

    return date;
  }

  List forUseDateList = [];
  List forUseTitleList = [];
  RxBool found = false.obs;

  Future<bool> eventChecker() async {
    forUseDateList.clear();
    forUseTitleList.clear();
    eventData.value.forEach((element) {
      DateTime elementDate = DateFormat("dd-MM-yyyy").parse(Utils.getFormattedDate(date: element.startDate.toString(), format: "dd-MM-yyyy"));
      forUseDateList.add(elementDate.toString().split(" ")[0]);
      forUseTitleList.add(element.title);
    });
    log("forUseDateList :::::: ${forUseDateList}");
    log("forUseTitleList :::::: ${forUseTitleList}");
    print("both list length ${forUseDateList.length} :::::::: ${forUseTitleList.length}");


    var dataModel = eventData.value.where((element) {
      if (!found.value) {
        log("get title ${element.title}");
        log("add title ${titleController.text}");
        log("get date ${Utils.getFormattedDate(format: "yyyy-MM-dd", date: element.startDate.toString())}");
        log("add date ${date.toString().split(" ")[0]}");
        // if (element.title?.contains(titleController.text) ?? false) {
        if (element.title.toString().trim().toLowerCase() == titleController.text.trim().toLowerCase()) {
          log("date where 01 ${Utils.getFormattedDate(format: "yyyy-MM-dd", date: element.startDate.toString()).contains(date.toString().split(" ")[0])}");
          if (Utils.getFormattedDate(format: "yyyy-MM-dd", date: element.startDate.toString()).contains(date.toString().split(" ")[0])) {
            found.value = true;
          } else {
            found.value = false;
          }
          log("found value ${found.value}");
        } else {
          found.value = false;
          log("found value 2 ${found.value}");
        }
        log("found value 3 ${found.value}");
      }
      return found.value;
    });
    log("dataModel ${dataModel}");
    return await found.value;
  }

  Future<TimeOfDay?> timePicker(context) async {
    time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return time;
  }

  void getImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      await picker.pickImage(source: ImageSource.gallery).then((value) {
        if (value != null) {
          pictureGallery.value = value.path.toString();
          // Navigation.pushNamed(Routes.pdfScreen);
        }
      });
    } catch (e) {
      // AppSnackBar.show("Pick File", e);
    }
  }

  addTextField() {
    descriptionController.add(TextEditingController());
  }

  removeTextField(int index) {
    descriptionController[index].dispose();
    descriptionController.removeAt(index);
  }

  @override
  void dispose() {
    for (var controller in descriptionController) {
      controller.dispose();
    }
    super.dispose();
  }

  CollectionReference addEventFunction = FirebaseFirestore.instance.collection('event');
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadImage() async {
    String fileName = pictureGallery.value.split("/").last;

    Reference ref = FirebaseStorage.instance.ref().child('event').child(fileName);

    try {
      // uploadLoader.value = true;
      UploadTask uploadTask = ref.putFile(File(pictureGallery.value));

      pictureGallery.value = await (await uploadTask).ref.getDownloadURL();

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {}, onError: (error) {
        // AppSnackBar.showErrorSnackBar(message: "Upload", title: "$error");
      });

      uploadTask.whenComplete(() async {
        pictureGallery.value = await ref.getDownloadURL();
        print(" pictureGallery.value ${pictureGallery.value}");
      });
    } catch (e) {
      // AppSnackBar.show("Upload", "Something went wrong");
      // uploadLoader.value = false;
    }
  }

  Future<void> createEvent() async {
    categories.forEach((element) {
      if (selectedCategory.contains(element.name)) {
        print(element.catId);
        selectedCategoryID.add(Category(categoryId: element.catId, categoryName: element.name));
      } else {
        print("object");
      }
      print(selectedCategoryID.length);
    });
    descriptionList.clear();
    for (int i = 0; i < descriptionController.length; i++) {
      if (descriptionController[i].text.isNotEmpty) {
        descriptionList.add(descriptionController[i].text.toString());
      }
    }
    print("getUserUid ${AppPrefService.getUserUid()}");

    isLoader.value = true;
    await uploadImage();
    final EventModel eventModel = EventModel(
        image: pictureGallery.value,
        title: titleController.text,
        description: descriptionList.value,
        startDate: "${dateOfBirth.value} ${timeToday.value}",
        zipCode: zipCodeController.value.text,
        category: selectedCategoryID,
        categoryType: categoryTypeController.value.text,
        address: addressController.value.text,
        city: cityController.value.text,
        country: countryController.value.text,
        state: stateController.value.text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        uid: AppPrefService.getUserUid(),
        status: "PENDING");
    print("dateTimeFormat.millisecondsSinceEpoch  ${DateTime.now().millisecondsSinceEpoch}");

    return addEventFunction.add(eventModel.toJson()).then((value) async {
      print("User Added ${value.id}");
      await addEventFunction.doc(value.id).update({"evntId": value.id});
      isLoader.value = false;
      Navigation.replaceAll(Routes.dashBoard);
    }).catchError((error) => print("Failed to add user: $error"));
  }
}
