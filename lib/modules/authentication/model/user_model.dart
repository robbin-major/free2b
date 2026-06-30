class UserModel {
  String? email;
  String? profilePhoto;
  String? firstName;
  String? lastName;
  List<String>? bookmark;
  List<String>? attending;

  UserModel({
    this.email,
    this.profilePhoto,
    this.firstName,
    this.lastName,
    this.bookmark,
    this.attending,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    profilePhoto = json['profilePhoto'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    bookmark = List<String>.from(json['bookmark'] ?? []);
    attending = List<String>.from(json['attending'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['profilePhoto'] = profilePhoto;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['bookmark'] = bookmark ?? [];
    data['attending'] = attending ?? [];
    return data;
  }
}
