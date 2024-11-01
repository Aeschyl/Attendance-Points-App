// Flutter widgets package
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/category_points.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:flutter/material.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';

// Pages
import 'package:fbla_lettering_point_app/Pages/User/timeline.dart';
import 'package:fbla_lettering_point_app/Pages/signup.dart';
import 'package:go_router/go_router.dart';

// DB/Auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fbla_lettering_point_app/main.dart';

// API Requests
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../DB_Deserialization/user.dart';
import '../Resources/log_in_saver.dart';

final _emailProvider = StateProvider((ref) {
  return TextEditingController();
});

final _passwordProvider = StateProvider((ref) {
  return TextEditingController();
});

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
});

class SignInPage extends ConsumerWidget {
  late UserData serializedUserData;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _emailController = ref.watch(_emailProvider);
    final _passwordController = ref.watch(_passwordProvider);
    final _auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);

    //AsyncValue<UserData> sharedPrefs = ref.watch(sharedPrefUserProvider);
    // print("AA");
    return Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SignInAndUpAppBar(title: "Sign In"),
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
            return Form(
              key: _formKey,
              child: SafeArea(
                minimum: const EdgeInsets.all(20),
                child: ListView(
                  children: [
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
                        onFieldSubmitted: (t) => _signIn(context, ref, prefs),
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
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: buttonStyle,
                        onPressed: () => _signIn(context, ref, prefs),
                        child: const Text("Sign in"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account? "),
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
                    )
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

  _signIn(BuildContext context, WidgetRef ref, SharedPreferences prefs) async {
    final _emailController = ref.watch(_emailProvider);
    final _passwordController = ref.watch(_passwordProvider);
    final _auth = ref.watch(authProvider);

    if (_formKey.currentState!.validate()) {
      try {
        var email = _emailController.text.trim().toLowerCase();
        var password = _passwordController.text.trim();
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        FirebaseFirestore db = FirebaseFirestore.instance;
        var userData = await db.collection("users").doc(email).get();
        serializedUserData = UserData.fromJson(userData.data()!);
        ref.read(authProvider.state).state = serializedUserData;
        prefs.setString('email', encryptAES(email));
        prefs.setString('password', encryptAES(password));
        // Go to timeline
        context.go('/timeline');
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
    }
    ref.read(_emailProvider.state).state = TextEditingController();
    ref.read(_passwordProvider.state).state = TextEditingController();
  }
}
