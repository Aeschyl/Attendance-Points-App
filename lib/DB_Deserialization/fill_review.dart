import 'event.dart';
import 'user.dart';

class FillReview {
  Event? event;
  UserData? user;

  FillReview({required this.user, required this.event});
  Event getEvent() {
    return event!;
  }

  UserData getUser() {
    return user!;
  }

  @override
  String toString() {
    return """{
      event: ${event?.toString()},
      user: ${user?.toString()},\n}""";
  }
}
