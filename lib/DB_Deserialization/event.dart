import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/participants.dart';

class Event {
  String? title;
  Timestamp? date;
  DateTime? dt;
  String? documentId;
  List<Participant>? participants;
  List<dynamic>? assignedOfficers;
  String? place;
  String? category;
  int? points;
  int? maximumAttendees;
  Event(
      {this.title,
      this.date,
      this.documentId,
      this.participants,
      this.assignedOfficers,
      this.place,
      this.category,
      this.points,
      this.maximumAttendees});

  Event.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    dt = date!.toDate();
    if (json['participants'] != null) {
      participants = <Participant>[];
      json['participants'].forEach((v) {
        participants!.add(Participant.fromJson(v));
      });
    }
    assignedOfficers = json['assignedOfficers'] ?? [];
    place = json['place'];
    points = json['points'];
    category = json['category'];
    maximumAttendees = json['maximumAttendees'];
  }
  void addID(String id) {
    documentId = id;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['date'] = date;
    if (participants != null) {
      data['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    data['place'] = place;
    data['points'] = points;
    data['category'] = category;
    data['maximumAttendees'] = maximumAttendees;
    data['assignedOfficers'] = assignedOfficers;
    return data;
  }

  /*@override
  String toString() {
    return toJson().toString();
  } */

  String prettyDate() {
    try {
      String minute = "${dt!.minute}";
      if ("${dt!.minute}".length <= 1) {
        minute = "0${dt!.minute}";
      }
      return "${dt!.month}/${dt!.day}/${dt!.year} - ${dt!.hour}:$minute";
    } catch (e) {
      return "FAILED";
    }
  }
}
