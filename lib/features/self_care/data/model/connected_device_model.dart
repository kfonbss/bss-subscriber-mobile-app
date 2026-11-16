import 'package:kfon_subscriber/features/self_care/domain/entity/connected_device_entity.dart';

/// One item of `data` in GET `/mobile/subscribers/{subscriberUuid}/connected-devices`.
class ConnectedDeviceModel {
  final String deviceName;
  final String deviceType;
  final String ipAddress;
  final String macAddress;
  final String connectionType;
  final String status;
  final String lastSeen;

  const ConnectedDeviceModel({
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.macAddress,
    required this.connectionType,
    required this.status,
    required this.lastSeen,
  });

  factory ConnectedDeviceModel.fromJson(Map<String, dynamic> json) {
    return ConnectedDeviceModel(
      deviceName: json['deviceName']?.toString() ?? '',
      deviceType: json['deviceType']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
      connectionType: json['connectionType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lastSeen: json['lastSeen']?.toString() ?? '',
    );
  }

  ConnectedDeviceEntity toEntity() => ConnectedDeviceEntity(
    deviceName: deviceName,
    deviceType: deviceType,
    ipAddress: ipAddress,
    macAddress: macAddress,
    connectionType: connectionType,
    status: status,
    lastSeen: lastSeen,
  );

  /// Skips anything that isn't a JSON object instead of failing the list.
  static List<ConnectedDeviceEntity> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((json) => ConnectedDeviceModel.fromJson(json).toEntity())
        .toList();
  }
}
