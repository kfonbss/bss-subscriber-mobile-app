class ApiUrls{
  static const baseURL='https://api.dev.kfonbss.co.in/';
  static String subscriberManagementService =
      'bss-subscriber-management-service/api';
  static String packageManagementService =
      'bss-package-management-services/api';
  static String billingFinanceService = 'bss-billing-finance-services/api';

  static const loginURL='bss-user-role-mapping-services/api/auth/login';
  static const forgotPasswordSendOTPURL='myforgotPasswordSendOTPURL';
  static const forgotPasswordVerifyOTPURL='myforgotVerifyOTPURL';
  static const setNewPasswordURL='bss-user-role-mapping-services/api/auth/forgot-password';
  static const lnpEnquiryFormURL='bss-enquiry-services/api/partner-enquiry/save';
  static const subscriptionEnquiryFormURL='bss-enquiry-services/api/customer-enquiries/save';
  static const agnpEnquiryFormURL='bss-enquiry-services/api/agnp-enquiries/save';
  static const govAndCorpEnquiryFormURL='bss-enquiry-services/api/corporate-enquiries/save';
  static const darkFibreEnquiryFormURL='bss-enquiry-services/api/darkfibre-enquiries/save';
  static const bplEnquiryFormURL='bplEnquiryFormURL';
  static const getPostOfficesDistrictURL='get_post_offices.php';
  static const signUpGetOTPFormURL='signUpGetOTPFormURL';
  static const signUpVerifyOTPFormURL='signUpVerifyOTPFormURL';
  static const homePageURL='homePageURL';
  static String subscriberDataUsageURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/data-usage';
  static String get listPackagesURL =>
      '$packageManagementService/mobile/packages';
  static String changePlanURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/change-plan';
  static String get walletTopupURL =>
      '$billingFinanceService/mobile/payment/top-up';
}