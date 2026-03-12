import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/enquiry_form/source/enquiry_form_api_service.dart';
import 'package:kfon_subscriber/data/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/data/faq/source/faq_api_service.dart';
import 'package:kfon_subscriber/data/sign_up/source/sign_up_api_service.dart';
import 'package:kfon_subscriber/domain/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/features/active_package_details/data/repository/package_details_repository_imp.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/change_plan/data/repository/change_plan_repository_imp.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/data_usage/data/repository/data_usage_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/home/data/repository/home_repository_imp.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/profile/data/repository/profile_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/top_up/data/repository/topup_repository_imp.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/data/repository/transaction_repository_imp.dart';
import 'package:kfon_subscriber/features/tranasactions/domain/repository/transaction_repository.dart';
import 'package:kfon_subscriber/features/ticket/data/repository/ticket_repository_imp.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/data/repository/invoice_repository_imp.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';

import 'features/auth/data/repository/auth_repository_imp.dart';
import 'features/auth/domain/repository/auth_repository.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  sl.registerSingleton<FaqApiService>(FaqApiServiceImp());
  sl.registerSingleton<EnquiryFormApiService>(EnquiryFormApiServiceImp());
  sl.registerSingleton<SignUpApiService>(SignUpApiServiceImp());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());
  sl.registerSingleton<FaqRepository>(FaqRepositoryImp());
  sl.registerSingleton<HomeRepository>(HomeRepositoryImp());
  sl.registerSingleton<DataUsageRepository>(DataUsageRepositoryImp());
  sl.registerSingleton<ChangePlanRepository>(ChangePlanRepositoryImp());
  sl.registerSingleton<TopupRepository>(ToupRepositoryImp());
  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImp());
  sl.registerSingleton<TransactionRepository>(TransactionRepositoryImp());
  sl.registerSingleton<PackageDetailsRepository>(PackageDetailsRepositoryImp());
  sl.registerSingleton<TicketRepository>(TicketRepositoryImp());
  sl.registerSingleton<InvoiceRepository>(InvoiceRepositoryImp());
}
