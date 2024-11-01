// Flutter Widgets
import 'dart:ui';

import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
import '../../DB_Deserialization/category_points.dart';
import '../../DB_Deserialization/participants.dart';
import '../../DB_Deserialization/fill_review.dart';
import '../../DB_Deserialization/review.dart';
import '../../Resources/grid_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final indexProvider = StateProvider((ref) => 1);
final searchProvider = StateProvider<List<UserData>>((ref) => []);
final filterProvider =
    StateProvider((ref) => "Pending"); // 0: declined, 1: pending, 2: approved

class AdminTimeline extends ConsumerWidget {
  AdminTimeline({Key? key}) : super(key: key);
  TextEditingController searchController = TextEditingController(text: "");
  int _selectedIndex = 1;
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
  final reviewsPendingProvider = FutureProvider<List<Review>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Review> result = [];
    await db.collection("reviews-pending").get().then(
      (event) {
        Review temp;
        for (var doc in event.docs) {
          temp = Review.fromJson(
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
  final reviewsApprovedProvider = FutureProvider<List<Review>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Review> result = [];
    await db.collection("reviews-approved").get().then(
      (event) {
        Review temp;
        for (var doc in event.docs) {
          temp = Review.fromJson(
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
  final reviewsDeclinedProvider = FutureProvider<List<Review>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Review> result = [];
    await db.collection("reviews-declined").get().then(
      (event) {
        Review temp;
        for (var doc in event.docs) {
          temp = Review.fromJson(
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

  Future<FillReview> getUserData(String userID, String eventID) async {
    var userData =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();
    var eventData = await FirebaseFirestore.instance
        .collection("events")
        .doc(eventID)
        .get();
    return FillReview(
        user: UserData.fromJson(userData.data()!),
        event: Event.fromJson(eventData.data()!));
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Event>> events = ref.watch(eventsProvider);
    AsyncValue<List<Review>> reviewsPending = ref.watch(reviewsPendingProvider);
    AsyncValue<List<Review>> reviewsApproved =
        ref.watch(reviewsApprovedProvider);
    AsyncValue<List<Review>> reviewsDeclined =
        ref.watch(reviewsDeclinedProvider);
    AsyncValue<List<UserData>> users = ref.watch(userProvider);
    int _selectedIndex = ref.watch(indexProvider);
    String _filterIndex = ref.watch(filterProvider);
    final auth = ref.watch(authProvider);

    var userItems = <String>[
      'Change to officer', /*'Delete Account'*/
    ];
    var officerItems = <String>[
      'Change to user', /*'Delete Account'*/
    ];

    List<String> dropdownItems = ["Pending", "Approved", "Declined"];
    List<Widget> _widgetOptions = [
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 30, 10),
            child: DropdownButton<String>(
              value: _filterIndex,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: mainColor),
              underline: Container(
                height: 2,
                color: accentColor,
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                ref.read(filterProvider.state).state = value!;
                ref.refresh(reviewsPendingProvider);
                ref.refresh(reviewsApprovedProvider);
                ref.refresh(reviewsDeclinedProvider);
              },
              items:
                  dropdownItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          if (_filterIndex == "Pending") ...[
            reviewsPending.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => ErrorMessage('Error: $err'),
              data: (items) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: getUserData(
                              items[index].userID!, items[index].eventID!),
                          builder: ((context, snapshot) {
                            if (snapshot.data is FillReview) {
                              return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ListTile(
                                    title: Text((snapshot.data as FillReview)
                                        .getUser()
                                        .fullName!),
                                    subtitle: Text((snapshot.data as FillReview)
                                        .getEvent()
                                        .title!),
                                    trailing: SizedBox(
                                      width: 100,
                                      height: 20,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check),
                                              alignment: Alignment.center,
                                              color: Colors.green,
                                              splashRadius: 40,
                                              onPressed: () async {
                                                //print(items[index]);
                                                //print(items[index].runtimeType);
                                                //print(items[index].documentID);
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        "reviews-approved")
                                                    .doc(
                                                        items[index].documentID)
                                                    .set(items[index].toJson());
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        "reviews-pending")
                                                    .doc(
                                                        items[index].documentID)
                                                    .delete();
                                                var event =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("events")
                                                        .doc(items[index]
                                                            .eventID)
                                                        .get();
                                                Event tempEvent =
                                                    Event.fromJson(
                                                        event.data()!);
                                                tempEvent.addID(event.id);
                                                /*for (int i = 0;
                                                i <
                                                    tempEvent
                                                        .participants!.length;
                                                i++) {
                                              if (tempEvent.participants![i]
                                                      .user!.email ==
                                                  items[index].userID) {
                                                // print(tempEvent
                                                    .participants![i].status);
                                                // print("ASDASDASDASD");
                                              }
                                            }*/
                                                for (Participant p in tempEvent
                                                    .participants!) {
                                                  if (p.user!.email ==
                                                      items[index].userID) {
                                                    p.status = "Approved";
                                                    break;
                                                  }
                                                }
                                                /*for (int i = 0;
                                                i <
                                                    tempEvent
                                                        .participants!.length;
                                                i++) {
                                              if (tempEvent.participants![i]
                                                      .user!.email ==
                                                  items[index].userID) {
                                                // print(tempEvent
                                                    .participants![i].status);
                                                // print("ASDASDASDASD");
                                              }
                                            }*/

                                                /*for (Participant p
                                                in tempEvent.participants!) {
                                              if (p.user!.email ==
                                                  items[index].userID) {
                                                tempEvent.participants!
                                                    .remove(p);
                                              }
                                            }*/
                                                await FirebaseFirestore.instance
                                                    .collection("events")
                                                    .doc(items[index].eventID)
                                                    .set(tempEvent.toJson());
                                                var user =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(
                                                            items[index].userID)
                                                        .get();
                                                UserData tempUser =
                                                    UserData.fromJson(
                                                        user.data()!);
                                                switch (tempEvent.category) {
                                                  case "Social":
                                                    tempUser.categoryPoints!
                                                        .social = tempUser
                                                            .categoryPoints!
                                                            .social! +
                                                        tempEvent.points!;
                                                    break;
                                                  case "Competitive Prep":
                                                    tempUser.categoryPoints!
                                                        .competitivePrep = tempUser
                                                            .categoryPoints!
                                                            .competitivePrep! +
                                                        tempEvent.points!;
                                                    break;
                                                  case "Community Service / Fundraising":
                                                    tempUser.categoryPoints!
                                                            .communityServiceFundraising =
                                                        tempUser.categoryPoints!
                                                                .communityServiceFundraising! +
                                                            tempEvent.points!;
                                                    break;
                                                  case "Other":
                                                    tempUser.categoryPoints!
                                                        .other = tempUser
                                                            .categoryPoints!
                                                            .other! +
                                                        tempEvent.points!;
                                                    break;
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(items[index].userID)
                                                    .set(tempUser.toJson());
                                                ref.refresh(
                                                    reviewsPendingProvider);
                                                ref.refresh(eventsProvider);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              alignment: Alignment.center,
                                              color: Colors.red,
                                              splashRadius: 40,
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        "reviews-declined")
                                                    .doc(
                                                        items[index].documentID)
                                                    .set(items[index].toJson());
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        "reviews-pending")
                                                    .doc(
                                                        items[index].documentID)
                                                    .delete();
                                                var event =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("events")
                                                        .doc(items[index]
                                                            .eventID)
                                                        .get();
                                                Event tempEvent =
                                                    Event.fromJson(
                                                        event.data()!);
                                                tempEvent.addID(event.id);
                                                for (Participant p in tempEvent
                                                    .participants!) {
                                                  if (p.user!.email ==
                                                      items[index].userID) {
                                                    p.status = "Declined";
                                                    break;
                                                  }
                                                }
                                                await FirebaseFirestore.instance
                                                    .collection("events")
                                                    .doc(items[index].eventID)
                                                    .set(tempEvent.toJson());
                                                /*var event = await FirebaseFirestore
                                                .instance
                                                .collection("events")
                                                .doc(items[index].eventID)
                                                .get();
                                            Event tempEvent =
                                                Event.fromJson(event.data()!);
                                            for (Participant p
                                                in tempEvent.participants!) {
                                              if (p.user!.email ==
                                                  items[index].userID) {
                                                tempEvent.participants!
                                                    .remove(p);
                                              }
                                            }
                                            await FirebaseFirestore.instance
                                                .collection("events")
                                                .doc(items[index].eventID)
                                                .set(tempEvent.toJson());*/
                                                ref.refresh(
                                                    reviewsPendingProvider);
                                                ref.refresh(eventsProvider);
                                              },
                                            ),
                                          ]),
                                    ),
                                  ));
                            } else {
                              // print(
                              //    "Triggered admin_timeline.dart line 187 ish");
                              return Container();
                            }
                          }),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ] else if (_filterIndex == "Declined") ...[
            reviewsDeclined.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => ErrorMessage('Error: $err'),
              data: (items) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: getUserData(
                              items[index].userID!, items[index].eventID!),
                          builder: ((context, snapshot) {
                            if (snapshot.data is FillReview) {
                              return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ListTile(
                                    title: Text((snapshot.data as FillReview)
                                        .getUser()
                                        .fullName!),
                                    subtitle: Text((snapshot.data as FillReview)
                                        .getEvent()
                                        .title!),
                                    trailing: const SizedBox(
                                      width: 80,
                                      height: 20,
                                      // child: Row(children: [
                                      //   IconButton(
                                      //     icon: const Icon(Icons.check),
                                      //     alignment: Alignment.center,
                                      //     color: Colors.green,
                                      //     onPressed: () async {
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-pending")
                                      //           .doc(items[index].documentID)
                                      //           .delete();
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-approved")
                                      //           .doc(items[index].documentID)
                                      //           .set(items[index].toJson());
                                      //       var event = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .get();
                                      //       Event tempEvent =
                                      //           Event.fromJson(event.data()!);
                                      //       for (Participant p
                                      //           in tempEvent.participants!) {
                                      //         if (p.user!.email ==
                                      //             items[index].userID) {
                                      //           tempEvent.participants!
                                      //               .remove(p);
                                      //         }
                                      //       }
                                      //       FirebaseFirestore.instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .set(tempEvent.toJson());
                                      //       var user = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("users")
                                      //           .doc(items[index].userID)
                                      //           .get();
                                      //       UserData tempUser =
                                      //           UserData.fromJson(user.data()!);

                                      //       switch (tempEvent.category) {
                                      //         case "Business":
                                      //           tempUser.categoryPoints!
                                      //               .business = tempUser
                                      //                   .categoryPoints!
                                      //                   .business! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Social":
                                      //           tempUser.categoryPoints!
                                      //               .social = tempUser
                                      //                   .categoryPoints!
                                      //                   .social! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Competitive Prep":
                                      //           tempUser.categoryPoints!
                                      //               .competitivePrep = tempUser
                                      //                   .categoryPoints!
                                      //                   .competitivePrep! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Community Service":
                                      //           tempUser.categoryPoints!
                                      //               .communityService = tempUser
                                      //                   .categoryPoints!
                                      //                   .communityService! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Meeting":
                                      //           tempUser.categoryPoints!
                                      //               .meetings = tempUser
                                      //                   .categoryPoints!
                                      //                   .meetings! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Fundraising":
                                      //           tempUser.categoryPoints!
                                      //               .fundraising = tempUser
                                      //                   .categoryPoints!
                                      //                   .fundraising! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //       }

                                      //       FirebaseFirestore.instance
                                      //           .collection("users")
                                      //           .doc(items[index].userID)
                                      //           .set(tempUser.toJson());
                                      //       ref.refresh(reviewsPendingProvider);
                                      //     },
                                      //   ),
                                      //   IconButton(
                                      //     icon: const Icon(Icons.close),
                                      //     alignment: Alignment.center,
                                      //     color: Colors.red,
                                      //     splashRadius: 20,
                                      //     onPressed: () async {
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-pending")
                                      //           .doc(items[index].documentID)
                                      //           .delete();
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-declined")
                                      //           .doc(items[index].documentID)
                                      //           .set(items[index].toJson());
                                      //       var event = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .get();
                                      //       Event tempEvent =
                                      //           Event.fromJson(event.data()!);
                                      //       for (Participant p
                                      //           in tempEvent.participants!) {
                                      //         if (p.user!.email ==
                                      //             items[index].userID) {
                                      //           tempEvent.participants!
                                      //               .remove(p);
                                      //         }
                                      //       }
                                      //       FirebaseFirestore.instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .set(tempEvent.toJson());
                                      //       ref.refresh(reviewsPendingProvider);
                                      //     },
                                      //   ),
                                      // ]),
                                    ),
                                  ));
                            } else {
                              return Container();
                            }
                          }),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            reviewsApproved.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => ErrorMessage('Error: $err'),
              data: (items) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: getUserData(
                              items[index].userID!, items[index].eventID!),
                          builder: ((context, snapshot) {
                            if (snapshot.data is FillReview) {
                              return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ListTile(
                                    title: Text((snapshot.data as FillReview)
                                        .getUser()
                                        .fullName!),
                                    subtitle: Text((snapshot.data as FillReview)
                                        .getEvent()
                                        .title!),
                                    trailing: const SizedBox(
                                      width: 80,
                                      height: 20,
                                      // child: Row(children: [
                                      //   IconButton(
                                      //     icon: const Icon(Icons.check),
                                      //     alignment: Alignment.center,
                                      //     color: Colors.green,
                                      //     onPressed: () async {
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-pending")
                                      //           .doc(items[index].documentID)
                                      //           .delete();
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-approved")
                                      //           .doc(items[index].documentID)
                                      //           .set(items[index].toJson());
                                      //       var event = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .get();
                                      //       Event tempEvent =
                                      //           Event.fromJson(event.data()!);
                                      //       for (Participant p
                                      //           in tempEvent.participants!) {
                                      //         if (p.user!.email ==
                                      //             items[index].userID) {
                                      //           tempEvent.participants!
                                      //               .remove(p);
                                      //         }
                                      //       }
                                      //       FirebaseFirestore.instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .set(tempEvent.toJson());
                                      //       var user = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("users")
                                      //           .doc(items[index].userID)
                                      //           .get();
                                      //       UserData tempUser =
                                      //           UserData.fromJson(user.data()!);

                                      //       switch (tempEvent.category) {
                                      //         case "Business":
                                      //           tempUser.categoryPoints!
                                      //               .business = tempUser
                                      //                   .categoryPoints!
                                      //                   .business! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Social":
                                      //           tempUser.categoryPoints!
                                      //               .social = tempUser
                                      //                   .categoryPoints!
                                      //                   .social! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Competitive Prep":
                                      //           tempUser.categoryPoints!
                                      //               .competitivePrep = tempUser
                                      //                   .categoryPoints!
                                      //                   .competitivePrep! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Community Service":
                                      //           tempUser.categoryPoints!
                                      //               .communityService = tempUser
                                      //                   .categoryPoints!
                                      //                   .communityService! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Meeting":
                                      //           tempUser.categoryPoints!
                                      //               .meetings = tempUser
                                      //                   .categoryPoints!
                                      //                   .meetings! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //         case "Fundraising":
                                      //           tempUser.categoryPoints!
                                      //               .fundraising = tempUser
                                      //                   .categoryPoints!
                                      //                   .fundraising! +
                                      //               tempEvent.points!;
                                      //           break;
                                      //       }

                                      //       FirebaseFirestore.instance
                                      //           .collection("users")
                                      //           .doc(items[index].userID)
                                      //           .set(tempUser.toJson());
                                      //       ref.refresh(reviewsPendingProvider);
                                      //     },
                                      //   ),
                                      //   IconButton(
                                      //     icon: const Icon(Icons.close),
                                      //     alignment: Alignment.center,
                                      //     color: Colors.red,
                                      //     splashRadius: 20,
                                      //     onPressed: () async {
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-pending")
                                      //           .doc(items[index].documentID)
                                      //           .delete();
                                      //       FirebaseFirestore.instance
                                      //           .collection("reviews-declined")
                                      //           .doc(items[index].documentID)
                                      //           .set(items[index].toJson());
                                      //       var event = await FirebaseFirestore
                                      //           .instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .get();
                                      //       Event tempEvent =
                                      //           Event.fromJson(event.data()!);
                                      //       for (Participant p
                                      //           in tempEvent.participants!) {
                                      //         if (p.user!.email ==
                                      //             items[index].userID) {
                                      //           tempEvent.participants!
                                      //               .remove(p);
                                      //         }
                                      //       }
                                      //       FirebaseFirestore.instance
                                      //           .collection("events")
                                      //           .doc(items[index].eventID)
                                      //           .set(tempEvent.toJson());
                                      //       ref.refresh(reviewsPendingProvider);
                                      //     },
                                      //   ),
                                      // ]),
                                    ),
                                  ));
                            } else {
                              return Container();
                            }
                          }),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      events.when(
          loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
          error: (err, stack) => ErrorMessage('Error: $err'),
          data: (items) {
            // print(MediaQuery.of(context).size.width);
            List<GridItemAdmin> widgetList = [];
            for (Event i in items) {
              print(i);
              print("hihi ${i.participants!} HIII");
              final numAttendees = i.participants!.length;
              print(i.maximumAttendees);
              // could add a sort by date here
              widgetList.add(
                GridItemAdmin(
                  title: i.title!,
                  place: i.place!,
                  points: i.points!,
                  event: i,
                  docID: i.documentId!,
                  eventProviderDeletion: eventsProvider,
                  maximumAttendees: i.maximumAttendees!,
                  attendees: numAttendees,
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
            } else {
              return const ErrorMessageWithRouteUncloseable(
                  "Unable to identify platform", "/signin", "Sign In");
            }
          }),
      users.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => ErrorMessage('Error: $err'),
        data: (items) {
          ref.read(searchProvider.state).state.clear();
          items.forEach((element) {
            ref.read(searchProvider.state).state.add(element);
          });
          var heroCount = 0;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ref.watch(searchProvider).length,
            itemBuilder: (context, index) {
              var renderList = ref.watch(searchProvider);
              if (renderList[index].role! == "officer" ||
                  renderList[index].role! == "user") {
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(renderList[index].fullName!),
                            renderList[index].role! == "officer"
                                ? SizedBox(
                                    height: 30.0,
                                    width: 70.0,
                                    child: FittedBox(
                                      child: FloatingActionButton(
                                        heroTag: "officerTag $heroCount",
                                        child: const Icon(
                                            Icons.manage_accounts_outlined),
                                        //elevation: 50,
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          return;
                                        },
                                      ),
                                    ),
                                  )
                                : Container(),
                            renderList[index].categoryPoints!.communityServiceFundraising! +
                                        renderList[index]
                                            .categoryPoints!
                                            .social! +
                                        renderList[index]
                                            .categoryPoints!
                                            .competitivePrep! +
                                        renderList[index]
                                            .categoryPoints!
                                            .other! >=
                                    40
                                ? SizedBox(
                                    height: 30.0,
                                    width: 70.0,
                                    child: FittedBox(
                                      child: FloatingActionButton(
                                        heroTag: "FinishedTag $heroCount",
                                        child: const Icon(Icons.check),
                                        //elevation: 50,
                                        backgroundColor: Colors.green,
                                        onPressed: () {
                                          return;
                                        },
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        PopupMenuButton<String>(onSelected: (newRole) async {
                          // roleIndex is the toggle option, 0 is user and 1 is officer
                          //
                          FirebaseFirestore db = FirebaseFirestore.instance;
                          int total =
                              renderList[index].categoryPoints!.social! +
                                  renderList[index]
                                      .categoryPoints!
                                      .competitivePrep! +
                                  renderList[index]
                                      .categoryPoints!
                                      .communityServiceFundraising! +
                                  renderList[index].categoryPoints!.other!;

                          int displayTotal = total;
                          if (total > 40) {
                            displayTotal = 40;
                          }
                          Map<String, String> pointsTable = {
                            "Social":
                                "${renderList[index].categoryPoints!.social}/8",
                            "Competitive Preparation":
                                "${renderList[index].categoryPoints!.competitivePrep}/10",
                            "Community Service":
                                "${renderList[index].categoryPoints!.communityServiceFundraising}/8",
                            "Other":
                                "${renderList[index].categoryPoints!.other}",
                          };
                          switch (newRole) {
                            case "Change to user":
                              renderList[index].setRole("user");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "${renderList[index].fullName} was made a user"),
                                ),
                              );
                              ref.refresh(userProvider);
                              break;
                            case "Change to officer":
                              renderList[index].setRole("officer");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "${renderList[index].fullName} was made an officer"),
                                ),
                              );
                              ref.refresh(userProvider);
                              break;
                            case "View profile":
                              showDialog(
                                  context: context,
                                  builder: (context) => GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 1, sigmaY: 1),
                                            child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              child: GestureDetector(
                                                onTap: () => {},
                                                child: AlertDialog(
                                                    buttonPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 20,
                                                            right: 40),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    25))),
                                                    title: Text(
                                                        renderList[index]
                                                            .fullName!),
                                                    content: Column(
                                                      children: [
                                                        CircularPercentIndicator(
                                                          radius: 60.0,
                                                          lineWidth: 5.0,
                                                          percent:
                                                              displayTotal / 40,
                                                          center: Text(
                                                              "$total/40 points"),
                                                          progressColor:
                                                              Colors.blue,
                                                        ),
                                                        DataTable(
                                                          columns: const <
                                                              DataColumn>[
                                                            DataColumn(
                                                                label: Text(
                                                                    'Category')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Points Earned')),
                                                          ],
                                                          rows: pointsTable
                                                              .entries
                                                              .map((e) =>
                                                                  DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text(e.key)),
                                                                        DataCell(
                                                                            Text(e.value)),
                                                                      ]))
                                                              .toList(),
                                                        ),
                                                      ],
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        style: buttonStyle,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context); // use navigator.pop here as it doesnt work with gorouter
                                                        },
                                                        child:
                                                            const Text('Close'),
                                                      ),
                                                    ]),
                                              ),
                                            )),
                                      ));
                              break;
                            /*case "Delete Account":
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmDeletion(
                              name: renderList[index].fullName!,
                              email: renderList[index].email!,
                              route: "/timeline",
                              userProvider: userProvider),
                        );
                        break;*/
                            default:
                              break;
                          }
                          db
                              .collection("users")
                              .doc(renderList[index].email)
                              .set(renderList[index].toJson());
                        }, itemBuilder: (BuildContext context) {
                          if (renderList[index].role == "officer") {
                            var temp = officerItems.map((String choice) {
                              heroCount += 1;
                              // print(heroCount);
                              return PopupMenuItem<String>(
                                child: Text(choice),
                                value: choice,
                              );
                            }).toList();
                            temp.add(const PopupMenuItem<String>(
                              child: Text("View profile"),
                              value: "View profile",
                            ));
                            return temp;
                          } else {
                            var temp = userItems.map((String choice) {
                              return PopupMenuItem<String>(
                                child: Text(choice),
                                value: choice,
                              );
                            }).toList();
                            temp.add(const PopupMenuItem<String>(
                              child: Text("View profile"),
                              value: "View profile",
                            ));
                            return temp;
                          }
                        }),
                      ],
                    ));
              } else {
                return Row();
              }
            },
          );
        },
      ),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "AddEventBtn",
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => GestureDetector(
              onTap: () {},
              child: AddEventPopup(
                eventProviderDeletion: eventsProvider,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF103283),
        foregroundColor: Colors.white,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SettingsAppBar(title: "Event Timeline", providers: [
          eventsProvider,
          reviewsPendingProvider,
          reviewsApprovedProvider,
          reviewsDeclinedProvider,
          userProvider
        ]),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
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
