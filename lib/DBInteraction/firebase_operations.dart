import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../DB_Deserialization/event.dart';

Future<UserData> getUserData(String email) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var userData = await db.collection("users").doc(email).get();
  UserData serializedUserData = UserData.fromJson(userData.data()!);
  return serializedUserData;
}

Future<List<Event>> getEvents() async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Event> result = [];
  await db.collection("events").get().then((event) {
    for (var doc in event.docs) {
      result.add(Event.fromJson(doc.data()));
    }
  });
  return result;
}

Future<List<UserData>> getUsers() async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var userData = await db.collection("users").get();
  List<UserData> users = [];
  for (var user in userData.docs) {
    users.add(UserData.fromJson(user.data()));
  }
  return users;
}

Future<Event> getEvent(String docID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var event = await db.collection("events").doc(docID).get();
  return Event.fromJson(event.data()!);
}
