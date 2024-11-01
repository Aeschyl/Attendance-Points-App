import 'package:fbla_lettering_point_app/DB_Deserialization/category_points.dart';

class UserData {
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  String? role;
  CategoryPoints? categoryPoints;

  UserData(
      {this.email,
      this.firstName,
      this.lastName,
      this.fullName,
      this.categoryPoints,
      this.role});

  UserData.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    fullName = json['fullName'];
    role = json['role'];
    categoryPoints = json['categoryPoints'] != null
        ? CategoryPoints.fromJson(json['categoryPoints'])
        : null;
  }
  void setRole(String r) {
    if (r == "user") {
      role = "user";
    } else if (r == "admin") {
      role = "admin";
    } else if (r == "officer") {
      role = "officer";
    } else {
      throw Error();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['fullName'] = fullName;
    data['role'] = role;
    if (categoryPoints != null) {
      data['categoryPoints'] = categoryPoints!.toJson();
    }
    return data;
  }

  /*@override
  String toString() {
    return toJson().toString();
  }*/
}
