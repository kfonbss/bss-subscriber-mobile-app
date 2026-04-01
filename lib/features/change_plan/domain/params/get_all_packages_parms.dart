import 'package:equatable/equatable.dart';

class GetAllPackagesParams extends Equatable {
  final String subscriberId;
  final String? search;
  final String type;
  final int? speedMbps;
  final bool? ott;

  const GetAllPackagesParams({
    required this.subscriberId,
    this.search,
    this.type = 'retail',
    this.speedMbps,
    this.ott,
  });

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};
    params['subscriberId'] = subscriberId;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    params['type'] = type;
    if (speedMbps != null) params['speedMbps'] = speedMbps;
    if (ott != null) params['ott'] = ott;
    return params;
  }

  @override
  List<Object?> get props => [subscriberId, search, type, speedMbps, ott];
}
