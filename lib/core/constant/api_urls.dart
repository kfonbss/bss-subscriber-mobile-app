import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static String get baseURL => dotenv.env['BASE_URL'] ?? '';
  static const String subscriberManagementService =
      'bss-subscriber-management-service/api';
  static const String packageManagementService =
      'bss-package-management-services/api';

  static const String userRoleMapingService = 'bss-user-role-mapping-services/api';
  static const String coreExternalService = 'bss-core-external-services/api';
  static const String fileStorageService = 'bss-file-storage-services/api/files';
  static const String billingFinanceService = 'bss-billing-finance-services/api';

  static String bssCoreDmdmService =
      'bss-core-dmdm-service/api';
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
  static String get regionsURL => '$bssCoreDmdmService/region/fetch-all';
  static const String customerEnquiryByMobileBase =
      'bss-enquiry-services/api/customer-enquiries/mobile';
  static String customerEnquiryByMobileURL(String mobileNumber) =>
      '$customerEnquiryByMobileBase/$mobileNumber';
  static const getPostOfficesDistrictURL = 'get_post_offices.php';
  static const String homePageURL =
      '$subscriberManagementService/mobile/subscriber/home';
  static String subscriberDataUsageURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/data-usage';
  // static const String listPackagesURL =
  //     '$packageManagementService/mobile/packages';
  static String get packageTabURL =>
      '$billingFinanceService/subscriber-services/assess-eligibility';
  static String get seasonalPreviewPackagesURL =>
      '$billingFinanceService/subscriber-services/list-packages';
  static const String listPackagesURL =
      '$billingFinanceService/rule-engine/packages/seasonal-preview';
  static String changePlanURL({required String subscriberUuid}) =>
      '$subscriberManagementService/mobile/subscribers/$subscriberUuid/change-plan';
  static String invoiceFileURL({required String fileId}) =>
      '$fileStorageService/$fileId/view-url';
  static const String rechargeChangePlanURL =
      '$billingFinanceService/web/payment/recharge/online';
  static String rechargePaymentStatus({required String orderId}) =>
      '$billingFinanceService/web/payment/recharge/status/$orderId';

  static String rechargeSeasonId =
      '$billingFinanceService/rule-engine/packages/seasonal-discount';

  static const String walletTopupURL =
      '$billingFinanceService/mobile/payment/top-up';
  static String get loginURL => '$userRoleMapingService/mobile/login';
  static String get resendOTPURL => '$userRoleMapingService/mobile/login/resend-otp';
  static String get verifyOTPURL => '$userRoleMapingService/mobile/login/verify-otp';
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
  static String get ticketCategoriesURL =>
      '$userRoleMapingService/crm/ticket-categories';
  static String get customerTypesURL =>
      '$userRoleMapingService/crm/customer-types';
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

  static String get subscriberDiscountRuleEngineURL =>
      '$billingFinanceService/rule-engine/packages/subscriber-discount';
  static const String addNoteURL = '$userRoleMapingService/mobile/note';

  /// Rate a ticket (POST `{rating, comment}`).
  /// TODO(rating): placeholder — replace with the real rating endpoint.
  static String rateTicketURL(String ticketUuid) =>
      '$submitTicketURL/$ticketUuid/rating';

  /// File Storage: Get view URL by file ID (GET)
  static String fileViewUrlByFileId(String fileId) =>
      '$fileStorageService/$fileId/view-url';

  /// CRM: Upload a file, returns its file ID (POST multipart `file`).
  /// Used for the GST/PAN documents sent with a create-ticket request.
  static const String fileUploadURL = '$userRoleMapingService/crm/upload';

  /// File Storage: Get download URL by file ID (GET)
  static String fileDownloadUrlByFileId(String fileId) =>
      '$fileStorageService/$fileId/download-url';
  static String get tenantsURL => '$bssCoreDmdmService/region/fetch-all';
  static String get lDTenantsURL => '$bssCoreDmdmService/region/fetch-all';
  static String get furtureRechargesListURL =>
      '$billingFinanceService/mobile/future-recharges';
  static String get paymentGateways =>
      '$bssCoreDmdmService/gateway/fetch-all';

  // UPI Autopay (mandate)
  static const String upiMandateStatus =
      '$billingFinanceService/upi-mandate/status';
  static const String upiMandateQuote =
      '$billingFinanceService/upi-mandate/quote';
  static const String upiMandateInitiate =
      '$billingFinanceService/upi-mandate/initiate';
  static const String upiMandateRevoke =
      '$billingFinanceService/upi-mandate/revoke';
}
