import 'package:fbla_lettering_point_app/Pages/Admin/admin_event_view.dart';
import 'package:fbla_lettering_point_app/Pages/User/event_view.dart';
import 'package:fbla_lettering_point_app/Pages/signin.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:fbla_lettering_point_app/Resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _sharedPrefs = FutureProvider((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
});

class EventRedirect extends ConsumerWidget {
  const EventRedirect({required this.docID, Key? key}) : super(key: key);

  final String docID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var auth = ref.watch(authProvider);
    AsyncValue<SharedPreferences> preferences = ref.watch(_sharedPrefs);

    return Scaffold(
        body: preferences.when(data: (prefs) {
          if (auth.role != null) {
            // print('Event: auth role not null,');
            if (auth.role == 'admin') {
              return AdminEventView(docID: docID);
            } else if (auth.role == 'officer' || auth.role == 'user') {
              return EventView(docID: docID);
            } else {
              context.go('/signin');
              return Container();
            }
          } else if (prefs.containsKey('email') && prefs.containsKey('password')) {
            // print('Event: auth role null, but shared prefs is there');
            signInWithSharedPrefs(context, '', ref, prefs);
            return Container();
          } else {
            return SignInPopup(GoRouter.of(context).location, "Sign In");
          }
        }, loading: () {
          return const CircularProgressIndicator();
        }, error: (error, stack) {
          return Text('$error\n$stack');
        }));
  }
}
