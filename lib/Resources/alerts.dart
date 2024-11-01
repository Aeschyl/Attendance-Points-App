import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fbla_lettering_point_app/Pages/signin.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DB_Deserialization/event.dart';
import '../DB_Deserialization/user.dart';
import '../main.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(
    this.error, {
    Key? key,
  }) : super(key: key);
  final String error;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: AlertDialog(
            buttonPadding: const EdgeInsets.only(bottom: 20, right: 40),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            title: Text(error),
            actions: [
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  Navigator.pop(
                      context); // use navigator.pop here as it doesnt work with gorouter
                },
                child: const Text('Close'),
              ),
            ]),
      ),
    );
  }
}

class ErrorMessageWithRoute extends StatelessWidget {
  const ErrorMessageWithRoute(this.error, this.route, {Key? key})
      : super(key: key);
  final String error;
  final String route;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: AlertDialog(
            buttonPadding: const EdgeInsets.only(bottom: 20, right: 40),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(error),
            actions: [
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  Navigator.pop(
                      context); // use navigator.pop here as it doesnt work with gorouter
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  context.go(route);
                },
                child: const Text('Sign up'),
              ),
            ]),
      ),
    );
  }
}

class ErrorMessageWithRouteUncloseable extends StatelessWidget {
  const ErrorMessageWithRouteUncloseable(this.error, this.route, this.routeName,
      {Key? key})
      : super(key: key);
  final String error;
  final String route;
  final String routeName;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: AlertDialog(
            buttonPadding: const EdgeInsets.only(bottom: 20, right: 40),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            title: Text(error),
            actions: [
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  context.go(route);
                },
                child: Text(routeName),
              ),
            ]),
      ),
    );
  }
}

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
});

class SignInPopup extends ConsumerWidget {
  SignInPopup(this.route, this.routeName, {Key? key}) : super(key: key);

  final _emailProvider = StateProvider((ref) {
    return TextEditingController();
  });

  final _passwordProvider = StateProvider((ref) {
    return TextEditingController();
  });

  final String route;
  final String routeName;
  final _formKey = GlobalKey<FormState>();
  late UserData serializedUserData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _emailController = ref.watch(_emailProvider);
    final _passwordController = ref.watch(_passwordProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);
    final _auth = ref.watch(authProvider);
    if (_auth.role != null) {
      // makes it so if you are logged in and go to signin it doesnt let you
      context.go(route);
      // print("Alerts.dart signinpopup failure on auth role ${_auth.role}");
      return Container();
    } else {
      return Scaffold(
          body: preferences.when(data: (prefs) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              title: Center(
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    minimum: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: 250,
                      height: 185,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter an email";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Email"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                onFieldSubmitted: (t) =>
                                    _signIn(context, ref, prefs),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter a password";
                                  }
                                  return null;
                                },
                                obscureText: true,
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Password"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go('/signup');
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 15,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Center(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(mainColor),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    const EdgeInsets.all(8),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _signIn(context, ref, prefs);
                                    context.go('/timeline');
                                  }
                                },
                                child: Text(routeName),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }, loading: () {
        return const CircularProgressIndicator();
      }, error: (error, stack) {
        return Text('$error\n$stack');
      }));
    }
  }

  _signIn(BuildContext context, WidgetRef ref, SharedPreferences prefs) async {
    final _emailController = ref.watch(_emailProvider);
    final _passwordController = ref.watch(_passwordProvider);
    final _auth = ref.watch(authProvider);

    var email = _emailController.text.trim().toLowerCase();
    var password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        ); // Send to firebase auth
        FirebaseFirestore db = FirebaseFirestore.instance;
        var userData = await db
            .collection("users")
            .doc(_emailController.text.trim())
            .get();
        serializedUserData = UserData.fromJson(userData.data()!);
        ref.read(authProvider.state).state = serializedUserData;
        prefs.setString('email', encryptAES(email));
        prefs.setString('password', encryptAES(password));
        // Go to timeline
        context.go(route);
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-email") {
          showDialog(
            context: context,
            builder: (context) => const ErrorMessage("Invalid email"),
          );
        } else if (e.code == 'user-not-found') {
          showDialog(
              context: context,
              builder: (context) => const ErrorMessageWithRoute(
                  "Email not registered", "/signup"));
        } else if (e.code == 'wrong-password') {
          showDialog(
              context: context,
              builder: (context) => const ErrorMessage("Wrong password"));
        }
      } catch (e, s) {
        // e is error s is stack trace
        showDialog(
            context: context,
            builder: (context) => ErrorMessage(
                "There was an error please contact us or try again $e"));
      }
    } else {}
    ref.read(_emailProvider.state).state = TextEditingController();
    ref.read(_passwordProvider.state).state = TextEditingController();
  }
}

