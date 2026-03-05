import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final int subscriberId;
  final String name;
  final String status;

  const ProfileEntity({
    required this.subscriberId,
    required this.name,
    required this.status,
  });

  @override
  List<Object?> get props => [subscriberId, name, status];
}
