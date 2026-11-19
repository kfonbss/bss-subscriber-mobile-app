import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/change_plan/data/models/package_new_model.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/paginated_packages_entity.dart';

/// A plan from RailWire's `Subpackagechange`. Speed, validity and data are
/// only inside the name until the API sends them, so the cards show the name
/// and the fee.
class RailwirePlan {
  final String packageId;
  final String packageName;
  final double renewalFee;

  const RailwirePlan({
    required this.packageId,
    required this.packageName,
    required this.renewalFee,
  });

  factory RailwirePlan.fromJson(Map<String, dynamic> json) => RailwirePlan(
    packageId: json['packageid']?.toString().trim() ?? '',
    packageName: json['packagename']?.toString().trim() ?? '',
    renewalFee: RailwireApi.toDouble(json['renewalfee']),
  );

  PackageInfoEntity toPackageInfo() =>
      PackageItemModel.fromJson({
        'id': packageId,
        'packageName': packageName,
        'renewalFee': renewalFee,
      }).toEntity();

  PackageEntity toPackageEntity() => PackageEntity(
    packageId: packageId,
    packageName: packageName,
    price: renewalFee,
    speed: '',
    data: '',
    validity: 0,
    planType: '',
  );
}

/// What changing to a plan would do, from `verifyplanchange`.
class RailwirePlanChangePreview {
  /// The new plan's fee (`tot_details.new_pf`). Whether this is also what the
  /// subscriber pays, given the current balance, is an open question with the
  /// PHP team.
  final double newPlanFee;

  /// Days of validity after the change (`tot_details.tot_days`).
  final int totalDays;

  /// The new end date as the API sends it, e.g. "09-09-2024".
  final String newValidity;

  /// E.g. "Your upgraded package validity would be till :09-09-2024".
  final String message;

  /// The subscriber's current balance (`tot_details.curr_bal`), which
  /// `applyplan_subscirber` pays the change from.
  final double currentBalance;

  const RailwirePlanChangePreview({
    required this.newPlanFee,
    required this.totalDays,
    required this.newValidity,
    required this.message,
    this.currentBalance = 0,
  });

  /// [fallbackFee] (the plan's `renewalfee`) is used when `new_pf` is missing.
  factory RailwirePlanChangePreview.fromJson(
    Map<String, dynamic> json, {
    required double fallbackFee,
  }) {
    final totData = json['tot_data'];
    final details =
        totData is Map<String, dynamic> &&
                totData['tot_details'] is Map<String, dynamic>
            ? totData['tot_details'] as Map<String, dynamic>
            : const <String, dynamic>{};
    final fee = RailwireApi.toDouble(details['new_pf']);
    return RailwirePlanChangePreview(
      newPlanFee: fee > 0 ? fee : fallbackFee,
      totalDays: RailwireApi.toDouble(details['tot_days']).round(),
      newValidity: json['new_validity']?.toString().trim() ?? '',
      message: json['Message']?.toString().trim() ?? '',
      currentBalance: RailwireApi.toDouble(details['curr_bal']),
    );
  }
}

/// The plans the subscriber can change to.
class RailwirePackageChangeModel {
  final List<RailwirePlan> plans;
  final String currentPackageId;

  /// `current_data.sub_status`, which `verifyplanchange` needs.
  final String currentSubStatus;

  const RailwirePackageChangeModel({
    required this.plans,
    required this.currentPackageId,
    this.currentSubStatus = '',
  });

  /// Plans without an id are dropped, and so is the current plan.
  factory RailwirePackageChangeModel.fromJson(Map<String, dynamic> json) {
    final current = json['current_data'];
    final currentData =
        current is Map<String, dynamic> ? current : const <String, dynamic>{};
    final currentId = currentData['packageid']?.toString().trim() ?? '';
    return RailwirePackageChangeModel(
      currentPackageId: currentId,
      currentSubStatus: currentData['sub_status']?.toString().trim() ?? '',
      plans:
          (json['package_list'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(RailwirePlan.fromJson)
              .where((plan) => plan.packageId.isNotEmpty)
              .where((plan) => plan.packageId != currentId)
              .toList(),
    );
  }

  static Future<Either<Failure, RailwirePackageChangeModel>> fetch() async {
    final result = await RailwireApi.post(
      ApiUrls.railwirePackageChangeURL,
      (session) => session.bySubscriberId,
    );
    return result.map(RailwirePackageChangeModel.fromJson);
  }

  /// Previews changing to [plan] with `verifyplanchange`. A failure is the
  /// server refusing the change (or the call failing).
  Future<Either<Failure, RailwirePlanChangePreview>> preview(
    RailwirePlan plan,
  ) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireVerifyPlanChangeURL,
      (session) => {
        ...session.bySubscriberId,
        'oldpkgid': currentPackageId,
        'packageid': plan.packageId,
        'sub_status': currentSubStatus,
      },
    );
    return result.map(
      (data) => RailwirePlanChangePreview.fromJson(
        data,
        fallbackFee: plan.renewalFee,
      ),
    );
  }

  /// Changes the current plan to [packageId] with `applyplan_subscirber`, paid
  /// from the current balance. Returns the API's message.
  Future<Either<Failure, String>> apply(String packageId) async {
    final result = await RailwireApi.post(
      ApiUrls.railwireApplyPlanURL,
      (session) => {
        ...session.bySubscriberId,
        'oldpkgid': currentPackageId,
        'packageid': packageId,
      },
    );
    return result.map((data) => data['Message']?.toString().trim() ?? '');
  }

  /// [plans] whose name contains [search], ignoring case.
  List<RailwirePlan> matching(String? search) {
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return plans;
    return plans
        .where((plan) => plan.packageName.toLowerCase().contains(query))
        .toList();
  }

  /// One page of [plans], for the screens that page through packages.
  static PackageNewEntity packagePage(
    List<RailwirePlan> plans,
    int page,
    int size,
  ) {
    final items = plans.skip(page * size).take(size).toList();
    final totalPages = size <= 0 ? 0 : (plans.length / size).ceil();
    return PackageNewEntity(
      content: items.map((plan) => plan.toPackageInfo()).toList(),
      pageable:
          PageableModel.fromJson({
            'pageNumber': page,
            'pageSize': size,
            'offset': page * size,
            'paged': true,
          }).toEntity(),
      totalElements: plans.length,
      totalPages: totalPages,
      last: page + 1 >= totalPages,
      size: size,
      number: page,
      numberOfElements: items.length,
      first: page == 0,
      empty: items.isEmpty,
    );
  }

  static PaginatedPackagesEntity paginatedPage(
    List<RailwirePlan> plans,
    int page,
    int size,
  ) {
    final totalPages = size <= 0 ? 0 : (plans.length / size).ceil();
    return PaginatedPackagesEntity(
      content:
          plans
              .skip(page * size)
              .take(size)
              .map((plan) => plan.toPackageEntity())
              .toList(),
      totalPages: totalPages,
      totalElements: plans.length,
      last: page + 1 >= totalPages,
      number: page,
      size: size,
    );
  }
}
