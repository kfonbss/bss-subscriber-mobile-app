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
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      code:        json['code']        as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive:    json['isActive']    as bool?   ?? false,
    );
  }

  PackageTypeEntity toEntity() => PackageTypeEntity(
    id: id, name: name, code: code,
    nameInLocal: nameInLocal, isActive: isActive,
  );
}

class PlanTypeModel {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PlanTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  factory PlanTypeModel.fromJson(Map<String, dynamic> json) {
    return PlanTypeModel(
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      code:        json['code']        as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive:    json['isActive']    as bool?   ?? false,
    );
  }

  PlanTypeEntity toEntity() => PlanTypeEntity(
    id: id, name: name, code: code,
    nameInLocal: nameInLocal, isActive: isActive,
  );
}

class PackagePlanTypeModel {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const PackagePlanTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  factory PackagePlanTypeModel.fromJson(Map<String, dynamic> json) {
    return PackagePlanTypeModel(
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      code:        json['code']        as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive:    json['isActive']    as bool?   ?? false,
    );
  }

  PackagePlanTypeEntity toEntity() => PackagePlanTypeEntity(
    id: id, name: name, code: code,
    nameInLocal: nameInLocal, isActive: isActive,
  );
}

class SubscriberProfileModel {
  final String id;
  final String name;
  final String code;
  final String nameInLocal;
  final bool isActive;

  const SubscriberProfileModel({
    required this.id,
    required this.name,
    required this.code,
    required this.nameInLocal,
    required this.isActive,
  });

  factory SubscriberProfileModel.fromJson(Map<String, dynamic> json) {
    return SubscriberProfileModel(
      id:          json['id']          as String? ?? '',
      name:        json['name']        as String? ?? '',
      code:        json['code']        as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive:    json['isActive']    as bool?   ?? false,
    );
  }

  SubscriberProfileEntity toEntity() => SubscriberProfileEntity(
    id: id, name: name, code: code,
    nameInLocal: nameInLocal, isActive: isActive,
  );
}

class PackageItemModel {
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
  final PackageTypeModel? packageType;
  final PlanTypeModel? planType;
  final String? category;
  final PackagePlanTypeModel? packagePlanType;
  final SubscriberProfileModel? subscriberProfile;
  final String? seasonalDiscount;

  const PackageItemModel({
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

  factory PackageItemModel.fromJson(Map<String, dynamic> json) {
    return PackageItemModel(
      id:                          json['id']                          as String? ?? '',
      packageName:                 json['packageName']                 as String? ?? '',
      freeValidity:                json['freeValidity']                as int?    ?? 0,
      initialFreeValidity:         json['initialFreeValidity']         as int?    ?? 0,
      renewalFee:                  (json['renewalFee']                 as num?)?.toDouble() ?? 0.0,
      allocatedVolume:             (json['allocatedVolume']            as num?)?.toDouble() ?? 0.0,
      discount:                    json['discount']                    as String?,
      fallbackSpeed:               json['fallbackSpeed']               as String? ?? '',
      subPackageCount:             json['subPackageCount']             as int?    ?? 0,
      totalPackageCount:           json['totalPackageCount']           as int?,
      renewPeriod:                 json['renewPeriod']                 as int?    ?? 0,
      speedInKbps:                 json['speedInKbps']                 as int?    ?? 0,
      packageType:      PackageTypeModel.fromJson(json['packageType']           as Map<String, dynamic>? ?? {}),
      planType:         PlanTypeModel.fromJson(json['planType']                 as Map<String, dynamic>? ?? {}),
      category:                    json['category']                    as String?,
      packagePlanType:  PackagePlanTypeModel.fromJson(json['packagePlanType']   as Map<String, dynamic>? ?? {}),
      subscriberProfile: SubscriberProfileModel.fromJson(json['subscriberProfile'] as Map<String, dynamic>? ?? {}),
      seasonalDiscount:            json['seasonalDiscount']            as String?,
    );
  }

  PackageItemEntity toEntity() => PackageItemEntity(
    id:                          id,
    packageName:                 packageName,
    freeValidity:                freeValidity,
    initialFreeValidity:         initialFreeValidity,
    renewalFee:                  renewalFee,
    allocatedVolume:             allocatedVolume,
    discount:                    discount,
    fallbackSpeed:                fallbackSpeed,
    subPackageCount:             subPackageCount,
    totalPackageCount:           totalPackageCount,
    renewPeriod:                 renewPeriod,
    speedInKbps:                 speedInKbps,
    packageType:                 packageType!.toEntity(),
    planType:                    planType!.toEntity(),
    category:                    category,
    packagePlanType:             packagePlanType!.toEntity(),
    subscriberProfile:           subscriberProfile!.toEntity(),
    seasonalDiscount:            seasonalDiscount,
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
      pageNumber: json['pageNumber'] as int?  ?? 0,
      pageSize:   json['pageSize']   as int?  ?? 0,
      offset:     json['offset']     as int?  ?? 0,
      paged:      json['paged']      as bool? ?? false,
      unpaged:    json['unpaged']    as bool? ?? false,
    );
  }

  PageableEntity toEntity() => PageableEntity(
    pageNumber: pageNumber,
    pageSize:   pageSize,
    offset:     offset,
    paged:      paged,
    unpaged:    unpaged,
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
      content: (json['content'] as List<dynamic>?)
          ?.map((e) => PackageItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      pageable:         PageableModel.fromJson(json['pageable'] as Map<String, dynamic>? ?? {}),
      totalElements:    json['totalElements']    as int?  ?? 0,
      totalPages:       json['totalPages']       as int?  ?? 0,
      last:             json['last']             as bool? ?? false,
      size:             json['size']             as int?  ?? 0,
      number:           json['number']           as int?  ?? 0,
      numberOfElements: json['numberOfElements'] as int?  ?? 0,
      first:            json['first']            as bool? ?? false,
      empty:            json['empty']            as bool? ?? false,
    );
  }

  PackageNewEntity toEntity() => PackageNewEntity(
    content:          content.map((e) => e.toEntity()).toList(),
    pageable:         pageable.toEntity(),
    totalElements:    totalElements,
    totalPages:       totalPages,
    last:             last,
    size:             size,
    number:           number,
    numberOfElements: numberOfElements,
    first:            first,
    empty:            empty,
  );
}