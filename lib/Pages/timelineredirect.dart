import 'package:fbla_lettering_point_app/Pages/signin.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DB_Deserialization/user.dart';
import 'Admin/admin_timeline.dart';
import 'Officer/officer_timeline.dart';
import 'User/timeline.dart';

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
});

class TimelineRedirect extends ConsumerWidget {
  const TimelineRedirect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var _auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);

    return Scaffold(
        body: preferences.when(data: (prefs) {
      if (_auth.role != null) {
        // print('Timeline: auth role not null,');
        if (_auth.role == 'admin') {
          return AdminTimeline();
        } else if (_auth.role == 'user') {
          return Timeline();
        } else if (_auth.role == 'officer') {
          return OfficerTimeline();
        } else {
          context.go('/signin');
          return Container();
        }
      } else if (prefs.containsKey('email') && prefs.containsKey('password')) {
        // print('Timeline: auth role null, but shared prefs is there');
        signInWithSharedPrefs(context, '', ref, prefs);
        if (_auth.role == 'admin') {
          return AdminTimeline();
        } else if (_auth.role == 'user') {
          return Timeline();
        } else if (_auth.role == 'officer') {
          return OfficerTimeline();
        } else {
          return Container();
        }
      } else {
        return SignInPopup("/timeline", "Sign In");
      }
    }, loading: () {
      return const CircularProgressIndicator();
    }, error: (error, stack) {
      return Text('$error\n$stack');
    }));
  }
}
