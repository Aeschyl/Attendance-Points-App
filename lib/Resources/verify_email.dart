import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/DB_Deserialization/category_points.dart';
import 'package:fbla_lettering_point_app/Pages/signup.dart';
import 'package:fbla_lettering_point_app/Pages/timelineredirect.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    Key? key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
    } catch (e) {
      // print(e);
    }
    if (!mounted) return;
    if (this.mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    }
    if (isEmailVerified) {
      // print("ASDASWDEBUGGER");
      timer?.cancel();
    } else if (count >= 10) {
      timer?.cancel();
      // print("TIMER EXCPREEDDDD");
      try {
        // print("In try line 77");
        final user = FirebaseAuth.instance.currentUser;
        await user?.delete();
      } catch (e) {
        // print("in catch");
        // print(e);
      }
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } catch (e) {
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      var userData = <String, dynamic>{
        "categoryPoints": CategoryPoints.defaults().toJson(),
        "email": widget.email,
        "firstName": widget.firstName,
        "fullName": widget.firstName + ' ' + widget.lastName,
        "lastName": widget.lastName,
        "role": "user",
      };
      db
          .collection("users")
          .doc(widget.email)
          .set(userData); // Send data to firebase
      // // print(credential.user!.email);
      // // print(credential.credential);
      // // print(credential.additionalUserInfo);
      const snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Verified',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      context.go('/signin');
      return Container();
    } else if (!isEmailVerified && count >= 10) {
      context.go('/signup');
      return Container();
    } else {
      return MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
        ),
        body: const Center(
          child: Text(
            'A verification email has been sent to your inbox. Make sure to check your spam folder!',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
  }
}
