import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/change_plan_request_params.dart';

enum PackageTabType { addon, standalone, changePackage, upgrade }

extension PackageTabTypeExtension on PackageTabType {
  String get apiValue {
    switch (this) {
      case PackageTabType.addon:
        return 'ADDON';

      case PackageTabType.standalone:
        return 'STANDALONE';

      case PackageTabType.changePackage:
        return 'CHANGE_PACKAGE';

      case PackageTabType.upgrade:
        return 'UPGRADE';
    }
  }

  String get displayName {
    switch (this) {
      case PackageTabType.addon:
        return 'Addon';

      case PackageTabType.standalone:
        return 'Standalone';

      case PackageTabType.changePackage:
        return 'Change Package';

      case PackageTabType.upgrade:
        return 'Upgrade';
    }
  }
}

abstract class SeasonalPlanEvent extends Equatable {
  const SeasonalPlanEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// PACKAGE TAB
// ============================================================

class LoadPackageTab extends SeasonalPlanEvent {
  final String subscriberId;
  final String currentPackageId;

  const LoadPackageTab({
    required this.subscriberId,
    required this.currentPackageId,
  });

  @override
  List<Object?> get props => [subscriberId, currentPackageId];
}

class SelectPackageTab extends SeasonalPlanEvent {
  final PackageTabType tab;
  final String subscriberId;
  final String packageId;

  const SelectPackageTab({
    required this.tab,
    required this.subscriberId,
    required this.packageId,
  });

  @override
  List<Object?> get props => [tab, subscriberId, packageId];
}

class SelectTargetKind extends SeasonalPlanEvent {
  final String targetKind;
  final String subscriberId;
  final String packageId;

  const SelectTargetKind({
    required this.targetKind,
    required this.subscriberId,
    required this.packageId,
  });

  @override
  List<Object?> get props => [targetKind, subscriberId, packageId];
}

// ============================================================
// PACKAGE LIST
// ============================================================

class LoadSeasonalPackages extends SeasonalPlanEvent {
  final String currentPackageId;
  final String subscriberId;
  final bool reset;
  final String? search;

  const LoadSeasonalPackages({
    required this.currentPackageId,
    required this.subscriberId,
    this.reset = true,
    this.search,
  });

  @override
  List<Object?> get props => [currentPackageId, subscriberId, reset, search];
}

class LoadMoreSeasonalPackages extends SeasonalPlanEvent {
  final String currentPackageId;
  final String subscriberId;

  const LoadMoreSeasonalPackages({
    required this.currentPackageId,
    required this.subscriberId,
  });

  @override
  List<Object?> get props => [currentPackageId, subscriberId];
}

class SearchSeasonalPackages extends SeasonalPlanEvent {
  final String query;
  final String currentPackageId;
  final String subscriberId;

  const SearchSeasonalPackages({
    required this.query,
    required this.currentPackageId,
    required this.subscriberId,
  });

  @override
  List<Object?> get props => [query, currentPackageId, subscriberId];
}

class ApplySeasonalPlanFilters extends SeasonalPlanEvent {
  final String currentPackageId;
  final String subscriberId;
  final String? subscriptionType;
  final String? packageType;

  const ApplySeasonalPlanFilters({
    required this.currentPackageId,
    required this.subscriberId,
    required this.subscriptionType,
    required this.packageType,
  });

  @override
  List<Object?> get props => [
    currentPackageId,
    subscriberId,
    subscriptionType,
    packageType,
  ];
}

class SelectSeasonalPackage extends SeasonalPlanEvent {
  final PackageEntity selectedPackage;

  const SelectSeasonalPackage(this.selectedPackage);

  @override
  List<Object?> get props => [selectedPackage];
}

// ============================================================
// DISCOUNT
// ============================================================

class FetchSeasonalDiscount extends SeasonalPlanEvent {
  final String subscriberUuid;
  final String packageId;
  final String seasonId;

  const FetchSeasonalDiscount({
    required this.subscriberUuid,
    required this.packageId,
    required this.seasonId,
  });

  @override
  List<Object?> get props => [subscriberUuid, packageId, seasonId];
}
