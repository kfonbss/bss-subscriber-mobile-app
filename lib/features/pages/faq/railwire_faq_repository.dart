import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';

/// One FAQ from RailWire's `faqdetails`.
class RailwireFaq {
  final String question;
  final String answer;

  /// Empty until the API sends `category`.
  final String category;

  const RailwireFaq({
    required this.question,
    required this.answer,
    this.category = '',
  });

  factory RailwireFaq.fromJson(Map<String, dynamic> json) => RailwireFaq(
    question: json['question']?.toString().trim() ?? '',
    answer: json['answer']?.toString().trim() ?? '',
    category: json['category']?.toString().trim() ?? '',
  );
}

class RailwireFaqRepository {
  /// The state's FAQs, without ones that have no question.
  static Future<Either<Failure, List<RailwireFaq>>> fetch() async {
    final result = await RailwireApi.get(
      ApiUrls.railwireFaqDetailsURL,
      (session) => {'stcode': session.stateCode},
    );
    return result.map(
      (data) =>
          (data['faqs_list'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(RailwireFaq.fromJson)
              .where((faq) => faq.question.isNotEmpty)
              .toList(),
    );
  }
}
