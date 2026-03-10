import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static String get baseURL => dotenv.env['BASE_URL'] ?? '';
  static String subscriberManagementService =
      'bss-subscriber-management-service/api';
  static String packageManagementService =
      'bss-package-management-services/api';

  static String userRoleMapingService = 'bss-user-role-mapping-services/api';
  static String coreExternalService = 'bss-core-external-services/api';

  static String billingFinanceService = 'bss-billing-finance-services/api';
  static const forgotPasswordSendOTPURL = 'myforgotPasswordSendOTPURL';
  static const forgotPasswordVerifyOTPURL = 'myforgotVerifyOTPURL';
  static const setNewPasswordURL =
      'bss-user-role-mapping-services/api/auth/forgot-password';
  static const lnpEnquiryFormURL =
      'bss-enquiry-services/api/partner-enquiry/save';
  static const subscriptionEnquiryFormURL =
      'bss-enquiry-services/api/customer-enquiries/save';
  static const agnpEnquiryFormURL =
      'bss-enquiry-services/api/agnp-enquiries/save';
  static const govAndCorpEnquiryFormURL =
      'bss-enquiry-services/api/corporate-enquiries/save';
  static const darkFibreEnquiryFormURL =
      'bss-enquiry-services/api/darkfibre-enquiries/save';
  static const bplEnquiryFormURL = 'bplEnquiryFormURL';
  static const getPostOfficesDistrictURL = 'get_post_offices.php';
  static const signUpGetOTPFormURL = 'signUpGetOTPFormURL';
  static const signUpVerifyOTPFormURL = 'signUpVerifyOTPFormURL';
  static String homePageURL = '$subscriberManagementService/mobile/subscriber/home';
  static String subscriberDataUsageURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/data-usage';
  static String get listPackagesURL =>
      '$packageManagementService/mobile/packages';
  static String changePlanURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/change-plan';
  static String get walletTopupURL =>
      '$billingFinanceService/mobile/payment/top-up';
  static String get loginURL => '$userRoleMapingService/mobile/login';
  static String get sendOTPURL => '$coreExternalService/otp/send';
  static String get verifyOTPURL => '$coreExternalService/otp/verify';
  static String get sendForgotPasswordOTPURL =>
      '$userRoleMapingService/mobile/forgot-password/send-otp';
  static String get verifyForgotPasswordOTPURL =>
      '$userRoleMapingService/mobile/forgot-password/verify-otp';
  static String get resetForgotPasswordURL =>
      '$userRoleMapingService/mobile/forgot-password/reset';
  static String get refreshTokenURL => '$userRoleMapingService/mobile/refresh';
  static String get logoutURL => '$userRoleMapingService/mobile/logout';
  //profile
  static String get profileURL =>
      '$subscriberManagementService/mobile/subscriber/profile';
  static String get accountInformationURL =>
      '$subscriberManagementService/mobile/subscriber/account-information';

  //transactions
  static String get rechargeTransactionsURL =>
      '$billingFinanceService/mobile/subscriber/recharge-transactions';

  static String packageDetailsURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/$subscriberUuid/package-details';
  static String get subjectURL => '$userRoleMapingService/mobile/issue-types';
  static String get prioritiesURL => '$userRoleMapingService/mobile/priorities';
  static String get visibilityPermissionURL =>
      '$userRoleMapingService/crm/visibility-permission';
  static String get submitTicketURL => '$userRoleMapingService/mobile/tickets';

  static String get addNoteURL => '$userRoleMapingService/mobile/note';
}
