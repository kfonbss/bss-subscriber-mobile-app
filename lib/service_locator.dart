import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/active_package_details/data/repository/package_details_repository_imp.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/auth/data/repository/tenant_repository_impl.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/tenant_repository.dart';
import 'package:kfon_subscriber/features/change_plan/data/repository/change_plan_repository_imp.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/data_usage/data/repository/data_usage_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/home/data/repository/home_repository_imp.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/data/repository/invoice_repository_imp.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/future_recharge/data/repository/future_recharge_repository_imp.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/repository/future_recharge_repository.dart';
import 'package:kfon_subscriber/features/notfication/data/respository/notification_repository_imp.dart';
import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';
import 'package:kfon_subscriber/features/profile/data/repository/profile_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/ticket/data/repository/ticket_repository_imp.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/data/repository/transaction_repository_imp.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';

import 'features/autopay/data/repository/autopay_repository_imp.dart';
import 'features/autopay/domain/repository/autopay_repository.dart';
import 'features/auth/data/repository/auth_repository_imp.dart';
import 'features/auth/domain/repository/auth_repository.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  // DioClient is needed immediately — keep eager
  sl.registerSingleton<DioClient>(DioClient());

  // Repositories — DioClient injected via constructor, not looked up inside methods
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImp());
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImp());
  sl.registerLazySingleton<DataUsageRepository>(() => DataUsageRepositoryImp());
  sl.registerLazySingleton<ChangePlanRepository>(
    () => ChangePlanRepositoryImp(),
  );
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImp());
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImp(),
  );
  sl.registerLazySingleton<PackageDetailsRepository>(
    () => PackageDetailsRepositoryImp(),
  );
  sl.registerSingleton<TicketRepository>(TicketRepositoryImp());
  sl.registerSingleton<FutureRechargeRepository>(FutureRechargeRepositoryImp());
  sl.registerLazySingleton<InvoiceRepository>(() => InvoiceRepositoryImp());
  sl.registerLazySingleton<TenantRepository>(() => TenantRepositoryImpl());
  sl.registerLazySingleton<AutopayRepository>(() => AutopayRepositoryImp());
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
}