final _selectionProvider = StateProvider((ref) => "Social");

class AddEventPopup extends ConsumerWidget {
  AddEventPopup({required this.eventProviderDeletion, Key? key})
      : super(key: key);
  final _titleProvider = StateProvider((ref) {
    return TextEditingController();
  });
  final _dateProvider = StateProvider((ref) {
    return TextEditingController();
  });
  final _placeProvider = StateProvider((ref) {
    return TextEditingController();
  });
  final _categoryProvider = StateProvider((ref) {
    return TextEditingController();
  });
  final _pointsProvider = StateProvider((ref) {
    return TextEditingController();
  });
  final _dateDataProvider = StateProvider((ref) {
    return DateTime(2022);
  });
  final _timeDataProvider = StateProvider((ref) {
    return TimeOfDay(hour: 12, minute: 0);
  });
  final _maxAttendeesProvider = StateProvider((ref) {
    return TextEditingController();
  });
  //final selectionProvider = StateProvider((ref) => 'Uncategorized');
  final eventProviderDeletion;
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final _formKey = GlobalKey<FormState>();

  var items = [
    'Social',
    'Competitive Prep',
    'Community Service',
    'Business',
    'Fundraising'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _titleController = ref.watch(_titleProvider);
    final _dateController = ref.watch(_dateProvider);
    final _placeController = ref.watch(_placeProvider);
    //final _categoryController = ref.watch(_categoryProvider);
    final _pointsController = ref.watch(_pointsProvider);
    final _maxAttendeesController = ref.watch(_maxAttendeesProvider);
    String dropdownvalue = ref.watch(_selectionProvider);

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: GestureDetector(
            onTap: () {},
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              title: Center(
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    minimum: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: 350,
                      height: 385,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                controller: _titleController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter a title";
                                  } else if (value.length > 50) {
                                    return "Max character limit is 50, you entered ${value.length} characters";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Title"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                controller: _placeController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter a place";
                                  } else if (value.length > 20) {
                                    return "Max character limit is 20";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Place"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonFormField(
                              // Initial Value
                              value: dropdownvalue,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                ref.read(_selectionProvider.state).state =
                                    newValue!;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                controller: _pointsController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter the number of points awarded for attendance";
                                  } else if (value.length > 3) {
                                    return "Pick a smaller number";
                                  }
                                  return null;
                                },
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Points"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 50,
                              width: 100,
                              child: TextFormField(
                                controller: _maxAttendeesController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter the number of maximum attendees";
                                  }
                                  return null;
                                },
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Maximum Attendees"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: DateTimeField(
                              validator: (dateTime) {
                                if (dateTime == null) {
                                  return "Provide a date and time";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                fillColor: mainColor,
                                border: OutlineInputBorder(),
                                labelText: "Date and Time",
                              ),
                              format: format,
                              controller: _dateController,
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2021),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date == null) return null;
                                ref.read(_dateDataProvider.state).state = date;

                                if (date.day != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        currentValue ?? DateTime.now()),
                                  );
                                  if (time == null) return null;
                                  ref.read(_timeDataProvider.state).state =
                                      time;
                                  return DateTimeField.combine(date, time);
                                }

                                return currentValue;
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(mainColor),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.all(8),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(mainColor),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.all(8),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      String temp =
                                          _titleController.text.trim();
                                      if (_formKey.currentState!.validate()) {
                                        _createEvent(context, ref);
                                        Navigator.pop(context);
                                      } else {
                                        _titleController.text = temp;
                                      }
                                    },
                                    child: const Text("Create Event"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _createEvent(BuildContext context, WidgetRef ref) async {
    final _titleController = ref.watch(_titleProvider);
    final _dateController = ref.watch(_dateProvider);
    final _placeController = ref.watch(_placeProvider);
    final _categoryController = ref.watch(_selectionProvider);
    final _pointsController = ref.watch(_pointsProvider);
    final _maxAttendeesController = ref.watch(_maxAttendeesProvider);
    final _auth = ref.watch(authProvider);
    // print("category " + _categoryController);

    if (_formKey.currentState!.validate()) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("events").add(Event(
            date: Timestamp.fromDate(
              DateTimeField.combine(ref.read(_dateDataProvider.state).state,
                  ref.read(_timeDataProvider.state).state),
            ),
            place: _placeController.text.trim(),
            title: _titleController.text.trim(),
            participants: [],
            category: _categoryController.trim(),
            points: int.parse(_pointsController.text.trim()),
            maximumAttendees: int.parse(_maxAttendeesController.text.trim()),
          ).toJson());
      ref.refresh(eventProviderDeletion);
    } else {}
  }
}

class EditEventPopup extends ConsumerWidget {
  EditEventPopup({required this.currEvent, required this.provider, Key? key})
      : super(key: key);
  late Event currEvent;
  late FutureProvider provider;

