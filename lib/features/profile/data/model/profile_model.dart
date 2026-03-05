import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.subscriberId,
    required super.name,
    required super.status,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      subscriberId: json['subscriberId'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
