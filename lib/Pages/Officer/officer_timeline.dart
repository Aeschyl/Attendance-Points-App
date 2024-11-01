// Flutter Widgets
import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Pages
import 'package:fbla_lettering_point_app/Pages/User/event_view.dart';
import 'package:fbla_lettering_point_app/Pages/User/profile.dart';

// API Requests
import 'package:fbla_lettering_point_app/DB_Deserialization/event.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fbla_lettering_point_app/DBInteraction/firebase_operations.dart';

// Utilities
import 'package:fbla_lettering_point_app/Resources/pretty_date.dart';

import '../../DB_Deserialization/fill_review.dart';
import '../../DB_Deserialization/participants.dart';
import '../../DB_Deserialization/review.dart';
import '../../Resources/grid_item.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final indexProvider = StateProvider((ref) => 1);

class OfficerTimeline extends ConsumerWidget {
  OfficerTimeline({Key? key}) : super(key: key);

  int _selectedIndex = 1;
  final eventsProvider = FutureProvider<List<Event>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Event> result = [];
    var query =
        await db.collection("events").orderBy("date", descending: true).get();

    for (var doc in query.docs) {
      Event e = Event.fromJson(
        doc.data(),
      );
      e.addID(doc.id);
      result.add(e);
    }
    return result;
  });
  final eventsReviewsProvider = FutureProvider<List>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List result = [];
    var query = await db.collection("events").get();

    for (var doc in query.docs) {
      Event e = Event.fromJson(
        doc.data(),
      );
      e.addID(doc.id);
      result.add(e);
    }

    var filtered = result
        .where((element) => element.assignedOfficers!
            .any((e) => e == ref.read(authProvider).email))
        .toList();
    List<FillReview> currRevs = [];
    List<Review> rawRevs = [];
    for (var element1 in filtered) {
      var q = await FirebaseFirestore.instance
          .collection("reviews-pending")
          .where("eventID", isEqualTo: element1.documentId)
          .get();
      var listDocs = q.docs.map((e) {
        var result = Review.fromJson(e.data());
        result.addID(e.id);
        return result;
      }).toList();
      for (var nt2 in listDocs) {
        var eventQuery = await FirebaseFirestore.instance
            .collection("events")
            .doc(nt2.eventID)
            .get();
        Event e = Event.fromJson(eventQuery.data()!);
        e.addID(eventQuery.id);
        var userQuery = await FirebaseFirestore.instance
            .collection("users")
            .doc(nt2.userID)
            .get();
        UserData u = UserData.fromJson(userQuery.data()!);

        rawRevs.add(nt2);
        currRevs.add(FillReview(event: e, user: u));
      }
    }
    return [rawRevs, currRevs];
  });
  final userProvider = FutureProvider<List<UserData>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var userData = await db.collection("users").get();
    List<UserData> users = [];
    for (var user in userData.docs) {
      users.add(
        UserData.fromJson(
          user.data(),
        ),
      );
    }
    return users;
  });

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Event>> events = ref.watch(eventsProvider);
    AsyncValue<List> eventsReviews = ref.watch(eventsReviewsProvider);
    AsyncValue<List<UserData>> users = ref.watch(userProvider);
    int _selectedIndex = ref.watch(indexProvider);
    final auth = ref.watch(authProvider);

    if (auth.role != "officer") {
      /*ref.read(authProvider.state).state = UserData();
          FirebaseAuth.instance.signOut();*/
      return Scaffold(body: SignInPopup("/timeline", "Sign In"));
    } else {
      List _widgetOptions = [
        eventsReviews.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => ErrorMessage('Error: $err'),
          data: (items) {
            // [raw, curr]
            return ListView.builder(
                itemCount: items[1].length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ListTile(
                        title: Text(items[1][index].getUser().fullName!),
                        subtitle: Text(items[1][index].getEvent().title!),
                        trailing: SizedBox(
                          width: 80,
                          height: 20,
                          child: Row(children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              alignment: Alignment.center,
                              color: Colors.green,
                              onPressed: () async {
                                // print(items[0][index].runtimeType.toString() +
                                //    " asdsaASSSSSSSSSSSSSSSSSSDASDASDASDASASSSSS");
                                await FirebaseFirestore.instance
                                    .collection("reviews-approved")
                                    .doc(items[0][index].documentID)
                                    .set(items[0][index].toJson());
                                await FirebaseFirestore.instance
                                    .collection("reviews-pending")
                                    .doc(items[0][index].documentID)
                                    .delete();
                                // print("ASDASDASD" + items[0][index].eventID);
                                var event = await FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(items[0][index].eventID)
                                    .get();
                                Event tempEvent = Event.fromJson(event.data()!);
                                tempEvent.addID(event.id);

                                /*for (int i = 0;
                                    i < tempEvent.participants!.length;
                                    i++) {
                                  if (tempEvent.participants![i].user!.email ==
                                      items[0][index].userID) {
                                    // print(tempEvent.participants![i].approved);
                                    // print("ASDASDASDASD");
                                  }
                                }*/
                                for (Participant p in tempEvent.participants!) {
                                  if (p.user!.email == items[0][index].userID) {
                                    p.status = "Approved";
                                    break;
                                  }
                                }
                                /*for (int i = 0;
                                    i < tempEvent.participants!.length;
                                    i++) {
                                  if (tempEvent.participants![i].user!.email ==
                                      items[0][index].userID) {
                                    // print(tempEvent.participants![i].approved);
                                    // print("ASDASDASDASD");
                                  }
                                }*/
                                await FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(items[0][index].eventID)
                                    .set(tempEvent.toJson());

                                var user = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(items[0][index].userID)
                                    .get();
                                UserData tempUser =
                                    UserData.fromJson(user.data()!);
                                switch (tempEvent.category) {
                                  case "Social":
                                    tempUser.categoryPoints!.social =
                                        tempUser.categoryPoints!.social! +
                                            tempEvent.points!;
                                    break;
                                  case "Competitive Prep":
                                    tempUser.categoryPoints!.competitivePrep =
                                        tempUser.categoryPoints!
                                                .competitivePrep! +
                                            tempEvent.points!;
                                    break;
                                  case "Community Service":
                                    tempUser.categoryPoints!
                                        .communityServiceFundraising = tempUser
                                            .categoryPoints!
                                            .communityServiceFundraising! +
                                        tempEvent.points!;
                                    break;
                                  case "Other":
                                    tempUser.categoryPoints!.other =
                                        tempUser.categoryPoints!.other! +
                                            tempEvent.points!;
                                    break;
                                }

                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(items[0][index].userID)
                                    .set(tempUser.toJson());
                                ref.refresh(eventsReviewsProvider);
                                ref.refresh(eventsProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              alignment: Alignment.center,
                              color: Colors.red,
                              splashRadius: 20,
                              onPressed: () async {
                                // print(
                                //    "asdasdasdASDASDA ${items[0][index].documentID}");
                                // print(items[0][index].runtimeType.toString() +
                                //    " asdsaASSSSSSSSSSSSSSSSSSDASDASDASDASASSSSS");
                                await FirebaseFirestore.instance
                                    .collection("reviews-declined")
                                    .doc(items[0][index].documentID)
                                    .set(items[0][index].toJson());
                                await FirebaseFirestore.instance
                                    .collection("reviews-pending")
                                    .doc(items[0][index].documentID)
                                    .delete();
                                // print("ASDASDASD" + items[0][index].eventID);
                                var event = await FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(items[0][index].eventID)
                                    .get();
                                Event tempEvent = Event.fromJson(event.data()!);
                                tempEvent.addID(event.id);
                                for (Participant p in tempEvent.participants!) {
                                  if (p.user!.email == items[0][index].userID) {
                                    p.status = "Declined";
                                    break;
                                  }
                                }
                                await FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(items[0][index].eventID)
                                    .set(tempEvent.toJson());
                                ref.refresh(eventsReviewsProvider);
                                ref.refresh(eventsProvider);
                              },
                            ),
                          ]),
                        ),
                      ));
                });
          },
        ),
        events.when(
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
      ];
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ProfileAppBar(
              title: "Event Timeline",
              providers: [eventsProvider, eventsReviewsProvider, userProvider]),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        //body: FutureBuilder(builder: buildEventList, future: getEvents()),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: (int index) {
            ref.read(indexProvider.state).state = index;
          },
        ),
      );
    }
  }
}
