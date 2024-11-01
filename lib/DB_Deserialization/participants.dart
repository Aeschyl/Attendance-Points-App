import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';

class Participant {
  String? status;
  UserData? user;

  Participant({this.status, this.user});

  Participant.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return """{
      status: ${status},
      user: ${user?.toString()},
    }""";
  }
}
