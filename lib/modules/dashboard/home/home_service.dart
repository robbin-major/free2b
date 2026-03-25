import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/enum/common_enums.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:intl/intl.dart';

import 'model/category_model.dart';

class HomeScreenService {
  static Future<List<EventModel>> getEventData() async {
    try {
      final String userID = AppPrefService.getUserUid();
      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot =
          await collectionRef.where("uid", isNotEqualTo: userID).where("status", isEqualTo: EventStatus.APPROVAL.eventType).get();
      for (var element in querySnapshot.docs) {
        final EventModel eventModel = EventModel.fromJson(element.data() as Map<String, dynamic>);
        eventList.add(eventModel.copyWith(eventID: element.id));
      }

      eventList.removeWhere(
        (element) {
          print("${element.title} :::::::::::::date time check 001 ${element.startDate!.split(" ")[1]}");
          return ((element.startDate?.isEmpty ?? true) || element.startDate == " " || element.startDate == "Invalid date  undefined") ||
              (element.startDate!.contains("Invalid") ||
                  element.startDate!.contains("date") ||
                  element.startDate!.contains("undefined") /*||
                element.startDate!.split(" ")[1].isEmpty*/
              );
        },
      );

      eventList.sort((a, b) {
        return (Utils.getFormattedDate(format: "MM-dd-yyyy", date: a.startDate ?? ""))
            .compareTo(Utils.getFormattedDate(format: "MM-dd-yyyy", date: b.startDate ?? ""));
      });
      return eventList;
    } catch (error, st) {
      print("GET EVENT ERROR $error --- $st");
      rethrow;
    }
  }

  static Future<List<EventModel>> getMyEventData({required EventStatus eventStatus}) async {
    try {
      final String userID = AppPrefService.getUserUid();
      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot = await collectionRef.where("status", isEqualTo: eventStatus.eventType).where("uid", isEqualTo: userID).get();
      for (var element in querySnapshot.docs) {
        final EventModel eventModel = EventModel.fromJson(element.data() as Map<String, dynamic>);
        eventList.add(eventModel.copyWith(eventID: element.id));
      }
      eventList.removeWhere(
        (element) {
          return ((element.startDate?.isEmpty ?? true) ||
                  element.startDate == " " ||
                  (element.startDate!.contains("Invalid") ||
                      element.startDate!.contains("date") ||
                      element.startDate!.contains("undefined")) /*||
            element.startDate!.split(" ")[1].isEmpty*/
              );
        },
      );

      eventList.sort((a, b) {
        print(
            "compare :::::${Utils.getFormattedDate(format: "MM-dd-yyyy", date: a.startDate ?? "")} ::::::::::: ${Utils.getFormattedDate(format: "MM-dd-yyyy", date: b.startDate ?? "")}");

        return (Utils.getFormattedDate(format: "MM-dd-yyyy", date: a.startDate ?? ""))
            .compareTo(Utils.getFormattedDate(format: "MM-dd-yyyy", date: b.startDate ?? ""));
      });

      return eventList;
    } catch (error, st) {
      print("GET MY EVENT ERROR $error --- $st");
      rethrow;
    }
  }

  static Future<UserModel?> getUserData() async {
    try {
      final String userID = AppPrefService.getUserUid();
      if (userID.isNotEmpty) {
        CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
        final userData = await collectionRef.doc(userID).get();
        final UserModel userModel = UserModel.fromJson(userData.data() as Map<String, dynamic>);
        AppPrefService.setEmail(userEmail: (userModel.email ?? ''));
        AppPrefService.setName(userName: "${(userModel.firstName ?? '')} ${(userModel.lastName ?? '')}");
        AppPrefService.setProfilePhoto(userProfilePhoto: (userModel.profilePhoto ?? ''));
        AppPreference.setUser(userModel);
        return userModel;
      }
      return null;
    } catch (error) {
      rethrow;
    }
    return null;
  }

  static Future<void> eventBookmark({required List<String> bookmarkList}) async {
    try {
      final String userID = AppPrefService.getUserUid();
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
      await collectionRef.doc(userID).update({"bookmark": bookmarkList});
    } catch (error) {
      rethrow;
    }
  }

  static Future<List<CategoryModel>> fetchCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('category').get();
    querySnapshot.docs.forEach((element) {
      // print(element.data());
    });
    return querySnapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }
}
