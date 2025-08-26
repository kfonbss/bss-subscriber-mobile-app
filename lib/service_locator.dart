import 'package:get_it/get_it.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/repository/auth.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_api_service.dart';
import 'package:kfon_subscriber/data/auth/sources/auth_local_service.dart';
import 'package:kfon_subscriber/data/enquiry_form/repository/enquiry_form.dart';
import 'package:kfon_subscriber/data/enquiry_form/source/enquiry_form_api_service.dart';
import 'package:kfon_subscriber/domain/auth/repository/auth.dart';
import 'package:kfon_subscriber/domain/auth/usecases/get_OTP.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/domain/auth/usecases/login.dart';
import 'package:kfon_subscriber/domain/auth/usecases/set_new_password.dart';
import 'package:kfon_subscriber/domain/auth/usecases/verify_otp.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/agnp_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/bpl_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/corporate_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/dark_fibre_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/download_letter_format_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/lnp_enquiry_form_submission_user_case.dart';
import 'package:kfon_subscriber/domain/enquiry_form/usercases/subscription_enquiry_form_submission_user_case.dart';

import 'domain/enquiry_form/usercases/post_office_district_user_case.dart';

final sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  sl.registerSingleton<AuthApiService>(AuthApiServiceImp());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImp());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImp());

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
}
