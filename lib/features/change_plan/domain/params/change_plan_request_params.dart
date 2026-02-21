import 'package:equatable/equatable.dart';

class ChangePlanRequestParams extends Equatable {
  final String packageId;
  final String packageName;
  final String planType;

  const ChangePlanRequestParams({
    required this.packageId,
    required this.packageName,
    required this.planType,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'packageName': packageName,
      'planType': planType,
    };
  }

  @override
  List<Object?> get props => [packageId, packageName, planType];
}
