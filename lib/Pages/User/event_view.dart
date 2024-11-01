// Flutter Widgets
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/Pages/signup.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/pretty_date.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// API Request stuff
import 'package:fbla_lettering_point_app/DB_Deserialization/event.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../DBInteraction/firebase_operations.dart';
import '../../DB_Deserialization/user.dart';
import '../../main.dart';

class EventView extends ConsumerWidget {
  EventView({required this.docID, Key? key}) : super(key: key);

  final String docID;
  final eventsProvider = FutureProvider<List<Event>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Event> result = [];
    await db.collection("events").get().then((event) {
      Event temp;
      for (var doc in event.docs) {
        temp = Event.fromJson(
          doc.data(),
        );
        temp.addID(doc.id);
        result.add(
          temp,
        );
      }
    });
    return result;
  });

  final userProvider = FutureProvider<List<UserData>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var userData = await db.collection("users").get();
    List<UserData> users = [];
    for (var user in userData.docs) {
      users.add(UserData.fromJson(user.data()));
    }
    return users;
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Event>> events = ref.watch(eventsProvider);
    AsyncValue<List<UserData>> users = ref.watch(userProvider);

    final auth = ref.watch(authProvider);
    Widget eventLoaded = events.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => ErrorMessage('Error: $err'),
      data: (items) {
        Event event = items[items.indexWhere(
          (element) => element.documentId == docID,
        )];
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: Center(
                child: Text(
                  "${event.title}",
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              subtitle: Center(
                child: Text(
                  event.prettyDate(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "${event.place}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            /* Expanded(
                 child: Container(
                   decoration: const BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.all(
                       Radius.circular(12.0),
                     ),
                   ),
                   child: ListView.builder(
                     itemCount: event.participants!.length,
                     itemBuilder: (context, index) {
                       return Center(
                         child: Text(event.participants![index].user!.fullName!),
                       );
                     },
                   ),
                 ),
               )*/
          ],
        );
      },
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ProfileAppBar(
            title: "Event Timeline", providers: [eventsProvider, userProvider]),
      ),
      body: Center(
        child: eventLoaded,
      ),
    );
  }
}
