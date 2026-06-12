import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';

class PackageTypeModel {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PackageTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  factory PackageTypeModel.fromJson(Map<String, dynamic> json) {
    return PackageTypeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  PackageTypeEntity toEntity() => PackageTypeEntity(
    id: id,
    name: name,
    code: code,
    nameInLocal: nameInLocal,
    isActive: isActive,
  );
}

class PackageItemModel {
  final String id;
  final String packageName;
  final int freeValidity;
  final int initialFreeValidity;
  final bool createCorrespondingTermPlan;
  final double renewalFee;
  final String speedProfile;
  final String status;
  final double allocatedVolume;
  final String? discount;
  final String fallbackSpeed;
  final int subPackageCount;
  final int? totalPackageCount;
  final String? remarks;
  final int renewPeriod;
  final int speedInKbps;
  final int fbSpeedInKbps;
  final String? type;
  final bool editable;
  final PackageTypeModel packageType;
  final String? category;
  final String? seasonalDiscount;
  final String? subscriberCategory;
  final String? broadbandCategory;
  final double amount;
  final double originalAmount;
  final String? discountType;
  final double discountAmount;
  final double savedAmount;
  final String? festivalTag;
  final String speed;
  final int validity;
  final String volumeType;
  final String volumeValue;
  final String planTypeName;

  const PackageItemModel({
    required this.id,
    required this.packageName,
    required this.freeValidity,
    required this.initialFreeValidity,
    required this.createCorrespondingTermPlan,
    required this.renewalFee,
    required this.speedProfile,
    required this.status,
    required this.allocatedVolume,
    this.discount,
    required this.fallbackSpeed,
    required this.subPackageCount,
    this.totalPackageCount,
    this.remarks,
    required this.renewPeriod,
    required this.speedInKbps,
    required this.fbSpeedInKbps,
    this.type,
    required this.editable,
    required this.packageType,
    this.category,
    this.seasonalDiscount,
    this.subscriberCategory,
    this.broadbandCategory,
    required this.amount,
    required this.originalAmount,
    this.discountType,
    required this.discountAmount,
    required this.savedAmount,
    this.festivalTag,
    required this.speed,
    required this.validity,
    required this.volumeType,
    required this.volumeValue,
    required this.planTypeName,
  });

  factory PackageItemModel.fromJson(Map<String, dynamic> json) {
    return PackageItemModel(
      id: json['id'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      freeValidity: json['freeValidity'] as int? ?? 0,
      initialFreeValidity: json['initialFreeValidity'] as int? ?? 0,
      createCorrespondingTermPlan:
          json['createCorrespondingTermPlan'] as bool? ?? false,
      renewalFee: (json['renewalFee'] as num?)?.toDouble() ?? 0.0,
      speedProfile: json['speedProfile']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      allocatedVolume: (json['allocatedVolume'] as num?)?.toDouble() ?? 0.0,
      discount: json['discount'] as String?,
      fallbackSpeed: json['fallbackSpeed'] as String? ?? '',
      subPackageCount: json['subPackageCount'] as int? ?? 0,
      totalPackageCount: json['totalPackageCount'] as int?,
      remarks: json['remarks'] as String?,
      renewPeriod: json['renewPeriod'] as int? ?? 0,
      speedInKbps: json['speedInKbps'] as int? ?? 0,
      fbSpeedInKbps: json['fbSpeedInKbps'] as int? ?? 0,
      type: json['type'] as String?,
      editable: json['editable'] as bool? ?? false,
      packageType: PackageTypeModel.fromJson(
        json['packageType'] as Map<String, dynamic>? ?? {},
      ),
      category: json['category'] as String?,
      seasonalDiscount: json['seasonalDiscount'] as String?,
      subscriberCategory: json['subscriberCategory'] as String?,
      broadbandCategory: json['broadbandCategory'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      festivalTag: json['festivalTag'] as String?,
      speed: json['speed']?.toString() ?? '',
      validity: json['validity'] as int? ?? 0,
      volumeType: json['volumeType'] as String? ?? '',
      volumeValue: json['volumeValue'] as String? ?? '',
      planTypeName: json['planTypeName'] as String? ?? '',
    );
  }

  PackageInfoEntity toEntity() => PackageInfoEntity(
    id: id,
    packageName: packageName,
    freeValidity: freeValidity,
    initialFreeValidity: initialFreeValidity,
    createCorrespondingTermPlan: createCorrespondingTermPlan,
    renewalFee: renewalFee,
    speedProfile: speedProfile,
    status: status,
    allocatedVolume: allocatedVolume,
    discount: discount,
    fallbackSpeed: fallbackSpeed,
    subPackageCount: subPackageCount,
    totalPackageCount: totalPackageCount,
    remarks: remarks,
    renewPeriod: renewPeriod,
    speedInKbps: speedInKbps,
    fbSpeedInKbps: fbSpeedInKbps,
    type: type,
    editable: editable,
    packageType: packageType.toEntity(),
    category: category,
    seasonalDiscount: seasonalDiscount,
    subscriberCategory: subscriberCategory,
    broadbandCategory: broadbandCategory,
    amount: amount,
    originalAmount: originalAmount,
    discountType: discountType,
    discountAmount: discountAmount,
    savedAmount: savedAmount,
    festivalTag: festivalTag,
    speed: speed,
    validity: validity,
    volumeType: volumeType,
    volumeValue: volumeValue,
    planTypeName: planTypeName,
  );
}

class PageableModel {
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  const PageableModel({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageableModel.fromJson(Map<String, dynamic> json) {
    return PageableModel(
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
      offset: json['offset'] as int? ?? 0,
      paged: json['paged'] as bool? ?? false,
      unpaged: json['unpaged'] as bool? ?? false,
    );
  }

  PageableEntity toEntity() => PageableEntity(
    pageNumber: pageNumber,
    pageSize: pageSize,
    offset: offset,
    paged: paged,
    unpaged: unpaged,
  );
}

class PackageNewModel {
  final List<PackageItemModel> content;
  final PageableModel pageable;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final int numberOfElements;
  final bool first;
  final bool empty;

  const PackageNewModel({
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

  factory PackageNewModel.fromJson(Map<String, dynamic> json) {
    return PackageNewModel(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((e) => PackageItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pageable: PageableModel.fromJson(
        json['pageable'] as Map<String, dynamic>? ?? {},
      ),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? false,
      size: json['size'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      numberOfElements: json['numberOfElements'] as int? ?? 0,
      first: json['first'] as bool? ?? false,
      empty: json['empty'] as bool? ?? false,
    );
  }

  PackageNewEntity toEntity() => PackageNewEntity(
    content: content.map((e) => e.toEntity()).toList(),
    pageable: pageable.toEntity(),
    totalElements: totalElements,
    totalPages: totalPages,
    last: last,
    size: size,
    number: number,
    numberOfElements: numberOfElements,
    first: first,
    empty: empty,
  );
}
