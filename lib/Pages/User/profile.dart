// Flutter widgets
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

// API Request Stuff
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../signin.dart';

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
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

class Profile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);
    String? newFirstName;
    String? newLastName;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ProfileAndBackButtonEnabledAppBar(
            title: "Profile",
            providers: [userProvider],
          ),
        ),
        body: preferences.when(data: (prefs) {
          if (auth.role != null) {
            // print('Profile: auth role not null,');
            if (auth.role == 'user' || auth.role == 'officer') {
              int total = auth.categoryPoints!.social! +
                  auth.categoryPoints!.competitivePrep! +
                  auth.categoryPoints!.communityServiceFundraising! +
                  auth.categoryPoints!.other!;
              int displayTotal = total;
              if (total > 40) {
                displayTotal = 40;
              }
              Map<String, String> pointsTable = {
                "Social": "${auth.categoryPoints!.social}/8",
                "Competitive Preparation":
                    "${auth.categoryPoints!.competitivePrep}/10",
                "Community Service":
                    "${auth.categoryPoints!.communityServiceFundraising}/8",
                "Other": "${auth.categoryPoints!.other}",
              };
              return Column(
                children: [
                  Center(
                      child: Text(
                    auth.fullName!,
                    textScaleFactor: 3,
                  )),
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 5.0,
                    percent: displayTotal / 40,
                    center: Text("$total/40 points"),
                    progressColor: Colors.blue,
                  ),
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Points Earned')),
                    ],
                    rows: pointsTable.entries
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.key)),
                              DataCell(Text(e.value)),
                            ]))
                        .toList(),
                  ),
                  Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(accentColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                              child: const Text("Edit Profile"),
                              onPressed: () async {
                                var query = await FirebaseFirestore.instance
                                    .collection("users")
                                    .where("email", isEqualTo: auth.email)
                                    .get();
                                var currUser =
                                    UserData.fromJson(query.docs.first.data());
                                newFirstName = currUser.firstName;
                                newLastName = currUser.lastName;
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 1, sigmaY: 1),
                                              child: Container(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  child: GestureDetector(
                                                      onTap: () => {},
                                                      child: AlertDialog(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          25))),
                                                          title: Center(
                                                            child: SafeArea(
                                                                minimum:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        20),
                                                                child: SizedBox(
                                                                    width: 300,
                                                                    height: 300,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: TextFormField(
                                                                                initialValue: currUser.firstName,
                                                                                onChanged: (text) => newFirstName = text,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: TextFormField(
                                                                                initialValue: currUser.lastName,
                                                                                onChanged: (text) => newLastName = text,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color(0xFFFF1100)), foregroundColor: MaterialStateProperty.all(Colors.white)), child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: ElevatedButton(
                                                                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(accentColor), foregroundColor: MaterialStateProperty.all(Colors.white)),
                                                                                    child: const Text("Update"),
                                                                                    onPressed: () async {
                                                                                      if (newFirstName!.trim() != '' || newLastName!.trim() != '') {
                                                                                        currUser.firstName = newFirstName?.trim();
                                                                                        currUser.lastName = newLastName?.trim();
                                                                                        currUser.fullName = "$newFirstName $newLastName";
                                                                                        await FirebaseFirestore.instance.collection("users").doc(query.docs.first.id).set(currUser.toJson());
                                                                                      }
                                                                                      Navigator.pop(context);
                                                                                    }),
                                                                              ),
                                                                            ])
                                                                      ],
                                                                    ))),
                                                          ))))));
                                    });
                              },
                            ),
                          ),*/
                          /*Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFFF81202)),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                                onPressed: () async {
                                  var query = await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('email', isEqualTo: auth.email)
                                      .get();
                                  var currUser = UserData.fromJson(
                                      query.docs.first.data());
                                  showDialog(
                                      context: context,
                                      builder: (builder) => ConfirmDeletion(
                                            email: currUser.email!,
                                            name: currUser.fullName!,
                                            route: '/profile',
                                            userProvider: userProvider,
                                          ));
                                },
                                child: const Text('Delete Account')),
                          ),*/
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(8)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await prefs.remove('email');
                                await prefs.remove('password');
                                ref.read(authProvider.state).state = UserData();
                                await FirebaseAuth.instance.signOut();
                                context.go('/signin');
                              },
                              child: const Text(
                                "Log out",
                              ),
                            ),
                          ),
                        ]),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              );
            } else if (auth.role == 'admin') {
              context.go('/settings');
            } else {
              context.go('signin');
            }
            return Container();
          } else if (prefs.containsKey('email') &&
              prefs.containsKey('password')) {
            // print('Profile: auth role null, but shared prefs is there');
            signInWithSharedPrefs(context, '', ref, prefs);
            return Container();
          } else {
            context.go('/signin');
            return Container();
          }
        }, loading: () {
          return const CircularProgressIndicator();
        }, error: (error, stack) {
          return Text('$error\n$stack');
        }));
  }
}
