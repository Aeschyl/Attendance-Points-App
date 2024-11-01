import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_lettering_point_app/Pages/User/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fbla_lettering_point_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fbla_lettering_point_app/Pages/Admin/admin_event_view.dart';
import 'package:fbla_lettering_point_app/Pages/Admin/admin_timeline.dart';

var buttonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(mainColor),
  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(8)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
);
var buttonStyleWhite = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.white),
  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(8)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
);

Timestamp lastRefresh = Timestamp.now();
bool refreshGrace = true;

class SignInAndUpAppBar extends StatelessWidget {
  const SignInAndUpAppBar({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: mainColor,
      title: Row(children: [
        Image.asset(
          "assets/images/transparent-creek.png",
          height: 30,
        ),
        const SizedBox(width: 20),
        Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )
      ]),
    );
  }
}

class ProfileAppBar extends ConsumerWidget {
  const ProfileAppBar({Key? key, required this.title, required this.providers})
      : super(key: key);

  final String title;
  final List providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: mainColor,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/timeline');
            }, // Image tapped
            child: Image.asset(
              'assets/images/transparent-creek.png',
              fit: BoxFit.cover, // Fixes border issues
              height: 30.0,
            ),
          ),
          /*Image.asset(
            "assets/images/fbla.png",
            height: 30,
          ),*/
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: buttonStyleWhite,
          onPressed: () {
            if (Timestamp.now().millisecondsSinceEpoch -
                        lastRefresh.millisecondsSinceEpoch >
                    (10 * 1000) ||
                refreshGrace) {
              refreshGrace = false;
              lastRefresh = Timestamp.now();
              for (var i in providers) {
                ref.refresh(i);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Refreshed"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "You are only permitted to refresh every 10 seconds"),
                ),
              );
            }
          }, // nav to profile page
          child: const Icon(
            Icons.refresh,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          style: buttonStyleWhite,
          onPressed: () {
            context.push('/profile');
          }, // nav to profile page
          child: const Icon(
            Icons.person,
            color: Colors.black,
          ),
        )
      ],
    );
  }
}

class SettingsAppBar extends ConsumerWidget {
  const SettingsAppBar({Key? key, required this.title, required this.providers})
      : super(key: key);

  final String title;
  final List providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: mainColor,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/timeline');
            }, // Image tapped
            child: Image.asset(
              'assets/images/transparent-creek.png',
              fit: BoxFit.cover, // Fixes border issues
              height: 30.0,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: buttonStyleWhite,
          onPressed: () {
            if (Timestamp.now().millisecondsSinceEpoch -
                        lastRefresh.millisecondsSinceEpoch >
                    (10 * 1000) ||
                refreshGrace) {
              refreshGrace = false;
              lastRefresh = Timestamp.now();
              for (var i in providers) {
                ref.refresh(i);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Refreshed"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "You are only permitted to refresh every 10 seconds"),
                ),
              );
            }
          }, // nav to profile page
          child: const Icon(
            Icons.refresh,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          style: buttonStyleWhite,
          onPressed: () {
            context.push('/settings');
          }, // nav to profile page
          child: const Icon(
            Icons.settings,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ProfileAndBackButtonEnabledAppBar extends ConsumerWidget {
  const ProfileAndBackButtonEnabledAppBar(
      {Key? key, required this.title, required this.providers})
      : super(key: key);

  final String title;
  final List providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: mainColor,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/timeline');
            }, // Image tapped
            child: Image.asset(
              'assets/images/transparent-creek.png',
              fit: BoxFit.cover, // Fixes border issues
              height: 30.0,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
      actions: [
        ElevatedButton(
          style: buttonStyleWhite,
          onPressed: () {
            if (Timestamp.now().millisecondsSinceEpoch -
                        lastRefresh.millisecondsSinceEpoch >
                    (10 * 1000) ||
                refreshGrace) {
              refreshGrace = false;
              lastRefresh = Timestamp.now();
              for (var i in providers) {
                ref.refresh(i);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Refreshed"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "You are only permitted to refresh every 10 seconds"),
                ),
              );
            }
          }, // nav to profile page
          child: const Icon(
            Icons.refresh,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

const Color mainColor = Color(0xffbb1d2e);
const Color secondaryColor = Color(0xff666666);
const Color accentColor = Color(0xff103283);
