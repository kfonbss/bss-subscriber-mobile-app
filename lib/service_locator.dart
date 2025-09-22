import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/repository/auth.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/data/enquiry_form/repository/enquiry_form.dart';
import 'package:kfon_subscriber/data/enquiry_form/source/enquiry_form_api_service.dart';
import 'package:kfon_subscriber/data/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/data/faq/source/faq_api_service.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/agnp_enquiry_form_submission_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/bpl_enquiry_form_submission_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/corporate_enquiry_form_submission_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/dark_fibre_enquiry_form_submission_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/download_letter_format_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/lnp_enquiry_form_submission_use_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usecases/subscription_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/domain/faq/usecases/faq_search_use_case.dart';

import 'domain/enquiry_form/usecases/post_office_district_use_case.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  sl.registerSingleton<AuthApiService>(AuthApiServiceImp());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImp());
  sl.registerSingleton<FaqApiService>(FaqApiServiceImp());


  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());
  sl.registerSingleton<FaqRepository>(FaqRepositoryImp());

  sl.registerSingleton<LoginUseCase>(LoginUseCase());

  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());

  sl.registerSingleton<GetOtpUseCase>(GetOtpUseCase());

  sl.registerSingleton<VerifyOtpUseCase>(VerifyOtpUseCase());

  sl.registerSingleton<SetNewPasswordUseCase>(SetNewPasswordUseCase());

  sl.registerSingleton<EnquiryFormApiService>(EnquiryFormApiServiceImp());

  sl.registerSingleton<EnquiryFormRepository>(EnquiryFormRepositoryImp());

  sl.registerSingleton<SubscriptionEnquiryFormSubmissionUserCase>(
    SubscriptionEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<LnpEnquiryFormSubmissionUserCase>(
    LnpEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<PostOfficeDistrictsUserCase>(
    PostOfficeDistrictsUserCase(),
  );
  sl.registerSingleton<AgnpEnquiryFormSubmissionUserCase>(
    AgnpEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<CorporateEnquiryFormSubmissionUserCase>(
    CorporateEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<DarkFibreEnquiryFormSubmissionUserCase>(
    DarkFibreEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<DownloadLetterFormatUserCase>(
    DownloadLetterFormatUserCase(),
  );
  sl.registerSingleton<BplEnquiryFormSubmissionUserCase>(
    BplEnquiryFormSubmissionUserCase(),
  );
  sl.registerSingleton<FaqSearchUseCase>(FaqSearchUseCase());
}
