
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_tab_entity.dart';

class PackageTabModel extends PackageTabEntity {
  const PackageTabModel({
    super.subscriberId,
    super.packageId,
    super.effectiveStatus,
    super.reason,
    super.addon,
    super.standalone,
    super.changePackage,
    super.upgrade,
  });

  factory PackageTabModel.fromJson(Map<String, dynamic> json) {
    return PackageTabModel(
      subscriberId: json['subscriberId'] as String?,
      packageId: json['packageId'] as String?,
      effectiveStatus: json['effectiveStatus'] as String?,
      reason: json['reason'] as String?,
      changePackage: json['changePackage'] != null
          ? EligibilityModel.fromJson(json['changePackage'], true)
          : null,
      upgrade: json['upgrade'] != null
          ? EligibilityModel.fromJson(json['upgrade'], false)
          : null,
      standalone: json['standalone'] != null
          ? EligibilityModel.fromJson(json['standalone'], false)
          : null,
      addon: json['addon'] != null
          ? EligibilityModel.fromJson(json['addon'], false)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriberId': subscriberId,
      'packageId': packageId,
      'effectiveStatus': effectiveStatus,
      'reason': reason,
      'addon': addon != null ? (addon as EligibilityModel).toJson() : null,
      'standalone': standalone != null
          ? (standalone as EligibilityModel).toJson()
          : null,
      'changePackage': changePackage != null
          ? (changePackage as EligibilityModel).toJson()
          : null,
      'upgrade': upgrade != null
          ? (upgrade as EligibilityModel).toJson()
          : null,
    };
  }

  PackageTabEntity toEntity() {
    return PackageTabEntity(
      subscriberId: subscriberId ?? '',
      packageId: packageId ?? '',
      effectiveStatus: effectiveStatus ?? '',
      reason: reason ?? '',
      addon: addon,
      standalone: standalone,
      changePackage: changePackage,
      upgrade: upgrade,
    );
  }
}
class EligibilityModel extends EligibilityEntity {
  const EligibilityModel({
    super.eligible,
    super.serviceTypes,
    super.reason,
  });

  factory EligibilityModel.fromJson(
      Map<String, dynamic> json,
      bool isChangePackage,
      ) {
    final isEligible = json['eligible'] as bool? ?? false;

    return EligibilityModel(
      eligible: isEligible,
      serviceTypes: json['serviceTypes'] != null
          ? List<String>.from(json['serviceTypes'])
          : isChangePackage && isEligible
          ? ['INTERNET_ONLY', 'BUNDLE']
          : null,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'serviceTypes': serviceTypes,
      'reason': reason,
    };
  }

  EligibilityEntity toEntity() {
    return EligibilityEntity(
      eligible: eligible ?? false,
      serviceTypes: serviceTypes ?? [],
      reason: reason ?? '',
    );
  }
}