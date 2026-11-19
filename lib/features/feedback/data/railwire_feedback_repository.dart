import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';

/// Sends the app feedback sheet to RailWire's `feedbackentries`.
class RailwireFeedbackRepository {
  /// [rating] is the sheet's 1–5 stars, sent as it is: whether the API expects
  /// 1–5 or 1–10 is an open question with the PHP team. `stcode` and
  /// `username` aren't in the API document but let the feedback be traced.
  static Future<Either<Failure, Unit>> send(int rating, String comment) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireFeedbackEntriesURL,
      (session) => {
        'star_rating': rating.toString(),
        'txt_message': comment,
        ...session.byUsername,
      },
    );
    return result.map((_) => unit);
  }
}
