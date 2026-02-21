import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';

class TabPlanState extends Equatable {
  final ListPlanStatus status;
  final List<PackageEntity> packages;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const TabPlanState({
    this.status = ListPlanStatus.initial,
    this.packages = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  TabPlanState copyWith({
    ListPlanStatus? status,
    List<PackageEntity>? packages,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return TabPlanState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    packages,
    currentPage,
    hasMore,
    errorMessage,
  ];
}
