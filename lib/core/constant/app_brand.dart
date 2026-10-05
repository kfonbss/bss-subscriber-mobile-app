class AppBrand {
  static bool isLdTenant(String? tenantId) {
    return tenantId?.trim().toUpperCase() == 'LD';
  }

  // Cached current tenant id, kept in sync with AppColor.setTenant.
  static String? _currentTenantId;
  static const String appName = 'RailWire';

  static void setTenant(String? tenantId) {
    _currentTenantId = tenantId;
  }

  static bool get isLd => isLdTenant(_currentTenantId);

  /// Whether a tenant has already been chosen (and saved) on this device.
  static bool get hasTenant => (_currentTenantId ?? '').trim().isNotEmpty;
}
