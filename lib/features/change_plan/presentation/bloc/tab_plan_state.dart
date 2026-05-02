import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';

class TabPlanState extends Equatable {
  final ListPlanStatus status;
  final List<PackageItemEntity> packages;
  final int totalPage;
  final bool hasMore;
  final String? errorMessage;

  const TabPlanState({
    this.status = ListPlanStatus.initial,
    this.packages = const [],
    this.totalPage = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  TabPlanState copyWith({
    ListPlanStatus? status,
    List<PackageItemEntity>? packages,
    int? totalPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return TabPlanState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      totalPage: totalPage ?? this.totalPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    packages,
    totalPage,
    hasMore,
    errorMessage,
  ];
}
