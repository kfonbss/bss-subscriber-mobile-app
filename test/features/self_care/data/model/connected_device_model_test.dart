import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/self_care/data/model/connected_device_model.dart';

void main() {
  group('ConnectedDeviceModel', () {
    test('maps every field of a device', () {
      final devices = ConnectedDeviceModel.fromJsonList([
        {
          'deviceName': 'Living Room TV',
          'deviceType': 'TV',
          'ipAddress': '192.168.1.10',
          'macAddress': 'AA:BB:CC:DD:EE:FF',
          'connectionType': 'WiFi 5GHz',
          'status': 'ONLINE',
          'lastSeen': '2026-11-16T10:00:00Z',
        },
      ]);

      expect(devices, hasLength(1));
      final d = devices.single;
      expect(d.deviceName, 'Living Room TV');
      expect(d.deviceType, 'TV');
      expect(d.ipAddress, '192.168.1.10');
      expect(d.macAddress, 'AA:BB:CC:DD:EE:FF');
      expect(d.connectionType, 'WiFi 5GHz');
      expect(d.status, 'ONLINE');
      expect(d.lastSeen, '2026-11-16T10:00:00Z');
    });

    test('missing or null fields become empty strings', () {
      final d =
          ConnectedDeviceModel.fromJsonList([
            {'deviceName': null},
          ]).single;

      expect(d.deviceName, '');
      expect(d.status, '');
      expect(d.lastSeen, '');
    });

    test('skips items that are not objects instead of failing', () {
      final devices = ConnectedDeviceModel.fromJsonList([
        {'deviceName': 'Phone'},
        null,
        'garbage',
      ]);

      expect(devices.map((d) => d.deviceName), ['Phone']);
    });
  });
}
