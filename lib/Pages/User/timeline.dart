// Flutter Widgets
import 'package:fbla_lettering_point_app/Resources/grid_item.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// API Requests
import 'package:fbla_lettering_point_app/DB_Deserialization/event.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Utilities
import 'package:fbla_lettering_point_app/Resources/pretty_date.dart';

import '../../DBInteraction/firebase_operations.dart';
import '../../DB_Deserialization/user.dart';
import '../../Resources/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class Timeline extends ConsumerWidget {
  Timeline({Key? key}) : super(key: key);
  final eventsProvider = FutureProvider<List<Event>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Event> result = [];
    await db.collection("events").orderBy("date", descending: true).get().then(
      (event) {
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
      },
    );
    return result;
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Event>> events = ref.watch(eventsProvider);
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ProfileAppBar(title: "Event Timeline", providers: [
          eventsProvider,
        ]),
      ),
      body: events.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => ErrorMessage('Error: $err'),
        data: (items) {
          List<GridItemUser> widgetList = [];
          for (Event i in items) {
            // could add a sort by date here
            widgetList.add(
              GridItemUser(
                title: i.title!,
                place: i.place!,
                points: i.points!,
                event: i,
                docID: i.documentId!,
              ),
            );
          }
          if (kIsWeb && MediaQuery.of(context).size.width > 657.0) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: widgetList,
                  ),
                ));
          } else if (kIsWeb && MediaQuery.of(context).size.width <= 657.0) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: widgetList,
                  ),
                )));
          } else if (Platform.isAndroid || Platform.isIOS) {
            return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: widgetList,
                  ),
                )));
          }
        },
      ),
    );
  }
}
