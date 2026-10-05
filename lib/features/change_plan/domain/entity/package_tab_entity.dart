class PackageTabEntity {
  final String? subscriberId;
  final String? packageId;
  final String? effectiveStatus;
  final String? reason;
  final EligibilityEntity? addon;
  final EligibilityEntity? standalone;
  final EligibilityEntity? changePackage;
  final EligibilityEntity? upgrade;

  const PackageTabEntity({
    this.subscriberId,
    this.packageId,
    this.effectiveStatus,
    this.reason,
    this.addon,
    this.standalone,
    this.changePackage,
    this.upgrade,
  });
}

class EligibilityEntity {
  final bool? eligible;
  final List<String>? serviceTypes;
  final String? reason;

  const EligibilityEntity({
    this.eligible,
    this.serviceTypes,
    this.reason,
  });
}
