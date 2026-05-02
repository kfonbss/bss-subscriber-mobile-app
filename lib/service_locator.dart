import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/active_package_details/data/repository/package_details_repository_imp.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/change_plan/data/repository/change_plan_repository_imp.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/data_usage/data/repository/data_usage_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/repository/enquiry_forms_imp.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:kfon_subscriber/features/home/data/repository/home_repository_imp.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/data/repository/invoice_repository_imp.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/offline_recharge/data/repository/offline_recharge_repository_imp.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/repository/offline_recharge_repository.dart';
import 'package:kfon_subscriber/features/profile/data/repository/profile_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/ticket/data/repository/ticket_repository_imp.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/top_up/data/repository/topup_repository_imp.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/data/repository/transaction_repository_imp.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';

import 'features/auth/data/repository/auth_repository_imp.dart';
import 'features/auth/domain/repository/auth_repository.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  // DioClient is needed immediately — keep eager
  sl.registerSingleton<DioClient>(DioClient());

  // Repositories — DioClient injected via constructor, not looked up inside methods
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<EnquiryFormRepository>(
    () => EnquiryFormRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<DataUsageRepository>(
    () => DataUsageRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<ChangePlanRepository>(
    () => ChangePlanRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<TopupRepository>(
    () => ToupRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<PackageDetailsRepository>(
    () => PackageDetailsRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerSingleton<TicketRepository>(TicketRepositoryImp());
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImp(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<OfflineRechargeRepository>(
    () => OfflineRechargeRepositoryImp(client: sl<DioClient>()),
  );
}
