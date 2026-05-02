import 'package:equatable/equatable.dart';

class GetAllPackagesParams extends Equatable {
  final String subscriberId;
  final String? search;
  final String type;
  final int? speedMbps;
  final bool? ott;
  final int page;
  final int size;

  const GetAllPackagesParams({
    required this.subscriberId,
    this.search,
    this.type = 'retail',
    this.speedMbps,
    this.ott,
    required this.page,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};
    params['subscriberId'] = subscriberId;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    params['type'] = type;
    if (speedMbps != null) params['speedMbps'] = speedMbps;
    if (ott != null) params['ott'] = ott;
    params['page'] = page;
    params['size'] = size;
    return params;
  }

  @override
  List<Object?> get props => [subscriberId, search, type, speedMbps, ott,page,size];
}
