// Flutter widgets package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/category_points.dart';
import 'package:fbla_lettering_point_app/Pages/signin.dart';
import 'package:fbla_lettering_point_app/Pages/timelineredirect.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:fbla_lettering_point_app/Resources/verify_email.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:flutter/material.dart';

// Pages
import 'package:fbla_lettering_point_app/Pages/User/timeline.dart';

// DB/Auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// API Requests
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final _emailProvider = StateProvider((ref) {
  return TextEditingController();
});

final _passwordProvider = StateProvider((ref) {
  return TextEditingController();
});

final _firstNameProvider = StateProvider((ref) {
  return TextEditingController();
});
final _lastNameProvider = StateProvider((ref) {
  return TextEditingController();
});

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
});

class SignUpPage extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _emailController = ref.watch(_emailProvider);
    _passwordController = ref.watch(_passwordProvider);
    _firstNameController = ref.watch(_firstNameProvider);
    _lastNameController = ref.watch(_lastNameProvider);
    final _auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);

    return Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SignInAndUpAppBar(title: "Sign Up"),
        ),
        body: preferences.when(data: (prefs) {
          if (_auth.role != null) {
            // print('auth role not null,');
            if (_auth.role == 'admin' ||
                _auth.role == 'user' ||
                _auth.role == 'officer') {
              context.go('/timeline');
            } else {
              context.go('/signin');
            }
            return Container();
          } else if (prefs.containsKey('email') &&
              prefs.containsKey('password')) {
            // print('auth role null, but shared prefs is there');
            signInWithSharedPrefs(context, '/timeline', ref, prefs);
            return Container();
          } else {
            // print('Everything is null');
            return SafeArea(
              minimum: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _firstNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter your first name";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "First Name"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter your last name";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Last Name"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter an email";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: "Email"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onFieldSubmitted: (t) => _signUp(context),
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
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: ElevatedButton(
                        style: buttonStyle,
                        onPressed: () => _signUp(context),
                        child: const Text("Sign Up"),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            context.go('/signin');
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }, loading: () {
          return const CircularProgressIndicator();
        }, error: (error, stack) {
          return Text('$error\n$stack');
        }));
  }

  _signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text.contains("@cherrycreekschools.org")) {
        //String start = _firstNameController.text[0] + _lastNameController.text;
        //if (_emailController.text.substring(0, start.length + 1) != start) {
        var email = _emailController.text.trim().toLowerCase();
        var password = _passwordController.text.trim();
        var firstName = _firstNameController.text.trim();
        var lastName = _lastNameController.text.trim();

        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          //WidgetsBinding.instance.addPostFrameCallback((_) {
          /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyEmailPage(
                      email: _emailController.text,
                      password: _passwordController.text,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text),
                ));
            //}); */

          FirebaseFirestore db = FirebaseFirestore.instance;
          var userData = <String, dynamic>{
            "categoryPoints": CategoryPoints.defaults().toJson(),
            "email": email,
            "firstName": firstName,
            "fullName": firstName + ' ' + lastName,
            "lastName": lastName,
            "role": "user",
          };
          db
              .collection("users")
              .doc(_emailController.text)
              .set(userData); // Send data to firebase
          context.go('/signin');
        } on FirebaseAuthException catch (e) {
          if (e.code == "invalid-email") {
            showDialog(
                context: context,
                builder: (context) => const ErrorMessage("Invalid email"));
          } else if (e.code == 'weak-password') {
            showDialog(
                context: context,
                builder: (context) =>
                    const ErrorMessage("Password is too weak"));
          } else if (e.code == 'email-already-in-use') {
            showDialog(
                context: context,
                builder: (context) =>
                    const ErrorMessage("Email is already in use"));
          }
        } catch (e) {
          // // print(e);
        }
        /*} else {
          showDialog(
              context: context,
              builder: (context) => ErrorMessage(
                  "Your email is invalid. Make sure to use your own valid cherrycreek email"));
        }*/
      } else {
        showDialog(
            context: context,
            builder: (context) =>
                const ErrorMessage("Must use cherrycreekschools.org email"));
      }
    }
  }
}
