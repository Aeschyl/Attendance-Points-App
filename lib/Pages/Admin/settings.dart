import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/Pages/signin.dart';

import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../DB_Deserialization/user.dart';
import '../../Resources/alerts.dart';
import '../../Resources/styles.dart';

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

class Settings extends ConsumerWidget {
  Settings({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ProfileAndBackButtonEnabledAppBar(
          title: "Settings",
          providers: [userProvider],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async => await launchUrlString(
                    "https://outputreport.abhiramkasu.repl.co/get-reports/387345980243845"),
                child: const Text("Get Report")),
          ),
          preferences.when(
            data: (prefs) {
              if (auth.role != null) {
                if (auth.role == 'admin') {
                  String? newFirstName;
                  String? newLastName;
                  String? currentPassword;
                  String? newPassword;
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /* Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      accentColor),
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
                                                  color:
                                                      Colors.black.withOpacity(0.1),
                                                  child: GestureDetector(
                                                      onTap: () => {},
                                                      child: AlertDialog(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius
                                                                          .circular(
                                                                              25))),
                                                          title: Center(
                                                            child: SafeArea(
                                                                minimum:
                                                                    const EdgeInsets
                                                                        .all(20),
                                                                child: SizedBox(
                                                                    width: 300,
                                                                    height: 300,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment
                                                                                  .spaceEvenly,
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets.all(8.0),
                                                                              child:
                                                                                  TextFormField(
                                                                                initialValue:
                                                                                    currUser.firstName,
                                                                                onChanged: (text) =>
                                                                                    newFirstName = text,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets.all(8.0),
                                                                              child:
                                                                                  TextFormField(
                                                                                initialValue:
                                                                                    currUser.lastName,
                                                                                onChanged: (text) =>
                                                                                    newLastName = text,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets.all(8.0),
                                                                                child:
                                                                                    ElevatedButton(style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFFFF1100)),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
                                                                              ),
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets.all(8.0),
                                                                                child: ElevatedButton(
                                                                                  style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      accentColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),
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
                          /* Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(accentColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                              child: const Text("Change Password"),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
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
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius
                                                                          .circular(
                                                                              25))),
                                                          title: Center(
                                                            child: SafeArea(
                                                                minimum:
                                                                    const EdgeInsets
                                                                        .all(20),
                                                                child: SizedBox(
                                                                    width: 300,
                                                                    height: 300,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Form(
                                                                          key:
                                                                              _formKey,
                                                                          child: Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: TextFormField(
                                                                                    validator: (value) {
                                                                                      if (value!.isEmpty) {
                                                                                        return "Enter your current password";
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    onChanged: (text) => currentPassword = text,
                                                                                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Current Password"),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: TextFormField(
                                                                                    validator: (value) {
                                                                                      if (value!.isEmpty) {
                                                                                        return "Enter your new password";
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    onChanged: (text) => newPassword = text,
                                                                                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "New Password"),
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ),
                                                                        Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets.all(8.0),
                                                                                child: ElevatedButton(
                                                                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color(0xFFFF1100)), foregroundColor: MaterialStateProperty.all(Colors.white)),
                                                                                    child: const Text("Cancel"),
                                                                                    onPressed: () => Navigator.pop(context)),
                                                                              ),
                                                                              Padding(
                                                                                padding:
                                                                                    const EdgeInsets.all(8.0),
                                                                                child: ElevatedButton(
                                                                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(accentColor), foregroundColor: MaterialStateProperty.all(Colors.white)),
                                                                                    child: const Text("Update"),
                                                                                    onPressed: () async {
                                                                                      if (_formKey.currentState!.validate()) {
                                                                                        final user = FirebaseAuth.instance.currentUser;
                                                                                        final cred = EmailAuthProvider.credential(email: decryptAES(prefs.getString('email')), password: currentPassword!);

                                                                                        user!.reauthenticateWithCredential(cred).then((value) {
                                                                                          user.updatePassword(newPassword!).then((_) {
                                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                              const SnackBar(
                                                                                                content: Text("Successfully Changed"),
                                                                                              ),
                                                                                            );
                                                                                          }).catchError((error) {
                                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                              const SnackBar(
                                                                                                content: Text("Failed"),
                                                                                              ),
                                                                                            );
                                                                                          });
                                                                                        }).catchError((err) {
                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                            const SnackBar(
                                                                                              content: Text("Current Password did not match. Password unchanged."),
                                                                                            ),
                                                                                          );
                                                                                        });
                                                                                        Navigator.pop(context);
                                                                                      }
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
                          /* Padding(
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
                                  var currUser =
                                      UserData.fromJson(query.docs.first.data());
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
                  );
                } else if (auth.role == 'user' || auth.role == 'officer') {
                  context.go('/profile');
                  return Container();
                } else {
                  context.go('/signin');
                  return Container();
                }
              } else if (prefs.containsKey('email') &&
                  prefs.containsKey('password')) {
                // print('Settings: auth role null, but shared prefs is there');
                signInWithSharedPrefs(context, '', ref, prefs);
                return Container();
              } else {
                context.go('/signin');
                return Container();
              }
            },
            loading: () {
              return const CircularProgressIndicator();
            },
            error: (error, stack) {
              return Text('$error\n$stack');
            },
          ),
        ],
      ),
    );
  }
}
