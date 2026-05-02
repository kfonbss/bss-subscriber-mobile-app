import 'package:equatable/equatable.dart';

class PackageTypeEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PackageTypeEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, nameInLocal, isActive];
}

class PlanTypeEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PlanTypeEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, nameInLocal, isActive];
}

class PackagePlanTypeEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PackagePlanTypeEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, nameInLocal, isActive];
}

class SubscriberProfileEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const SubscriberProfileEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code, nameInLocal, isActive];
}

class PackageItemEntity extends Equatable {
  final String id;
  final String packageName;
  final int freeValidity;
  final int initialFreeValidity;
  final double renewalFee;
  final double allocatedVolume;
  final String? discount;
  final String fallbackSpeed;
  final int subPackageCount;
  final int? totalPackageCount;
  final int renewPeriod;
  final int speedInKbps;
  final String? category;
  final String? seasonalDiscount;
  final PackageTypeEntity? packageType;
  final PlanTypeEntity? planType;
  final PackagePlanTypeEntity? packagePlanType;
  final SubscriberProfileEntity? subscriberProfile;

  const PackageItemEntity({
    required this.id,
    required this.packageName,
    required this.freeValidity,
    required this.initialFreeValidity,
    required this.renewalFee,
    required this.allocatedVolume,
    this.discount,
    required this.fallbackSpeed,
    required this.subPackageCount,
    this.totalPackageCount,
    required this.renewPeriod,
    required this.speedInKbps,
    this.packageType,
    this.planType,
    this.category,
    this.packagePlanType,
    this.subscriberProfile,
    this.seasonalDiscount,
  });

  @override
  List<Object?> get props => [
    id,
    packageName,
    freeValidity,
    initialFreeValidity,
    renewalFee,
    allocatedVolume,
    discount,
    fallbackSpeed,
    subPackageCount,
    totalPackageCount,
    renewPeriod,
    speedInKbps,
    packageType,
    planType,
    category,
    packagePlanType,
    subscriberProfile,
    seasonalDiscount,
  ];
}

class PageableEntity extends Equatable {
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  const PageableEntity({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  @override
  List<Object?> get props => [pageNumber, pageSize, offset, paged, unpaged];
}

class PackageNewEntity extends Equatable {
  final List<PackageItemEntity> content;
  final PageableEntity pageable;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final int numberOfElements;
  final bool first;
  final bool empty;

  const PackageNewEntity({
    required this.content,
    required this.pageable,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  @override
  List<Object?> get props => [
    content,
    pageable,
    totalElements,
    totalPages,
    last,
    size,
    number,
    numberOfElements,
    first,
    empty,
  ];
}
