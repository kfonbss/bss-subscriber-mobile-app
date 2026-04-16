import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static String get baseURL => dotenv.env['BASE_URL'] ?? '';
  static const String subscriberManagementService =
      'bss-subscriber-management-service/api';
  static const String packageManagementService =
      'bss-package-management-services/api';

  static const String userRoleMapingService = 'bss-user-role-mapping-services/api';
  static const String coreExternalService = 'bss-core-external-services/api';

  static const String billingFinanceService = 'bss-billing-finance-services/api';
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
  static const String homePageURL =
      '$subscriberManagementService/mobile/subscriber/home';
  static String subscriberDataUsageURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/data-usage';
  static const String listPackagesURL =
      '$packageManagementService/mobile/packages';
  static String changePlanURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/change-plan';
  static const String rechargeChangePlanURL =
      '$billingFinanceService/web/payment/recharge/online';
  static String rechargePaymentStatus({required String orderId}) =>
      '$billingFinanceService/web/payment/recharge/status/$orderId';

  static const String walletTopupURL =
      '$billingFinanceService/mobile/payment/top-up';
  static const String loginURL = '$userRoleMapingService/mobile/login';
  static const String sendOTPURL = '$coreExternalService/otp/send';
  static const String verifyOTPURL = '$coreExternalService/otp/verify';
  static const String sendForgotPasswordOTPURL =
      '$userRoleMapingService/mobile/forgot-password/send-otp';
  static const String verifyForgotPasswordOTPURL =
      '$userRoleMapingService/mobile/forgot-password/verify-otp';
  static const String resetForgotPasswordURL =
      '$userRoleMapingService/mobile/forgot-password/reset';
  static const String refreshTokenURL = '$userRoleMapingService/mobile/refresh';
  static const String logoutURL = '$userRoleMapingService/mobile/logout';
  //profile
  static const String profileURL =
      '$subscriberManagementService/mobile/subscriber/profile';
  static const String accountInformationURL =
      '$subscriberManagementService/mobile/subscriber/account-information';

  //transactions
  static const String rechargeTransactionsURL =
      '$billingFinanceService/mobile/subscriber/recharge-transactions';
  //invoices
  static const String invoicesURL =
      '$subscriberManagementService/mobile/subscriber/invoices';

  static String packageDetailsURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/$subscriberUuid/package-details';
  static String subscriberDetailsURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/details';
  static const String subjectURL = '$userRoleMapingService/mobile/issue-types';
  static const String prioritiesURL = '$userRoleMapingService/mobile/priorities';
  static const String visibilityPermissionURL =
      '$userRoleMapingService/crm/visibility-permission';
  static const String submitTicketURL = '$userRoleMapingService/mobile/tickets';

  static const String addNoteURL = '$userRoleMapingService/mobile/note';
}
