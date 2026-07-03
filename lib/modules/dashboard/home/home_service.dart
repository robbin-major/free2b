import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/enum/common_enums.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:intl/intl.dart';

import 'model/category_model.dart';

class HomeScreenService {
  static Future<List<EventModel>> getEventData() async {
    try {
      final String userID = AuthSessionService.userId;
      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot =
          await collectionRef.where("uid", isNotEqualTo: userID).where("status", isEqualTo: EventStatus.APPROVAL.eventType).get();
      for (var element in querySnapshot.docs) {
        final EventModel eventModel = EventModel.fromJson(element.data() as Map<String, dynamic>);
        eventList.add(eventModel.copyWith(eventID: element.id));
      }

      eventList.removeWhere(
        (element) => !_isVisibleUpcomingEvent(element),
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

  static Future<List<EventModel>> getCalendarEventData() async {
    try {
      final String userID = AuthSessionService.userId;
      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot = await collectionRef
          .where("uid", isNotEqualTo: userID)
          .where("status", isEqualTo: EventStatus.APPROVAL.eventType)
          .get();

      for (var element in querySnapshot.docs) {
        final EventModel eventModel =
            EventModel.fromJson(element.data() as Map<String, dynamic>);
        eventList.add(eventModel.copyWith(eventID: element.id));
      }

      eventList.removeWhere(
        (element) => EventDateUtils.parseEventDateTime(element.startDate) == null,
      );

      eventList.sort((a, b) {
        final DateTime? aDate = EventDateUtils.parseEventDateTime(a.startDate);
        final DateTime? bDate = EventDateUtils.parseEventDateTime(b.startDate);

        if (aDate == null || bDate == null) {
          return 0;
        }

        return aDate.compareTo(bDate);
      });

      return eventList;
    } catch (error, st) {
      print("GET CALENDAR EVENT ERROR $error --- $st");
      rethrow;
    }
  }

  static Future<List<EventModel>> getMyEventData({required EventStatus eventStatus}) async {
    try {
      final String userID = AuthSessionService.userId;
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
      final String userID = AuthSessionService.userId;
      if (userID.isNotEmpty) {
        CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
        final userData = await collectionRef.doc(userID).get();
        final Object? data = userData.data();
        if (data is! Map<String, dynamic>) {
          return AppPreference.getUser();
        }
        final UserModel userModel = UserModel.fromJson(data);
        AppPrefService.setEmail(userEmail: (userModel.email ?? ''));
        AppPrefService.setName(userName: "${(userModel.firstName ?? '')} ${(userModel.lastName ?? '')}");
        AppPrefService.setProfilePhoto(userProfilePhoto: (userModel.profilePhoto ?? ''));
        AppPreference.setUser(userModel);
        return userModel;
      }
      return null;
    } catch (error) {
      print("GET USER DATA ERROR $error");
      return AppPreference.getUser();
    }
  }

  static Future<void> eventBookmark({required List<String> bookmarkList}) async {
    try {
      final String userID = AuthSessionService.userId;
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
      await collectionRef.doc(userID).update({"bookmark": bookmarkList});
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> eventAttendance({
    required String eventId,
    required bool attending,
  }) async {
    try {
      final String userID = AuthSessionService.userId;
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('users');
      if (userID.isEmpty || eventId.isEmpty) {
        return;
      }
      await collectionRef.doc(userID).set(
        {
          "attending": attending
              ? FieldValue.arrayUnion([eventId])
              : FieldValue.arrayRemove([eventId]),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<List<EventModel>> getAttendingEvents({required bool attended}) async {
    try {
      final UserModel? userModel = await getUserData();
      final List<String> attendingIds = userModel?.attending ?? [];

      if (attendingIds.isEmpty) {
        return <EventModel>[];
      }

      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot =
          await collectionRef.where("status", isEqualTo: EventStatus.APPROVAL.eventType).get();

      for (var element in querySnapshot.docs) {
        if (attendingIds.contains(element.id)) {
          final EventModel eventModel =
              EventModel.fromJson(element.data() as Map<String, dynamic>);
          eventList.add(eventModel.copyWith(eventID: element.id));
        }
      }

      eventList.removeWhere((element) {
        final DateTime? eventDate =
            EventDateUtils.parseEventDateTime(element.startDate);

        if (eventDate == null) {
          return true;
        }

        final bool eventEnded = _hasEventEnded(element, fallbackDate: eventDate);
        return attended ? !eventEnded : eventEnded;
      });

      eventList.sort((a, b) {
        final DateTime? aDate = EventDateUtils.parseEventDateTime(a.startDate);
        final DateTime? bDate = EventDateUtils.parseEventDateTime(b.startDate);

        if (aDate == null || bDate == null) {
          return 0;
        }

        return attended ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
      });

      return eventList;
    } catch (error, st) {
      print("GET ATTENDING EVENT ERROR $error --- $st");
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

  static bool _isVisibleUpcomingEvent(EventModel event) {
    if (_hasInvalidEventStartDate(event.startDate)) {
      return false;
    }

    final DateTime? startDate = EventDateUtils.parseEventDateTime(event.startDate);

    if (startDate == null) {
      return false;
    }

    return !_hasEventEnded(event, fallbackDate: startDate);
  }

  static bool _hasEventEnded(EventModel event, {DateTime? fallbackDate}) {
    final DateTime? endDate = EventDateUtils.parseEventDateTime(event.endDate);
    final DateTime? effectiveDate = endDate ?? fallbackDate ?? EventDateUtils.parseEventDateTime(event.startDate);

    return effectiveDate != null && EventDateUtils.hasEventEnded(effectiveDate);
  }

  static bool _hasInvalidEventStartDate(String? startDate) {
    final String value = startDate ?? '';

    return (value.isEmpty ||
        value == " " ||
        value == "Invalid date  undefined" ||
        value.contains("Invalid") ||
        value.contains("date") ||
        value.contains("undefined"));
  }
}
