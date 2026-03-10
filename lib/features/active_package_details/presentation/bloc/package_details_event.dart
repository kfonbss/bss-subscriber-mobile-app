import 'package:equatable/equatable.dart';

abstract class PackageDetailsEvent extends Equatable {
  const PackageDetailsEvent();

  @override
  List<Object?> get props => [];
}


class GetActivePackageDetails extends PackageDetailsEvent {
  final String subscriberUuid;

  const GetActivePackageDetails({required this.subscriberUuid});

  @override
  List<Object?> get props => [subscriberUuid];
}
