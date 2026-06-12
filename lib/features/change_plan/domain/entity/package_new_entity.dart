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

class PackageInfoEntity extends Equatable {
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
  final String? remarks;
  final int renewPeriod;
  final int speedInKbps;
  final String? type;
  final PackageTypeEntity packageType;
  final String? category;
  final String? seasonalDiscount;
  final String? subscriberCategory;
  final String? broadbandCategory;
  final String? discountType;
  final String? festivalTag;
  final bool createCorrespondingTermPlan;
  final String speedProfile;
  final String status;
  final int fbSpeedInKbps;
  final bool editable;
  final double amount;
  final double originalAmount;
  final double discountAmount;
  final double savedAmount;
  final String speed;
  final int validity;
  final String volumeType;
  final String volumeValue;
  final String planTypeName;

  const PackageInfoEntity({
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
    this.remarks,
    required this.renewPeriod,
    required this.speedInKbps,
    this.type,
    required this.packageType,
    this.category,
    this.seasonalDiscount,
    this.subscriberCategory,
    this.broadbandCategory,
    this.discountType,
    this.festivalTag,

    required this.createCorrespondingTermPlan,
    required this.speedProfile,
    required this.status,
    required this.fbSpeedInKbps,
    required this.editable,
    required this.amount,
    required this.originalAmount,
    required this.discountAmount,
    required this.savedAmount,
    required this.speed,
    required this.validity,
    required this.volumeType,
    required this.volumeValue,
    required this.planTypeName,

  });

  @override
  List<Object?> get props => [
    id,
    packageName,
    freeValidity,
    initialFreeValidity,
    createCorrespondingTermPlan,
    renewalFee,
    speedProfile,
    status,
    allocatedVolume,
    discount,
    fallbackSpeed,
    subPackageCount,
    totalPackageCount,
    remarks,
    renewPeriod,
    speedInKbps,
    fbSpeedInKbps,
    type,
    editable,
    packageType,
    category,
    seasonalDiscount,
    subscriberCategory,
    broadbandCategory,
    amount,
    originalAmount,
    discountType,
    discountAmount,
    savedAmount,
    festivalTag,
    speed,
    validity,
    volumeType,
    volumeValue,
    planTypeName,
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
  final List<PackageInfoEntity> content;
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
