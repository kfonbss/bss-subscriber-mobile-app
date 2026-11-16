import 'package:equatable/equatable.dart';

/// A device currently or recently connected to the subscriber's router.
class ConnectedDeviceEntity extends Equatable {
  final String deviceName;
  final String deviceType;
  final String ipAddress;
  final String macAddress;
  final String connectionType;
  final String status;
  final String lastSeen;

  const ConnectedDeviceEntity({
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.macAddress,
    required this.connectionType,
    required this.status,
    required this.lastSeen,
  });

  @override
  List<Object?> get props => [
    deviceName,
    deviceType,
    ipAddress,
    macAddress,
    connectionType,
    status,
    lastSeen,
  ];
}