  var items = [
    'Social',
    'Competitive Prep',
    'Community Service',
    'Business',
    'Fundraising'
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? newTitle = currEvent.title;
    String? newPlace = currEvent.place;
    String? newCategory = currEvent.category;
    int? newPoints = currEvent.points;
    Timestamp? newDateTime = currEvent.date;
    int? newMaxAttendees = currEvent.maximumAttendees;
    final format = DateFormat("yyyy-MM-dd HH:mm");
    //TODO Finsih the rest of this with TextFormFields and such uk how it is
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: GestureDetector(
                  onTap: () {},
                  child: AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    title: Center(
                        child: Form(
                      child: SafeArea(
                          minimum: const EdgeInsets.all(20),
                          child: SizedBox(
                              width: 350,
                              height: 385,
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      initialValue: newTitle,
                                      onChanged: (t) => newTitle = t.trim(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      initialValue: newPlace,
                                      onChanged: (t) => newPlace = t.trim(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: DropdownButtonFormField(
                                      // Initial Value
                                      value: newCategory,

                                      // Down Arrow Icon
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),

                                      // Array list of items
                                      items: items.map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      // After selecting the desired option,it will
                                      // change button value to selected value
                                      onChanged: (String? newValue) {
                                        newCategory = newValue;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      initialValue: newPoints.toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (t) =>
                                          newPoints = int.parse(t),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      initialValue: newMaxAttendees.toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (t) =>
                                          newMaxAttendees = int.parse(t),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: DateTimeField(
                                      initialValue: newDateTime?.toDate(),
                                      format: format,
                                      decoration: const InputDecoration(
                                        fillColor: mainColor,
                                        border: OutlineInputBorder(),
                                        labelText: "Date and Time",
                                      ),
                                      onChanged: (t) => newDateTime =
                                          Timestamp.fromDate(
                                              t ?? DateTime.now()),
                                      onShowPicker:
                                          (context, currentValue) async {
                                        final date = await showDatePicker(
                                            builder: (context, child) => Theme(
                                                  child: child!,
                                                  data: ThemeData(
                                                      colorScheme:
                                                          const ColorScheme
                                                                  .dark(
                                                              primary:
                                                                  mainColor,
                                                              surface:
                                                                  secondaryColor,
                                                              onPrimary:
                                                                  accentColor)),
                                                ),
                                            context: context,
                                            firstDate: DateTime(2021),
                                            initialDate:
                                                newDateTime?.toDate() ??
                                                    DateTime.now(),
                                            lastDate: DateTime(2100));
                                        if (date == null) return null;

                                        if (date.day != null) {
                                          final time = await showTimePicker(
                                            builder: (context, child) => Theme(
                                              child: child!,
                                              data: ThemeData(
                                                  colorScheme:
                                                      const ColorScheme.dark(
                                                          primary: mainColor,
                                                          surface:
                                                              secondaryColor,
                                                          onPrimary:
                                                              accentColor)),
                                            ),
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                currentValue ?? DateTime.now()),
                                          );
                                          if (time == null) return null;

                                          return DateTimeField.combine(
                                              date, time);
                                        }

                                        return currentValue;
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 8, 8),
                                        child: Center(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      mainColor),
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                const EdgeInsets.all(8),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 8),
                                        child: Center(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      mainColor),
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                const EdgeInsets.all(8),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              currEvent.title =
                                                  newTitle ?? currEvent.title;
                                              currEvent.place =
                                                  newPlace ?? currEvent.place;
                                              currEvent.category =
                                                  newCategory ??
                                                      currEvent.category;
                                              currEvent.points =
                                                  newPoints ?? currEvent.points;
                                              currEvent.maximumAttendees =
                                                  newMaxAttendees ??
                                                      currEvent
                                                          .maximumAttendees;
                                              currEvent.date =
                                                  newDateTime ?? currEvent.date;

                                              FirebaseFirestore.instance
                                                  .collection("events")
                                                  .doc(currEvent.documentId)
                                                  .set(currEvent.toJson());
                                              ref.refresh(provider);
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Update"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ))),
                    )),
                  ),
                ))));
  }
}

class ConfirmDeletion extends ConsumerWidget {
  const ConfirmDeletion(
      {required this.name,
      required this.email,
      required this.route,
      required this.userProvider,
      Key? key})
      : super(key: key);
  final String route;
  final String name;
  final String email; // name of event/student
  final userProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: AlertDialog(
            buttonPadding: const EdgeInsets.only(bottom: 20, right: 40),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            title: Text("Are you sure you want to delete $name ($email)"),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(8)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(8)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(email)
                      .delete();
                  FirebaseAuth.instance.currentUser?.delete();

                  ref.refresh(userProvider);
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ]),
      ),
    );
  }
}
