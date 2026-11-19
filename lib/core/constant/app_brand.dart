class AppBrand {
  static bool isLdTenant(String? tenantId) {
    return tenantId?.trim().toUpperCase() == 'LD';
  }

  // Cached current tenant id, kept in sync with AppColor.setTenant.
  static String? _currentTenantId;

  /// Build-time brand: `flutter run --dart-define=BRAND=kfon` (or
  /// `flutter build ... --dart-define=BRAND=kfon`). Anything else, or no
  /// value, builds RailWire.
  static const String brand = String.fromEnvironment(
    'BRAND',
    defaultValue: 'railwire' //'kfon', //'railwire',
  );

  static const bool isKfon = brand == 'kfon';

  /// Tenant id sent for every KFON login / API call (no circle selection).
  static const String kfonTenantId = 'KFON';

  static const String appName = isKfon ? 'KFON' : 'RailWire';

  static void setTenant(String? tenantId) {
    _currentTenantId = tenantId;
  }

  static bool get isRailWire => appName == 'RailWire';

  static bool get isLd => isLdTenant(_currentTenantId);

  /// Whether a tenant has already been chosen (and saved) on this device.
  static bool get hasTenant => (_currentTenantId ?? '').trim().isNotEmpty;
}
