class Review {
  String? eventID;
  String? userID;
  String? fullName;
  late String documentID;

  Review({required this.userID, required this.eventID, required this.fullName});
  Review.fromJson(Map<String, dynamic> json) {
    eventID = json['eventID'];
    userID = json['userID'];
    fullName = json['fullName'];
  }

  void addID(String id) {
    documentID = id;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventID'] = eventID;
    data['userID'] = userID;
    data['fullName'] = fullName;
    return data;
  }

  @override
  String toString() {
    return """{
      eventID: ${eventID},
      userID: ${userID},
      fullName: ${fullName}\n}""";
  }
}
