import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/railwire_package_change_model.dart';

void main() {
  final model = RailwirePackageChangeModel.fromJson({
    'status': true,
    'package_list': [
      {
        'packageid': '105052',
        'packagename': '50Mbps Unlimited',
        'renewalfee': '1599.2',
      },
      {
        'packageid': '105044',
        'packagename': '20Mbps Unlimited',
        'renewalfee': '1200',
      },
      {'packageid': '800089', 'packagename': 'Current', 'renewalfee': '472'},
      {'packageid': '', 'packagename': 'No id', 'renewalfee': '1'},
      {
        'packageid': '104979',
        'packagename': 'FUP50Mbps-7Mbps 100GB',
        'renewalfee': '888.8',
      },
    ],
    'current_data': {
      'packageid': '800089',
      'current_package': '20Mbps Unlimited',
      'packagefee': 472,
      'sub_status': '1',
    },
  });

  test('reads the plans, without the current plan or ones without an id', () {
    expect(model.currentPackageId, '800089');
    expect(model.plans.map((p) => p.packageId), ['105052', '105044', '104979']);
    expect(model.plans.first.renewalFee, 1599.2);
  });

  test('search matches the name, ignoring case', () {
    expect(model.matching('unlimited').map((p) => p.packageId), [
      '105052',
      '105044',
    ]);
    expect(model.matching('  '), model.plans);
  });

  test('pages for Home and the Change plan screen', () {
    final home = RailwirePackageChangeModel.packagePage(model.plans, 0, 2);
    expect(home.content.map((p) => p.id), ['105052', '105044']);
    expect(home.content.first.renewalFee, 1599.2);
    expect(home.totalElements, 3);
    expect(home.totalPages, 2);
    expect(home.last, isFalse);

    final screen = RailwirePackageChangeModel.paginatedPage(model.plans, 1, 2);
    expect(screen.content.single.packageId, '104979');
    expect(screen.content.single.price, 888.8);
    expect(screen.last, isTrue);
  });
}
