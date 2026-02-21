import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/repository/auth.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/data/enquiry_form/repository/enquiry_form.dart';
import 'package:kfon_subscriber/data/enquiry_form/source/enquiry_form_api_service.dart';
import 'package:kfon_subscriber/data/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/data/faq/source/faq_api_service.dart';
import 'package:kfon_subscriber/data/home/repository/home_repository.dart';
import 'package:kfon_subscriber/data/home/source/home_api_service.dart';
import 'package:kfon_subscriber/data/sign_up/repository/sign_up_repository.dart';
import 'package:kfon_subscriber/data/sign_up/source/sign_up_api_service.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/agnp_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/bpl_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/gov_and_corp_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/dark_fibre_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/download_letter_format_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/lnp_enquiry_form_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/home_enquiry_form_user_case.dart';
import 'package:kfon_subscriber/domain/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/domain/faq/usecases/faq_search_use_case.dart';
import 'package:kfon_subscriber/domain/home/repository/home_repository.dart';
import 'package:kfon_subscriber/domain/home/usecase/home_use_case.dart';
import 'package:kfon_subscriber/domain/sign_up/repository/sign_up.dart';
import 'package:kfon_subscriber/domain/sign_up/usecases/sign_up_get_OTP.dart';
import 'package:kfon_subscriber/domain/sign_up/usecases/sign_up_verify_OTP.dart';
import 'package:kfon_subscriber/features/change_plan/data/repository/change_plan_repository_imp.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/data_usage/data/repository/data_usage_repository_imp.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/profile/data/repository/profile_repository_imp.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/top_up/data/repository/topup_repository_imp.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  sl.registerSingleton<AuthApiService>(AuthApiServiceImp());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImp());
  sl.registerSingleton<FaqApiService>(FaqApiServiceImp());
  sl.registerSingleton<EnquiryFormApiService>(EnquiryFormApiServiceImp());
  sl.registerSingleton<SignUpApiService>(SignUpApiServiceImp());
  sl.registerSingleton<HomeApiService>(HomeApiServiceImp());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());
  sl.registerSingleton<FaqRepository>(FaqRepositoryImp());
  sl.registerSingleton<HomeRepository>(HomeRepositoryImp());
  sl.registerSingleton<DataUsageRepository>(DataUsageRepositoryImp());
  sl.registerSingleton<ChangePlanRepository>(ChangePlanRepositoryImp());
  sl.registerSingleton<TopupRepository>(ToupRepositoryImp());
  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImp());

  sl.registerSingleton<LoginUseCase>(LoginUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
  sl.registerSingleton<GetOtpUseCase>(GetOtpUseCase());
  sl.registerSingleton<VerifyOtpUseCase>(VerifyOtpUseCase());
  sl.registerSingleton<SetNewPasswordUseCase>(SetNewPasswordUseCase());
  sl.registerSingleton<EnquiryFormRepository>(EnquiryFormRepositoryImp());
  sl.registerSingleton<SignUpRepository>(SignUpRepositoryImp());
  sl.registerSingleton<HomeEnquiryFormUseCase>(HomeEnquiryFormUseCase());
  sl.registerSingleton<GovAndCorpEnquiryFormUseCase>(
    GovAndCorpEnquiryFormUseCase(),
  );
  sl.registerSingleton<LnpEnquiryFormUseCase>(LnpEnquiryFormUseCase());
  sl.registerSingleton<AgnpEnquiryFormUseCase>(AgnpEnquiryFormUseCase());
  sl.registerSingleton<DarkFibreEnquiryFormUseCase>(
    DarkFibreEnquiryFormUseCase(),
  );
  sl.registerSingleton<DownloadLetterFormatUseCase>(
    DownloadLetterFormatUseCase(),
  );
  sl.registerSingleton<BplEnquiryFormUseCase>(BplEnquiryFormUseCase());
  sl.registerSingleton<FaqSearchUseCase>(FaqSearchUseCase());
  sl.registerSingleton<SignUpGetOtpUseCase>(SignUpGetOtpUseCase());
  sl.registerSingleton<SignUpVerifyOtpUseCase>(SignUpVerifyOtpUseCase());
  sl.registerSingleton<HomeUseCase>(HomeUseCase());
}
