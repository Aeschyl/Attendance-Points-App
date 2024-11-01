import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alerts.dart';

late UserData serializedUserData;

String encryptAES(String? plainText) {
  final key = encrypt.Key.fromUtf8('7436773979244226452948404D635166');
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter.encrypt(plainText!, iv: iv).base64;
  //return encrypted!.base64;
}

String decryptAES(String? plainText) {
  final key = encrypt.Key.fromUtf8('7436773979244226452948404D635166');
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter.decrypt(encrypt.Encrypted.from64(plainText!), iv: iv);
  //return decrypted;
}

signInWithSharedPrefs(BuildContext context, String destination, WidgetRef ref,
    SharedPreferences prefs) async {
  // print("1");
  String? email = decryptAES(prefs.getString('email'));
  String? password = decryptAES(prefs.getString('password'));
  // print("email: ${email == null} ");
  // print("password: ${password == null} ");
  // print("2");
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // print("3");
    FirebaseFirestore db = FirebaseFirestore.instance;
    var userData = await db.collection("users").doc(email).get();
    serializedUserData = UserData.fromJson(userData.data()!);
    ref.read(authProvider.state).state = serializedUserData;
    // print("SIGNED IN W SHARED PREFS");
    if (!destination.isEmpty) {
      context.go(destination);
    }
    // Go to timeline
  } on FirebaseAuthException catch (e) {
    // print("Exception $e");
    if (e.code == "invalid-email" ||
        e.code == 'user-not-found' ||
        e.code == 'wrong-password') {
      prefs.remove('email');
      prefs.remove('password');
      showDialog(
        context: context,
        builder: (context) => const ErrorMessage(
            "There was an error. Please log in try logging in again"),
      );
    }
  } catch (e, s) {
    // print("CATCHECD $e,   $s");
    // e is error s is stack trace
    showDialog(
        context: context,
        builder: (context) => ErrorMessage(
            "There was an error please contact us or try again. $e"));
  }
}
/*
Future<void> saveUser(
  String email,
) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('email', encryptAES(email));
  prefs.setBool("isLoggedIn", true);
}

Future<void> logOutUser() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.setBool("isLoggedIn", false);
}

Future<String?> getEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return decryptAES(prefs.getString('email'));
}

Future<bool?> checkIfLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('uid');
*/
  // // print("HELLO " + prefs!.containsKey('isLoggedIn').toString());
  // // print("BYE " + prefs!.getBool("isLoggedIn").toString());
  // if (prefs!.containsKey('isLoggedIn')) {
  //   return prefs!.getBool("isLoggedIn");
  // } else {
  //   // print('Returning False');
  //   return false;
  // }
  //}
