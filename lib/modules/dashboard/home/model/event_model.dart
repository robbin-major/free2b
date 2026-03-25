import 'dart:convert';

List<EventModel> eventModelFromJson(String str) =>
    List<EventModel>.from(json.decode(str).map((x) => EventModel.fromJson(x)));

String eventModelToJson(List<EventModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventModel {
  final String? country;
  final String? uid;
  final String? address;
  final String? zipCode;
  final String? city;
  final int? createdAt;
  final List<String>? description;
  final String? image;
  final String? state;
  final String? title;
  final String? aptSuiteOther;
  final String? startDate;
  final String? status;
  final String? eventID;
  final List<Category>? category;
  final String? categoryType;

  EventModel({
    this.image,
    this.country,
    this.uid,
    this.address,
    this.zipCode,
    this.city,
    this.createdAt,
    this.description,
    this.state,
    this.title,
    this.aptSuiteOther,
    this.startDate,
    this.status,
    this.eventID,
    this.category,
    this.categoryType,
  });

  @override
  EventModel copy() =>
      EventModel(
        image: image,
        country: uid,
        address: address,
        description: description,
        state: state,
        title: title,
        createdAt: createdAt,
        aptSuiteOther: aptSuiteOther,
        startDate: startDate,
        status: status,
        eventID: eventID,
        zipCode: zipCode,
        category: category,
        categoryType: categoryType,
      );

  @override
  EventModel copyWith({String? country,
    String? uid,
    String? address,
    String? city,
    List<String>? description,
    String? startTime,
    String? image,
    String? state,
    int? createdAt,
    String? title,
    String? aptSuiteOther,
    String? startDate,
    String? status,
    String? eventID,
    List<Category>? category,
    String? categoryType,
    String? zipCode}) =>
      EventModel(
        country: country ?? this.country,
        uid: uid ?? this.uid,
        address: address ?? this.address,
        city: city ?? this.city,
        description: description ?? this.description,
        image: image ?? this.image,
        state: state ?? this.state,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        aptSuiteOther: aptSuiteOther ?? this.aptSuiteOther,
        startDate: startDate ?? this.startDate,
        status: status ?? this.status,
        eventID: eventID ?? this.eventID,
        zipCode: zipCode ?? this.zipCode,
        category: category ?? this.category,
        categoryType: categoryType ?? this.categoryType,
      );

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      EventModel(
        country: json["country"],
        uid: json["uid"],
        image: json["image"],
        address: json["address"],
        city: json["city"],
        description: json["description"] == null
            ? []
            : List<String>.from(json["description"]!.map((x) => x)),
        state: json["state"],
        title: json["title"],
        createdAt: json["createdAt"],
        aptSuiteOther: json["Apt/Suite/Other"],
        startDate: json["startDate"],
        status: json["status"],
        // category: json["category"] == null ? [] : List<Category>.from(json["category"]!.map((x) => x)),
        category: json["category"] == null
            ? []
            : List<Category>.from(
            json["category"].map((x) => Category.fromJson(x))),

        zipCode: json["zipCode"],
        categoryType: json["categoryType"],
      );

  Map<String, dynamic> toJson() =>
      {
        "country": country ?? '',
        "uid": uid ?? '',
        "image": image ?? '',
        "address": address ?? '',
        "city": city ?? '',
        "description": description == null
            ? []
            : List<dynamic>.from(description!.map((x) => x)),
        "state": state ?? '',
        "title": title ?? '',
        "createdAt": createdAt ?? '',
        "Apt/Suite/Other": aptSuiteOther ?? '',
        "startDate": startDate ?? '',
        "status": status ?? '',
        "category": category == null
            ? []
            : List<dynamic>.from(category?.map((x) => x.toJson()) ?? []),
        "zipCode": zipCode ?? '',
        "categoryType": categoryType ?? '',
      };
}

class Category {
  String? categoryId;
  String? categoryName;

  Category({
    this.categoryId,
    this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
      );

  Map<String, dynamic> toJson() =>
      {
        "categoryId": categoryId,
        "categoryName": categoryName,
      };
}
