import 'package:fbla_lettering_point_app/DB_Deserialization/review.dart';

import 'fill_review.dart';

class ReviewGroup {
  List<FillReview> currRev;
  List<Review> rawRev;
  ReviewGroup({required this.rawRev, required this.currRev});

  List<FillReview> getCurrRev() {
    return currRev;
  }

  List<Review> getRawRev() {
    return rawRev;
  }
}
