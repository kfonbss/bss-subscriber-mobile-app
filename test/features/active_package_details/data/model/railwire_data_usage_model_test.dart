import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/active_package_details/data/model/railwire_data_usage_model.dart';

void main() {
  test('reads GB when the response has no unit', () {
    final usage = RailwireDataUsageModel.fromJson({
      'total_alloted': 1000,
      'total_consumed': '250.5',
    });

    expect(usage.totalVolumeGb, 1000);
    expect(usage.availableVolumeGb, 749.5);
  });

  test('converts MB and bytes when the unit is given', () {
    final mb = RailwireDataUsageModel.fromJson({
      'unit': 'MB',
      'total_alloted': 2048,
      'total_consumed': 1024,
    });
    final bytes = RailwireDataUsageModel.fromJson({
      'unit': 'bytes',
      'total_alloted': 1024 * 1024 * 1024,
      'total_consumed': 0,
    });

    expect(mb.totalVolumeGb, 2);
    expect(mb.availableVolumeGb, 1);
    expect(bytes.totalVolumeGb, 1);
  });

  test('remaining data never goes below zero', () {
    final usage = RailwireDataUsageModel.fromJson({
      'total_alloted': 0,
      'total_consumed': 5,
    });

    expect(usage.availableVolumeGb, 0);
  });

  test('missing values read as zero', () {
    final usage = RailwireDataUsageModel.fromJson({'total_alloted': null});

    expect(usage.totalVolumeGb, 0);
    expect(usage.availableVolumeGb, 0);
  });
}
