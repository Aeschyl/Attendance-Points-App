import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/participants.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/review.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../DB_Deserialization/event.dart';
import '../DB_Deserialization/user.dart';
import '../main.dart';
import 'alerts.dart';

class GridItemAdmin extends ConsumerWidget {
  const GridItemAdmin({
    Key? key,
    required this.title,
    required this.place,
    required this.points,
    required this.event,
    required this.docID,
    required this.eventProviderDeletion,
    required this.maximumAttendees,
    required this.attendees,
  }) : super(key: key);

  final String title;
  final String place;
  final int points;
  final Event event;
  final String docID;
  final FutureProvider eventProviderDeletion;
  final int maximumAttendees;
  final int attendees;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(maximumAttendees);
    print(attendees);
    return GestureDetector(
      onTap: () {
        ref.read(eventProvider.state).state = event;
        switch (ref.read(authProvider.state).state.role) {
          case "admin":
            context.pushNamed(
              "event",
              params: {"eventName": docID},
            );
            break;
          case "user":
            context.pushNamed(
              "event",
              params: {"eventName": docID},
            );
            break;
          case "officer":
            context.pushNamed(
              "event",
              params: {"eventName": docID},
            );
            break;
          default:
            /*ref.read(authProvider.state).state = UserData();
          FirebaseAuth.instance.signOut();*/
            showDialog(
              context: context,
              builder: (context) => const ErrorMessageWithRouteUncloseable(
                  "Could not get your authentication state",
                  "/signin",
                  "Sign in"),
            );
        }
      },
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(
                20), // this is used to achieve the unique borders
          ),
          shape: NeumorphicShape.convex,
          intensity: 100, // idk how that works
          depth: 50,
          /*border: const NeumorphicBorder(
          color: Colors.black,
        ),*/
        ),
        child: SizedBox(
          width: 300,
          height: 400,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              color: mainColor, height: 20, width: 20)),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                              color: accentColor, height: 20, width: 20)),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              color: secondaryColor, height: 20, width: 20)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: const BoxDecoration(
                      color: mainColor, shape: BoxShape.circle),
                  child: const Icon(
                    Icons.event,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned.fill(
                top: 75,
                left: 10,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 25,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 140,
                left: 10,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        "@$place",
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 17,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 290,
                left: 10,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        event.category!,
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 17,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 35,
                left: 30,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        event.prettyDate(),
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 17,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 190,
                left: 10,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        "${points.toString()} points",
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 17,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 240,
                left: 10,
                child: Flex(
                  // to ensure proper wrapping
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Text(
                        "${attendees.toString()}/${maximumAttendees.toString()} attendees",
                        softWrap: true,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 56, 111),
                          fontSize: 17,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 35,
                child: ElevatedButton(
                  onPressed: () async => await launchUrlString(
                      "https://outputreport.abhiramkasu.repl.co/get-specific-report/387345980243845/$docID/false"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mainColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.download),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 125,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (b) {
                          return EditEventPopup(
                              currEvent: event,
                              provider: eventProviderDeletion);
                        });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mainColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.edit),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 215,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("events")
                        .doc(event.documentId)
                        .delete();
                    var events = await FirebaseFirestore.instance
                        .collection("reviews-pending")
                        .where("eventID", isEqualTo: event.documentId)
                        .get();
                    events.docs
                        .forEach((element) => element.reference.delete());
                    events = await FirebaseFirestore.instance
                        .collection("reviews-approved")
                        .where("eventID", isEqualTo: event.documentId)
                        .get();
                    events.docs
                        .forEach((element) => element.reference.delete());
                    events = await FirebaseFirestore.instance
                        .collection("reviews-declined")
                        .where("eventID", isEqualTo: event.documentId)
                        .get();
                    events.docs
                        .forEach((element) => element.reference.delete());
                    ref.refresh(eventProviderDeletion);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mainColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.delete),
                ),
              ),
              /* Positioned(
                bottom: 20,
                left: 20,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(eventProvider.state).state = event;
                    switch (ref.read(authProvider.state).state.role) {
                      case "admin":
                        context.pushNamed(
                          "event",
                          params: {"eventName": docID},
                        );
                        break;
                      case "user":
                        context.pushNamed(
                          "event",
                          params: {"eventName": docID},
                        );
                        break;
                      case "officer":
                        context.pushNamed(
                          "event",
                          params: {"eventName": docID},
                        );
                        break;
                      default:
                        /*ref.read(authProvider.state).state = UserData();
          FirebaseAuth.instance.signOut();*/
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const ErrorMessageWithRouteUncloseable(
                                  "Could not get your authentication state",
                                  "/signin",
                                  "Sign in"),
                        );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mainColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.info),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class GridItemUser extends ConsumerWidget {
  const GridItemUser({
    Key? key,
    required this.title,
    required this.place,
    required this.points,
    required this.event,
    required this.docID,
  }) : super(key: key);

  final String title;
  final String place;
  final int points;
  final Event event;
  final String docID;

  Future<List> buttonText(WidgetRef ref) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var raw = await db
        .collection("reviews-pending")
        .get(); // might be better to do cloud function
    // could have boolean that if this was triggered before then it wont work anymore in that session
    for (var i in raw.docs) {
      Review existCheck = Review.fromJson(i.data());
      if (existCheck.eventID == event.documentId &&
          existCheck.userID == ref.read(authProvider.state).state.email) {
        return ["Pending", Color.fromARGB(255, 219, 198, 2)];
      }
    }
    raw = await db
        .collection("reviews-approved")
        .get(); // might be better to do cloud function
    // could have boolean that if this was triggered before then it wont work anymore in that session
    for (var i in raw.docs) {
      Review existCheck = Review.fromJson(i.data());
      if (existCheck.eventID == event.documentId &&
          existCheck.userID == ref.read(authProvider.state).state.email) {
        return ["Approved", Colors.green];
      }
    }
    raw = await db
        .collection("reviews-declined")
        .get(); // might be better to do cloud function
    // could have boolean that if this was triggered before then it wont work anymore in that session
    for (var i in raw.docs) {
      Review existCheck = Review.fromJson(i.data());
      if (existCheck.eventID == event.documentId &&
          existCheck.userID == ref.read(authProvider.state).state.email) {
        return ["Declined", mainColor];
      }
    }
    return ["I Attended", accentColor];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusButtonText;
    var statusButtonColor;
    /*return Scaffold(
        body: */
    return FutureBuilder<List>(
        future: buttonText(ref),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            statusButtonText = snapshot.data![0];
            statusButtonColor = snapshot.data![1];
            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  ref.read(eventProvider.state).state = event;
                  switch (ref.read(authProvider.state).state.role) {
                    case "admin":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    case "user":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    case "officer":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    default:
                      /*ref.read(authProvider.state).state = UserData();
          FirebaseAuth.instance.signOut();*/
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const ErrorMessageWithRouteUncloseable(
                                "Could not get your authentication state",
                                "/signin",
                                "Sign in"),
                      );
                  }
                },
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(
                          20), // this is used to achieve the unique borders
                    ),
                    shape: NeumorphicShape.convex,
                    intensity: 100, // idk how that works
                    depth: 50,
                    /*border: const NeumorphicBorder(
          color: Colors.black,
        ),*/
                  ),
                  child: SizedBox(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          color: mainColor,
                                          height: 20,
                                          width: 20)),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                          color: accentColor,
                                          height: 20,
                                          width: 20)),
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                          color: secondaryColor,
                                          height: 20,
                                          width: 20)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: const BoxDecoration(
                                  color: mainColor, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.event,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 100,
                            left: 10,
                            child: Flex(
                              // to ensure proper wrapping
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 31, 56, 111),
                                      fontSize: 25,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            top: 175,
                            left: 10,
                            child: Flex(
                              // to ensure proper wrapping
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Text(
                                    "@$place",
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 31, 56, 111),
                                      fontSize: 17,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            top: 240,
                            left: 10,
                            child: Flex(
                              // to ensure proper wrapping
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${points.toString()} points",
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 31, 56, 111),
                                      fontSize: 17,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            top: 300,
                            left: 10,
                            child: Flex(
                              // to ensure proper wrapping
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.category!,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 31, 56, 111),
                                      fontSize: 17,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            top: 35,
                            left: 30,
                            child: Flex(
                              // to ensure proper wrapping
                              direction: Axis.vertical,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.prettyDate(),
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 31, 56, 111),
                                      fontSize: 17,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                FirebaseFirestore db =
                                    FirebaseFirestore.instance;
                                /*var raw = await db
                                    .collection("reviews-pending")
                                    .get(); // might be better to do cloud function
                                // could have boolean that if this was triggered before then it wont work anymore in that session
                                for (var i in raw.docs) {
                                  Review existCheck = Review.fromJson(i.data());
                                  if (existCheck.eventID == event.documentId &&
                                      existCheck.userID ==
                                          ref
                                              .read(authProvider.state)
                                              .state
                                              .email) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ErrorMessage(
                                          "Your request is pending approval"),
                                    );
                                    setState(
                                      () {
                                        statusButtonText = "Pending";
                                      },
                                    );
                                    return;
                                  }
                                }
                                raw = await db
                                    .collection("reviews-approved")
                                    .get(); // might be better to do cloud function
                                // could have boolean that if this was triggered before then it wont work anymore in that session
                                for (var i in raw.docs) {
                                  Review existCheck = Review.fromJson(i.data());
                                  if (existCheck.eventID == event.documentId &&
                                      existCheck.userID ==
                                          ref
                                              .read(authProvider.state)
                                              .state
                                              .email) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ErrorMessage(
                                          "You were approved for this"),
                                    );
                                    setState(
                                      () {
                                        statusButtonText = "Approved";
                                      },
                                    );
                                    return;
                                  }
                                }
                                raw = await db
                                    .collection("reviews-declined")
                                    .get(); // might be better to do cloud function
                                // could have boolean that if this was triggered before then it wont work anymore in that session
                                for (var i in raw.docs) {
                                  Review existCheck = Review.fromJson(i.data());
                                  if (existCheck.eventID == event.documentId &&
                                      existCheck.userID ==
                                          ref
                                              .read(authProvider.state)
                                              .state
                                              .email) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ErrorMessage(
                                          "You were declined for this"),
                                    );
                                    setState(
                                      () {
                                        statusButtonText = "Declined";
                                      },
                                    );
                                    return;
                                  }
                                }*/
                                if (statusButtonText == "I Attended") {
                                  event.participants!.add(
                                    Participant(
                                      status: "Pending",
                                      user: ref.read(authProvider.state).state,
                                    ),
                                  );
                                  await db
                                      .collection("events")
                                      .doc(docID)
                                      .set(event.toJson());
                                  db.collection("reviews-pending").add(Review(
                                          userID: ref
                                              .read(authProvider.state)
                                              .state
                                              .email,
                                          eventID: event.documentId,
                                          fullName: ref
                                              .read(authProvider.state)
                                              .state
                                              .fullName)
                                      .toJson());
                                  setState(() {
                                    statusButtonText = "Pending";
                                    statusButtonColor =
                                        Color.fromARGB(255, 219, 198, 2);
                                  });
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    statusButtonColor),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(8)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              child: Text(statusButtonText),
                            ),
                          ),
                          /*Positioned(
              bottom: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(eventProvider.state).state = event;
                  switch (ref.read(authProvider.state).state.role) {
                    case "admin":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    case "user":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    case "officer":
                      context.pushNamed(
                        "event",
                        params: {"eventName": docID},
                      );
                      break;
                    default:
                      /*ref.read(authProvider.state).state = UserData();
          FirebaseAuth.instance.signOut();*/
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const ErrorMessageWithRouteUncloseable(
                                "Could not get your authentication state",
                                "/signin",
                                "Sign in"),
                      );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mainColor),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(8)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                child: const Icon(Icons.info),
              ),*/
                        ],
                      )),
                ),
              );
            });
          } else {
            return Container();
          }
        });
  }
}
