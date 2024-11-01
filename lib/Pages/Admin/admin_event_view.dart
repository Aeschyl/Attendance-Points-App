// Flutter Widgets
import 'dart:ui';

import 'package:fuzzywuzzy/fuzzywuzzy.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/participants.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// API Request stuff
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../DBInteraction/firebase_operations.dart';
import '../../DB_Deserialization/event.dart';
import '../../DB_Deserialization/user.dart';
import '../../Resources/alerts.dart';
import '../../main.dart';

class AssignedUser {
  UserData user;
  bool approved;
  AssignedUser({required this.user, required this.approved});
}

class _AdminEventViewState extends ConsumerState<AdminEventView> {
  var oddEven = 0;
  late final eventProvider = FutureProvider<Event>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var query = await db.collection("events").doc(widget.docID).get();
    Event result = Event.fromJson((query).data()!);
    result.addID(query.id);
    return result;
  });

  final userProvider = FutureProvider<List<UserData>>((ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var userData = await db.collection("users").get();

    return userData.docs.map((e) => UserData.fromJson(e.data())).toList();
  });
  List<Participant>? participants = [];
  @override
  Widget build(BuildContext context) {
    AsyncValue<Event> event = ref.watch(eventProvider);
    AsyncValue<List<UserData>> users = ref.watch(userProvider);
    Event currEvent;
    final auth = ref.watch(authProvider);

    Widget eventLoaded = event.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => ErrorMessage('Error: $err'),
      data: (item) {
        currEvent = item;
        setState(() {
          participants = currEvent.participants;
        });

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: Center(
                child: Text(
                  "${item.title}",
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              subtitle: Center(
                child: Text(
                  item.prettyDate(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "${item.place}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: buttonStyle,
                  child: const Text('Assign Officers'),
                  onPressed: () async {
                    var query = await FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'officer')
                        .get();

                    final Set<UserData> officers = query.docs
                        .map((e) => UserData.fromJson(e.data()))
                        .toSet();

                    showDialog(
                        context: context,
                        builder: (context) {
                          var assignedOfficers =
                              currEvent.assignedOfficers!.toSet();
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: AlertDialog(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
                                      title: Center(
                                        child: SafeArea(
                                          minimum: const EdgeInsets.all(20),
                                          child: SizedBox(
                                            width: 350,
                                            height: 385,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  itemCount: officers.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Material(
                                                      child: ListTile(
                                                          tileColor: assignedOfficers
                                                                  .contains(officers
                                                                      .elementAt(
                                                                          index)
                                                                      .email)
                                                              ? Colors.green
                                                                  .withOpacity(
                                                                      .6)
                                                              : Colors.white,
                                                          title: Text(officers
                                                              .elementAt(index)
                                                              .fullName!),
                                                          onTap: () {
                                                            var newEvent =
                                                                currEvent;

                                                            var set = newEvent
                                                                .assignedOfficers!
                                                                .toSet();

                                                            if (!set.add(
                                                                officers
                                                                    .elementAt(
                                                                        index)
                                                                    .email!)) {
                                                              // print(
                                                              //    'Removed Assgined');
                                                              set.remove(officers
                                                                  .elementAt(
                                                                      index)
                                                                  .email!);
                                                            }
                                                            newEvent.assignedOfficers =
                                                                set.toList();
                                                            setState(() {
                                                              // print(
                                                              //    "Set State");
                                                              assignedOfficers =
                                                                  set;
                                                            });

                                                            // print(
                                                            //    'Document Id = ');

                                                            // print(item
                                                            //    .documentId);

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'events')
                                                                .doc(item
                                                                    .documentId)
                                                                .set(newEvent
                                                                    .toJson());
                                                          }),
                                                    );
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Done"),
                                                  style: buttonStyle,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  },
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  child: const Text("Add/Remove Members"),
                  onPressed: () async {
                    var query = await FirebaseFirestore.instance
                        .collection('users')
                        .get();

                    final Set<UserData> users = query.docs
                        .map((e) => UserData.fromJson(e.data()))
                        .toSet();
                    final alreadyAssignedUsers = currEvent.participants
                        ?.where((element) =>
                            users.any((e) => e.email == element.user!.email))
                        .toSet();

                    var finalCompleteUsers = users
                        .map((e) => AssignedUser(
                            user: e,
                            approved: alreadyAssignedUsers!
                                .any((l) => l.user!.email == e.email)))
                        .toSet()
                        .toList();
                    bool isBusy = false;
                    var searchResults = finalCompleteUsers;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        title: Center(
                                          child: SafeArea(
                                            minimum: const EdgeInsets.all(20),
                                            child: SizedBox(
                                              width: 350,
                                              height: 385,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                  hintText:
                                                                      'Search through members',
                                                                  prefixIcon:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            0), // add padding to adjust icon
                                                                    child: Icon(
                                                                        Icons
                                                                            .search),
                                                                  )),
                                                          autofillHints:
                                                              finalCompleteUsers
                                                                  .map((e) => e
                                                                      .user
                                                                      .fullName!)
                                                                  .toList(),
                                                          onChanged: (e) {
                                                            if (isBusy) return;
                                                            isBusy = true;
                                                            if (e.isEmpty) {
                                                              setState(() {
                                                                searchResults =
                                                                    finalCompleteUsers;
                                                              });
                                                            }

                                                            setState(() {
                                                              searchResults = finalCompleteUsers
                                                                  .where((element) =>
                                                                      ratio(element.user.fullName!.toLowerCase(), e.toLowerCase()) >
                                                                          60 ||
                                                                      element
                                                                          .user
                                                                          .fullName!
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              e.toLowerCase()))
                                                                  .toSet()
                                                                  .toList();
                                                            });

                                                            isBusy = false;
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              searchResults
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Material(
                                                                child: ListTile(
                                                              tileColor: searchResults[
                                                                          index]
                                                                      .approved
                                                                  ? Colors.green
                                                                      .withOpacity(
                                                                          .6)
                                                                  : Colors
                                                                      .white,
                                                              title: Text(
                                                                  searchResults[
                                                                          index]
                                                                      .user
                                                                      .fullName!),
                                                              onTap: () async {
                                                                if (searchResults[
                                                                        index]
                                                                    .approved) {
                                                                  setState(() {
                                                                    searchResults[
                                                                            index]
                                                                        .approved = false;
                                                                  });
                                                                  currEvent.participants?.removeWhere((element) =>
                                                                      element
                                                                          .user!
                                                                          .email ==
                                                                      searchResults[
                                                                              index]
                                                                          .user
                                                                          .email);
                                                                } else {
                                                                  currEvent
                                                                      .participants
                                                                      ?.add(Participant(
                                                                          status:
                                                                              "Approved",
                                                                          user:
                                                                              searchResults[index].user));
                                                                  setState(() {
                                                                    searchResults[
                                                                            index]
                                                                        .approved = true;
                                                                  });
                                                                }
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'events')
                                                                    .doc(currEvent
                                                                        .documentId)
                                                                    .set(currEvent
                                                                        .toJson());
                                                                this.setState(
                                                                    () {
                                                                  participants =
                                                                      currEvent
                                                                          .participants;
                                                                  oddEven = 0;
                                                                });
                                                              },
                                                            ));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Done"),
                                                    style: buttonStyle,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  },
                  style: buttonStyle),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white54),
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.builder(
                    itemCount: participants?.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: oddEven++ % 2 == 0
                            ? const Color.fromARGB(179, 155, 150, 150)
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Center(
                            child: Text(participants![index].user!.fullName!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SettingsAppBar(
            title: "Event Timeline", providers: [eventProvider, userProvider]),
      ),
      body: Center(
        child: eventLoaded,
      ),
      //body: FutureBuilder(builder: buildEventList, future: getEvents()),
    );
  }
}

class AdminEventView extends ConsumerStatefulWidget {
  AdminEventView({required this.docID, Key? key}) : super(key: key);
  final String docID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminEventViewState();
}
