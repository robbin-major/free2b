import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/enum/common_enums.dart';

class BookMarkService {
  static Future<List<EventModel>> getBookmarkEvent() async {
    try {
      final UserModel? userModel = AppPreference.getUser();
      final List<EventModel> eventList = <EventModel>[];
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('event');
      QuerySnapshot querySnapshot = await collectionRef.where("status", isEqualTo: EventStatus.APPROVAL.eventType).get();
      print("userModel ${userModel?.bookmark?.length}");
      for (var element in querySnapshot.docs) {
        for (var bookMarkId in userModel?.bookmark ?? []) {
          if (bookMarkId == element.id) {
            final EventModel eventModel = EventModel.fromJson(element.data() as Map<String, dynamic>);
            eventList.add(eventModel.copyWith(eventID: element.id));
          }
        }
      }

      // eventList.sort((a, b) {
      //   return (a.startDate ?? "").compareTo(b.startDate ?? "");
      // });
      return eventList;
    } catch (error, st) {
      print("GET BOOK MARK EVENT ERROR $error --- $st");
      rethrow;
    }
  }
}
