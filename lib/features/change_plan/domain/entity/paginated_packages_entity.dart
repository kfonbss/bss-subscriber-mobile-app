import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';

class PaginatedPackagesEntity {
  final List<PackageEntity> content;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int number;
  final int size;

  const PaginatedPackagesEntity({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.number,
    required this.size,
  });
}
