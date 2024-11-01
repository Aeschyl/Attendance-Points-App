// Flutter widgets
import 'dart:developer';

import 'package:fbla_lettering_point_app/DB_Deserialization/user.dart';
import 'package:fbla_lettering_point_app/Pages/Admin/admin_event_view.dart';
import 'package:fbla_lettering_point_app/Pages/User/event_view.dart';
import 'package:fbla_lettering_point_app/Pages/event_redirect.dart';
import 'package:fbla_lettering_point_app/Resources/alerts.dart';
import 'package:fbla_lettering_point_app/Resources/log_in_saver.dart';
import 'package:fbla_lettering_point_app/Resources/verify_email.dart';
import 'package:flutter/material.dart';

// Pages
import 'package:fbla_lettering_point_app/Pages/User/timeline.dart';
import 'package:fbla_lettering_point_app/Pages/signup.dart';
import 'package:fbla_lettering_point_app/Pages/signin.dart';
import 'package:fbla_lettering_point_app/Pages/User/profile.dart';
import 'package:fbla_lettering_point_app/Pages/Admin/admin_timeline.dart';
import 'package:go_router/go_router.dart';

// DB/Auth
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DB_Deserialization/event.dart';
import 'Pages/Admin/settings.dart';
import 'Pages/timelineredirect.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

final authProvider = StateProvider((ref) => UserData());
final eventProvider = StateProvider((ref) => Event());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _router = GoRouter(
    initialLocation: '/signin',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) {
          return SignInPage();
        },
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpPage(),
      ),
      GoRoute(
        path: '/timeline',
        builder: (context, state) {
          /*
          return const ErrorMessageWithRouteUncloseable(
                "You are not authorized", '/signin', 'Sign in');*/
          return const TimelineRedirect();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return Profile();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          return Settings();
        },
      ),
      GoRoute(
        name: "event",
        path: '/timeline/:eventName',
        builder: (context, state) {
          return EventRedirect(docID: state.params['eventName']!);
        },
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FBLA Lettering Points',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
