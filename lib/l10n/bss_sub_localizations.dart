import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'bss_sub_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BssSubLocalizations
/// returned by `BssSubLocalizations.of(context)`.
///
/// Applications need to include `BssSubLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/bss_sub_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BssSubLocalizations.localizationsDelegates,
///   supportedLocales: BssSubLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the BssSubLocalizations.supportedLocales
/// property.
abstract class BssSubLocalizations {
  BssSubLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BssSubLocalizations? of(BuildContext context) {
    return Localizations.of<BssSubLocalizations>(context, BssSubLocalizations);
  }

  static const LocalizationsDelegate<BssSubLocalizations> delegate =
      _BssSubLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @welcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KFON'**
  String get welcomeLabel;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We have sent you 6 digits verification code to \n {mobileNumber}'**
  String otpSentMessage(Object mobileNumber);

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @willReturnToLoginScreen.
  ///
  /// In en, this message translates to:
  /// **'This will return you to the log in screen.'**
  String get willReturnToLoginScreen;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @stayConnectedAlways.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected, Always'**
  String get stayConnectedAlways;

  /// No description provided for @experienceLightningFast.
  ///
  /// In en, this message translates to:
  /// **'Experience lightning-fast internet with KFON\'s reliable fiber network, keeping you online anytime, anywhere.'**
  String get experienceLightningFast;

  /// No description provided for @bridgingDigitalDivide.
  ///
  /// In en, this message translates to:
  /// **'Bridging the Digital Divide'**
  String get bridgingDigitalDivide;

  /// No description provided for @kfonEmpowersCitizen.
  ///
  /// In en, this message translates to:
  /// **'KFON empowers every citizen with affordable internet, supporting education, business, and government services.'**
  String get kfonEmpowersCitizen;

  /// No description provided for @internetWorksForYou.
  ///
  /// In en, this message translates to:
  /// **'Internet That Works for You'**
  String get internetWorksForYou;

  /// No description provided for @enjoyHighSpeed.
  ///
  /// In en, this message translates to:
  /// **'Enjoy high-speed, secure, and cost-effective internet designed for every household and business.'**
  String get enjoyHighSpeed;

  /// No description provided for @welcomeToKfon.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KFON'**
  String get welcomeToKfon;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @selectSubjectKey.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get selectSubjectKey;

  /// No description provided for @resolvedIn.
  ///
  /// In en, this message translates to:
  /// **'Resolved in {time}'**
  String resolvedIn(String time);

  /// No description provided for @selectPriorityKey.
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get selectPriorityKey;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @ticketCategory.
  ///
  /// In en, this message translates to:
  /// **'Ticket Category'**
  String get ticketCategory;

  /// No description provided for @fileSizeMustBeLess.
  ///
  /// In en, this message translates to:
  /// **'File size must be less than 5MB'**
  String get fileSizeMustBeLess;

  /// No description provided for @pleaseAttachDocument.
  ///
  /// In en, this message translates to:
  /// **'Please attach at least one document'**
  String get pleaseAttachDocument;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @ticketFileInstructions.
  ///
  /// In en, this message translates to:
  /// **'*Please upload files in the following format :\nGIF, JPG, JPEG, PNG, PDF, MP4. The maximum allowed file\nsize is 5MB.'**
  String get ticketFileInstructions;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @enquiryForms.
  ///
  /// In en, this message translates to:
  /// **'Enquiry Forms'**
  String get enquiryForms;

  /// No description provided for @kerlaInternetWebsite.
  ///
  /// In en, this message translates to:
  /// **'www.kerlainternet.com'**
  String get kerlaInternetWebsite;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your registered username to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @ticketIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID copied to clipboard'**
  String get ticketIdCopied;

  /// No description provided for @getOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Confirm Password'**
  String get enterConfirmPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @otpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccessfully;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyYourAccount;

  /// No description provided for @weHaveSentOtpTo.
  ///
  /// In en, this message translates to:
  /// **'We have sent you 6 digits verification code to {mobileNumber}'**
  String weHaveSentOtpTo(String mobileNumber);

  /// No description provided for @yourTicketHasBeenCreated.
  ///
  /// In en, this message translates to:
  /// **'Your ticket has been created successfully!'**
  String get yourTicketHasBeenCreated;

  /// No description provided for @ourSupportTeamWillGetBack.
  ///
  /// In en, this message translates to:
  /// **'Our support team will get back to you shortly'**
  String get ourSupportTeamWillGetBack;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success  🎉'**
  String get success;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get recharge;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @updatedDate.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String updatedDate(String date);

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @activeUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String activeUntilDate(String date);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} Days left'**
  String daysLeft(String days);

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @fpu.
  ///
  /// In en, this message translates to:
  /// **'FPU'**
  String get fpu;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @packsActive.
  ///
  /// In en, this message translates to:
  /// **'+{count} Pack Active'**
  String packsActive(String count);

  /// No description provided for @viewUsage.
  ///
  /// In en, this message translates to:
  /// **'View Usage'**
  String get viewUsage;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @planChange.
  ///
  /// In en, this message translates to:
  /// **'Plan Change'**
  String get planChange;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @validity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get choosePlan;

  /// No description provided for @fiberToHome.
  ///
  /// In en, this message translates to:
  /// **'Fiber to Home\n(FTTH)'**
  String get fiberToHome;

  /// No description provided for @internetLeasedLine.
  ///
  /// In en, this message translates to:
  /// **'Internet Leased\nline (IIL)'**
  String get internetLeasedLine;

  /// No description provided for @darkFiber.
  ///
  /// In en, this message translates to:
  /// **'Dark Fiber for\nLeased (DFL)'**
  String get darkFiber;

  /// No description provided for @coLocation.
  ///
  /// In en, this message translates to:
  /// **'Co-Location'**
  String get coLocation;

  /// No description provided for @wifiServices.
  ///
  /// In en, this message translates to:
  /// **'WiFi Services'**
  String get wifiServices;

  /// No description provided for @ott.
  ///
  /// In en, this message translates to:
  /// **'Over-the-Top\n(OTT)'**
  String get ott;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @activePackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Package'**
  String get activePackageTitle;

  /// No description provided for @activeAddOns.
  ///
  /// In en, this message translates to:
  /// **'Active Add-ons'**
  String get activeAddOns;

  /// No description provided for @addonServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'+{serviceTypeName}   ₹{amount}'**
  String addonServiceTitle(String serviceTypeName, double amount);

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @sessionInformation.
  ///
  /// In en, this message translates to:
  /// **'Session Information'**
  String get sessionInformation;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsage;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @valueInMb.
  ///
  /// In en, this message translates to:
  /// **'{value} MB'**
  String valueInMb(String value);

  /// No description provided for @networkDetails.
  ///
  /// In en, this message translates to:
  /// **'Network Details'**
  String get networkDetails;

  /// No description provided for @mac.
  ///
  /// In en, this message translates to:
  /// **'MAC'**
  String get mac;

  /// No description provided for @framedIp.
  ///
  /// In en, this message translates to:
  /// **'Framed-IP'**
  String get framedIp;

  /// No description provided for @framedIpv6Prefix.
  ///
  /// In en, this message translates to:
  /// **'Framed-IPv6 Prefix'**
  String get framedIpv6Prefix;

  /// No description provided for @framedIpv6Delegated.
  ///
  /// In en, this message translates to:
  /// **'Framed-IPv6 Delegated'**
  String get framedIpv6Delegated;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @valueInGb.
  ///
  /// In en, this message translates to:
  /// **'{value} GB'**
  String valueInGb(String value);

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistory;

  /// No description provided for @durationValue.
  ///
  /// In en, this message translates to:
  /// **'Duration : {duration}'**
  String durationValue(String duration);

  /// No description provided for @totalValueMb.
  ///
  /// In en, this message translates to:
  /// **'Total : {totalMb} MB'**
  String totalValueMb(String totalMb);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @restartModem.
  ///
  /// In en, this message translates to:
  /// **'Restart Modem'**
  String get restartModem;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @modemRestartedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Modem Restarted Successfully!'**
  String get modemRestartedSuccessfully;

  /// No description provided for @modemRestartedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your modem has been restarted. Connection restored and ready to use.'**
  String get modemRestartedDescription;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @restartFailed.
  ///
  /// In en, this message translates to:
  /// **'Restart Failed'**
  String get restartFailed;

  /// No description provided for @restartFailedDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restart your modem. Please try again or contact support.'**
  String get restartFailedDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @restartYourModem.
  ///
  /// In en, this message translates to:
  /// **'Restart Your Modem'**
  String get restartYourModem;

  /// No description provided for @restartYourModemDescription.
  ///
  /// In en, this message translates to:
  /// **'Restarting your modem helps fix connection issues and improve performance.\nThis will take about 2-3 minutes.'**
  String get restartYourModemDescription;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get restartNow;

  /// No description provided for @restartingModem.
  ///
  /// In en, this message translates to:
  /// **'Restarting Modem'**
  String get restartingModem;

  /// No description provided for @restartingModemDescription.
  ///
  /// In en, this message translates to:
  /// **'Restarting your modem... please wait.'**
  String get restartingModemDescription;

  /// No description provided for @restartingDots.
  ///
  /// In en, this message translates to:
  /// **'Restarting.....'**
  String get restartingDots;

  /// No description provided for @rechargeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recharge Success'**
  String get rechargeSuccess;

  /// No description provided for @lastPaid.
  ///
  /// In en, this message translates to:
  /// **'Last Paid'**
  String get lastPaid;

  /// No description provided for @rechargeCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Recharge Count'**
  String get rechargeCountLabel;

  /// No description provided for @rechargeCountTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} Times'**
  String rechargeCountTimes(String count);

  /// No description provided for @lastPlan.
  ///
  /// In en, this message translates to:
  /// **'Last Plan'**
  String get lastPlan;

  /// No description provided for @topupTo.
  ///
  /// In en, this message translates to:
  /// **'Topup To'**
  String get topupTo;

  /// No description provided for @topupAmount.
  ///
  /// In en, this message translates to:
  /// **'Topup Amount'**
  String get topupAmount;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get accountBalance;

  /// No description provided for @topupMessage.
  ///
  /// In en, this message translates to:
  /// **'Topup Message'**
  String get topupMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @rechargeCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your recharge has been completed Successfully'**
  String get rechargeCompletedSuccessfully;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetailsTitle;

  /// No description provided for @orderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Time'**
  String get orderTime;

  /// No description provided for @orderAmount.
  ///
  /// In en, this message translates to:
  /// **'Order Amount'**
  String get orderAmount;

  /// No description provided for @bssReference.
  ///
  /// In en, this message translates to:
  /// **'BSS Reference'**
  String get bssReference;

  /// No description provided for @bssStatus.
  ///
  /// In en, this message translates to:
  /// **'BSS Status'**
  String get bssStatus;

  /// No description provided for @txnReference.
  ///
  /// In en, this message translates to:
  /// **'Txn. Reference'**
  String get txnReference;

  /// No description provided for @responseMessage.
  ///
  /// In en, this message translates to:
  /// **'Response Message   '**
  String get responseMessage;

  /// No description provided for @paymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway'**
  String get paymentGateway;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @bssNo.
  ///
  /// In en, this message translates to:
  /// **'BSS No'**
  String get bssNo;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @expireDate.
  ///
  /// In en, this message translates to:
  /// **'Expire Date'**
  String get expireDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid On'**
  String get paidOn;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid By'**
  String get paidBy;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @faqSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get faqSectionAccount;

  /// No description provided for @faqSectionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get faqSectionPayments;

  /// No description provided for @faqAccountQ1.
  ///
  /// In en, this message translates to:
  /// **'How can I pay my bill online?'**
  String get faqAccountQ1;

  /// No description provided for @faqAccountA1.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Wallet / Payments\" → Choose payment method → Proceed to Pay.'**
  String get faqAccountA1;

  /// No description provided for @faqAccountQ2.
  ///
  /// In en, this message translates to:
  /// **'What payment modes are accepted?'**
  String get faqAccountQ2;

  /// No description provided for @faqAccountA2.
  ///
  /// In en, this message translates to:
  /// **'We accept various payment methods including credit cards, debit cards, UPI, and net banking.'**
  String get faqAccountA2;

  /// No description provided for @faqAccountQ3.
  ///
  /// In en, this message translates to:
  /// **'My internet speed is slow. What should I do?'**
  String get faqAccountQ3;

  /// No description provided for @faqAccountA3.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection, restart your router, or contact our support team for assistance.'**
  String get faqAccountA3;

  /// No description provided for @faqPaymentsQ1.
  ///
  /// In en, this message translates to:
  /// **'How can I pay my bill online?'**
  String get faqPaymentsQ1;

  /// No description provided for @faqPaymentsA1.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Wallet / Payments\" → Choose payment method → Proceed to Pay.'**
  String get faqPaymentsA1;

  /// No description provided for @faqPaymentsQ2.
  ///
  /// In en, this message translates to:
  /// **'What payment modes are accepted?'**
  String get faqPaymentsQ2;

  /// No description provided for @faqPaymentsA2.
  ///
  /// In en, this message translates to:
  /// **'We accept various payment methods including credit cards, debit cards, UPI, and net banking.'**
  String get faqPaymentsA2;

  /// No description provided for @faqPaymentsQ3.
  ///
  /// In en, this message translates to:
  /// **'My internet speed is slow. What should I do?'**
  String get faqPaymentsQ3;

  /// No description provided for @faqPaymentsA3.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection, restart your router, or contact our support team for assistance.'**
  String get faqPaymentsA3;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @promoAndOffer.
  ///
  /// In en, this message translates to:
  /// **'Promo & Offer'**
  String get promoAndOffer;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @accountVerification.
  ///
  /// In en, this message translates to:
  /// **'Account Verification'**
  String get accountVerification;

  /// No description provided for @accountVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please verify your account to gift an package to your friend.'**
  String get accountVerificationMessage;

  /// No description provided for @bestDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Best Deal Unlimited Call! 🥰'**
  String get bestDealTitle;

  /// No description provided for @bestDealMessage.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out on this incredible deal! We\'re excited to offer you unlimited calling to any operator, 24 hours a day. That\'s right, you can chat with your loved ones or colleagues anytime you want without worrying about time or cost limitations.'**
  String get bestDealMessage;

  /// No description provided for @getItNow.
  ///
  /// In en, this message translates to:
  /// **'Get it Now'**
  String get getItNow;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with Us'**
  String get chatWithUs;

  /// No description provided for @chatwithAI.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get chatwithAI;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @aboutKfon.
  ///
  /// In en, this message translates to:
  /// **'About Kfon'**
  String get aboutKfon;

  /// No description provided for @kfon.
  ///
  /// In en, this message translates to:
  /// **'KFON'**
  String get kfon;

  /// No description provided for @kfonDescription.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting'**
  String get kfonDescription;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @missionDescription.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting'**
  String get missionDescription;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting'**
  String get achievementsDescription;

  /// No description provided for @appUpdateCheck.
  ///
  /// In en, this message translates to:
  /// **'App Update Check'**
  String get appUpdateCheck;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get currentVersion;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get upToDate;

  /// No description provided for @noNewUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No new updates available'**
  String get noNewUpdatesAvailable;

  /// No description provided for @appIsUpToDateMessage.
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date. We will notify you when a new version is avaliable.'**
  String get appIsUpToDateMessage;

  /// No description provided for @checkForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check For Update'**
  String get checkForUpdate;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @changeBssPortalPassword.
  ///
  /// In en, this message translates to:
  /// **'Change BSS Portal Password'**
  String get changeBssPortalPassword;

  /// No description provided for @changeInternetPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Internet Password'**
  String get changeInternetPassword;

  /// No description provided for @changeSsidPassword.
  ///
  /// In en, this message translates to:
  /// **'Change SSID Password'**
  String get changeSsidPassword;

  /// No description provided for @changeWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Change WiFi Password'**
  String get changeWifiPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @enterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @forgotPasswordLower.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordLower;

  /// No description provided for @passwordUpdatedSuccessfullyTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Updated\n Successfully 🎉'**
  String get passwordUpdatedSuccessfullyTitle;

  /// No description provided for @passwordUpdatedSuccessfullyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed. You\'ll be redirected to Security Settings.'**
  String get passwordUpdatedSuccessfullyDescription;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search language'**
  String get searchLanguage;

  /// No description provided for @languageChoice.
  ///
  /// In en, this message translates to:
  /// **'Language Choice'**
  String get languageChoice;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications Settings'**
  String get notificationsSettings;

  /// No description provided for @aboutKfonTitle.
  ///
  /// In en, this message translates to:
  /// **'About KFON'**
  String get aboutKfonTitle;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @subscriberId.
  ///
  /// In en, this message translates to:
  /// **'Subscriber ID'**
  String get subscriberId;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @mobileNo.
  ///
  /// In en, this message translates to:
  /// **'Mobile No.'**
  String get mobileNo;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @kycIdProof.
  ///
  /// In en, this message translates to:
  /// **'KYC/ID Proof'**
  String get kycIdProof;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get onlineStatus;

  /// No description provided for @taxInformation.
  ///
  /// In en, this message translates to:
  /// **'Tax Information'**
  String get taxInformation;

  /// No description provided for @pan.
  ///
  /// In en, this message translates to:
  /// **'PAN'**
  String get pan;

  /// No description provided for @gst.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get gst;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @lnpContactDetails.
  ///
  /// In en, this message translates to:
  /// **'LNP Contact Details'**
  String get lnpContactDetails;

  /// No description provided for @lnpName.
  ///
  /// In en, this message translates to:
  /// **'LNP Name'**
  String get lnpName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @lnpAddress.
  ///
  /// In en, this message translates to:
  /// **'LNP Address'**
  String get lnpAddress;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'This will return you to the log in screen.'**
  String get logoutConfirmDescription;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID : {id}'**
  String idLabel(String id);

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'last sync: {time}'**
  String lastSync(String time);

  /// No description provided for @selfCareTools.
  ///
  /// In en, this message translates to:
  /// **'Self-Care/Tools'**
  String get selfCareTools;

  /// No description provided for @restartModemRefreshConnection.
  ///
  /// In en, this message translates to:
  /// **'Restart Modem/Refresh Connection'**
  String get restartModemRefreshConnection;

  /// No description provided for @networkHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Network Health Check'**
  String get networkHealthCheck;

  /// No description provided for @pingSpeedTest.
  ///
  /// In en, this message translates to:
  /// **'Ping / Speed Test'**
  String get pingSpeedTest;

  /// No description provided for @manageYourConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage your connected devices'**
  String get manageYourConnectedDevices;

  /// No description provided for @changeSsidWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Change SSID / Wi-Fi Password'**
  String get changeSsidWifiPassword;

  /// No description provided for @speedTest.
  ///
  /// In en, this message translates to:
  /// **'Speed Test'**
  String get speedTest;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @uploadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadSpeed;

  /// No description provided for @downloadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadSpeed;

  /// No description provided for @ping.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get ping;

  /// No description provided for @startSpeedTest.
  ///
  /// In en, this message translates to:
  /// **'Start Speed Test'**
  String get startSpeedTest;

  /// No description provided for @selectPriority.
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get selectPriority;

  /// No description provided for @errorLoadingPriorities.
  ///
  /// In en, this message translates to:
  /// **'Error loading priorities'**
  String get errorLoadingPriorities;

  /// No description provided for @noPrioritiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No priorities available'**
  String get noPrioritiesAvailable;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select subject'**
  String get selectSubject;

  /// No description provided for @selectSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get selectSubjectHint;

  /// No description provided for @errorLoadingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Error loading subjects'**
  String get errorLoadingSubjects;

  /// No description provided for @noMatchingItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching items found'**
  String get noMatchingItemsFound;

  /// No description provided for @noSubjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subjects available'**
  String get noSubjectsAvailable;

  /// No description provided for @selectSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Select Subscriber'**
  String get selectSubscriber;

  /// No description provided for @searchSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Search Subscriber'**
  String get searchSubscriber;

  /// No description provided for @noSubscribersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subscribers available'**
  String get noSubscribersAvailable;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @visibilityPermission.
  ///
  /// In en, this message translates to:
  /// **'Visibility Permission'**
  String get visibilityPermission;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @enterYourNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your note here...'**
  String get enterYourNoteHere;

  /// No description provided for @remarksMustBeAtLeast10Characters.
  ///
  /// In en, this message translates to:
  /// **'Remarks must be at least 10 characters'**
  String get remarksMustBeAtLeast10Characters;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success  🎉'**
  String get successTitle;

  /// No description provided for @ticketCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your ticket has been created successfully!'**
  String get ticketCreatedSuccessfully;

  /// No description provided for @supportTeamWillGetBack.
  ///
  /// In en, this message translates to:
  /// **'Our support team will get back to you shortly'**
  String get supportTeamWillGetBack;

  /// No description provided for @ticketIdCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID copied to clipboard'**
  String get ticketIdCopiedToClipboard;

  /// No description provided for @returnToHomepage.
  ///
  /// In en, this message translates to:
  /// **'Return to Homepage'**
  String get returnToHomepage;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @ticketCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket Category *'**
  String get ticketCategoryLabel;

  /// No description provided for @complaintRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complaint Registration'**
  String get complaintRegistration;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @selectSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Subject *'**
  String get selectSubjectLabel;

  /// No description provided for @selectSubjectHintText.
  ///
  /// In en, this message translates to:
  /// **'Select subject'**
  String get selectSubjectHintText;

  /// No description provided for @selectPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Priority *'**
  String get selectPriorityLabel;

  /// No description provided for @selectPriorityHintText.
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get selectPriorityHintText;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @remarksHint.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarksHint;

  /// No description provided for @attachmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments *'**
  String get attachmentsLabel;

  /// No description provided for @pleaseAttachAtLeastOneDocument.
  ///
  /// In en, this message translates to:
  /// **'Please attach at least one document'**
  String get pleaseAttachAtLeastOneDocument;

  /// No description provided for @fileFormatInstructions.
  ///
  /// In en, this message translates to:
  /// **'*Please upload files in the following format :\nGIF, JPG, JPEG, PNG, PDF, MP4. The maximum allowed file\nsize is 5MB.'**
  String get fileFormatInstructions;

  /// No description provided for @fileSizeMustBeLessThan5MB.
  ///
  /// In en, this message translates to:
  /// **'File size must be less than 5MB'**
  String get fileSizeMustBeLessThan5MB;

  /// No description provided for @errorPickingFile.
  ///
  /// In en, this message translates to:
  /// **'Error picking file: {error}'**
  String errorPickingFile(String error);

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @ticketIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID #{ticketId}'**
  String ticketIdTitle(String ticketId);

  /// No description provided for @noSubject.
  ///
  /// In en, this message translates to:
  /// **'No Subject'**
  String get noSubject;

  /// No description provided for @noteSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully'**
  String get noteSavedSuccessfully;

  /// No description provided for @routerImage.
  ///
  /// In en, this message translates to:
  /// **'Router Image'**
  String get routerImage;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @youSender.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youSender;

  /// No description provided for @supportSender.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSender;

  /// No description provided for @searchTickets.
  ///
  /// In en, this message translates to:
  /// **'Search Tickets'**
  String get searchTickets;

  /// No description provided for @noTickets.
  ///
  /// In en, this message translates to:
  /// **'No Tickets'**
  String get noTickets;

  /// No description provided for @ticketIdFormat.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID #{id}'**
  String ticketIdFormat(String id);

  /// No description provided for @ticketIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID #--'**
  String get ticketIdEmpty;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @priorityInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get priorityInstant;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get statusProgress;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @amountTopUp.
  ///
  /// In en, this message translates to:
  /// **'Amount Top-Up'**
  String get amountTopUp;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @accountBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Balance : '**
  String get accountBalanceLabel;

  /// No description provided for @quickRecharge.
  ///
  /// In en, this message translates to:
  /// **'Quick Recharge'**
  String get quickRecharge;

  /// No description provided for @selectPaymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Gateway'**
  String get selectPaymentGateway;

  /// No description provided for @processToPay.
  ///
  /// In en, this message translates to:
  /// **'Process to Pay'**
  String get processToPay;

  /// No description provided for @pleaseEnterAnAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAnAmount;

  /// No description provided for @pleaseEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterAValidAmount;

  /// No description provided for @pleaseSelectAPaymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment gateway'**
  String get pleaseSelectAPaymentGateway;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled'**
  String get paymentCancelled;

  /// No description provided for @topUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Top-Up Successful!'**
  String get topUpSuccessful;

  /// No description provided for @topUpSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you. your payment has been successfully received with the following details. Please quote you transaction reference number for any quueries relating to this request.'**
  String get topUpSuccessMessage;

  /// No description provided for @topUpNote.
  ///
  /// In en, this message translates to:
  /// **'Note : Paymnet will be creadited to your Rconverge Billing acoount within 3 Working Days'**
  String get topUpNote;

  /// No description provided for @topUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top-Up Failed'**
  String get topUpFailed;

  /// No description provided for @topUpFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recharge of ₹{amount} could not be completed.'**
  String topUpFailedMessage(String amount);

  /// No description provided for @topUpFailedRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your payment method or network connection and try again.'**
  String get topUpFailedRetryMessage;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @paymentAmountRs.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount (Rs)'**
  String get paymentAmountRs;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @cancelPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment?'**
  String get cancelPaymentTitle;

  /// No description provided for @cancelPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this payment?'**
  String get cancelPaymentMessage;

  /// No description provided for @filterBySpeed.
  ///
  /// In en, this message translates to:
  /// **'Filter By Speed'**
  String get filterBySpeed;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @mbps.
  ///
  /// In en, this message translates to:
  /// **'{speed} Mbps'**
  String mbps(int speed);

  /// No description provided for @changePlan.
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get changePlan;

  /// No description provided for @allPlans.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPlans;

  /// No description provided for @ottPlans.
  ///
  /// In en, this message translates to:
  /// **'OTT Plans'**
  String get ottPlans;

  /// No description provided for @searchPlan.
  ///
  /// In en, this message translates to:
  /// **'Search Plan'**
  String get searchPlan;

  /// No description provided for @changePackage.
  ///
  /// In en, this message translates to:
  /// **'Change Package'**
  String get changePackage;

  /// No description provided for @noPackagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No packages available'**
  String get noPackagesAvailable;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @rechargeSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Recharge Successful!'**
  String get rechargeSuccessful;

  /// No description provided for @rechargeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recharge of ₹{amount} has been completed successfully.'**
  String rechargeSuccessMessage(String amount);

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID: {txnId}'**
  String transactionId(String txnId);

  /// No description provided for @rechargeFailed.
  ///
  /// In en, this message translates to:
  /// **'Recharge Failed'**
  String get rechargeFailed;

  /// No description provided for @rechargeFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recharge of ₹500 could not be completed.'**
  String get rechargeFailedMessage;

  /// No description provided for @rechargePaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Recharge payment is cancelled'**
  String get rechargePaymentCancelled;

  /// No description provided for @rechargeFailedError.
  ///
  /// In en, this message translates to:
  /// **'Recharge failed: {error}'**
  String rechargeFailedError(String error);

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoicesFound;

  /// No description provided for @invoiceNo.
  ///
  /// In en, this message translates to:
  /// **'Invoice No : '**
  String get invoiceNo;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount : '**
  String get amountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date : '**
  String get dateLabel;

  /// No description provided for @introducingKfonApp.
  ///
  /// In en, this message translates to:
  /// **'Introducing KFON app'**
  String get introducingKfonApp;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @agnpEnquiry.
  ///
  /// In en, this message translates to:
  /// **'AGNP Enquiry'**
  String get agnpEnquiry;

  /// No description provided for @previewStep.
  ///
  /// In en, this message translates to:
  /// **'3. Preview'**
  String get previewStep;

  /// No description provided for @companyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInformation;

  /// No description provided for @geographicInformation.
  ///
  /// In en, this message translates to:
  /// **'Geographic Information'**
  String get geographicInformation;

  /// No description provided for @companyInformationStep.
  ///
  /// In en, this message translates to:
  /// **'1. Company Information'**
  String get companyInformationStep;

  /// No description provided for @geographicInformationStep.
  ///
  /// In en, this message translates to:
  /// **'2. Geographic Information'**
  String get geographicInformationStep;

  /// No description provided for @currentlyAssociatedWithISP.
  ///
  /// In en, this message translates to:
  /// **'Currently associated with any other ISP?'**
  String get currentlyAssociatedWithISP;

  /// No description provided for @agnpName.
  ///
  /// In en, this message translates to:
  /// **'AGNP Name*'**
  String get agnpName;

  /// No description provided for @enterAgnpName.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Name'**
  String get enterAgnpName;

  /// No description provided for @agnpContactName.
  ///
  /// In en, this message translates to:
  /// **'AGNP Contact Name*'**
  String get agnpContactName;

  /// No description provided for @enterAgnpContactName.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Contact Name'**
  String get enterAgnpContactName;

  /// No description provided for @agnpMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'AGNP Mobile Number*'**
  String get agnpMobileNumber;

  /// No description provided for @enterAgnpMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Mobile Number'**
  String get enterAgnpMobileNumber;

  /// No description provided for @agnpAlternativeMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'AGNP Alternative Mobile Number'**
  String get agnpAlternativeMobileNumber;

  /// No description provided for @enterAgnpAlternativeMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Alternative Mobile Number'**
  String get enterAgnpAlternativeMobileNumber;

  /// No description provided for @landlineNumber.
  ///
  /// In en, this message translates to:
  /// **'Landline Number'**
  String get landlineNumber;

  /// No description provided for @enterLandlineNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Landline Number'**
  String get enterLandlineNumber;

  /// No description provided for @agnpEmail.
  ///
  /// In en, this message translates to:
  /// **'AGNP Email*'**
  String get agnpEmail;

  /// No description provided for @enterAgnpEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Email'**
  String get enterAgnpEmail;

  /// No description provided for @agnpFullAddress.
  ///
  /// In en, this message translates to:
  /// **'AGNP Full Address*'**
  String get agnpFullAddress;

  /// No description provided for @enterAgnpFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Full Address'**
  String get enterAgnpFullAddress;

  /// No description provided for @agnpLocation.
  ///
  /// In en, this message translates to:
  /// **'AGNP Location'**
  String get agnpLocation;

  /// No description provided for @enterAgnpLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Location'**
  String get enterAgnpLocation;

  /// No description provided for @agnpLocationLatitude.
  ///
  /// In en, this message translates to:
  /// **'AGNP Location Latitude'**
  String get agnpLocationLatitude;

  /// No description provided for @enterAgnpLocationLatitude.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Location Latitude'**
  String get enterAgnpLocationLatitude;

  /// No description provided for @agnpLocationLongitude.
  ///
  /// In en, this message translates to:
  /// **'AGNP Location Longitude'**
  String get agnpLocationLongitude;

  /// No description provided for @enterAgnpLocationLongitude.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Location Longitude'**
  String get enterAgnpLocationLongitude;

  /// No description provided for @agnpPincode.
  ///
  /// In en, this message translates to:
  /// **'AGNP Pincode*'**
  String get agnpPincode;

  /// No description provided for @enterAgnpPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter AGNP Pincode'**
  String get enterAgnpPincode;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successMessage;

  /// No description provided for @bplSubscriptionEnquiry.
  ///
  /// In en, this message translates to:
  /// **'BPL Subscription Enquiry'**
  String get bplSubscriptionEnquiry;

  /// No description provided for @personalInformationStep.
  ///
  /// In en, this message translates to:
  /// **'1. Personal Information'**
  String get personalInformationStep;

  /// No description provided for @addressInformationStep.
  ///
  /// In en, this message translates to:
  /// **'2. Address Information'**
  String get addressInformationStep;

  /// No description provided for @addressInformation.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get addressInformation;

  /// No description provided for @rationCardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Ration Card Holder\'s Name*'**
  String get rationCardHolderName;

  /// No description provided for @enterRationCardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter Ration Card Holder\'s Name'**
  String get enterRationCardHolderName;

  /// No description provided for @aadharLinkedMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar linked mobile number of the ration card holder*'**
  String get aadharLinkedMobileNumber;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// No description provided for @ksebConsumerNo.
  ///
  /// In en, this message translates to:
  /// **'KSEB Consumer No*'**
  String get ksebConsumerNo;

  /// No description provided for @enterKsebConsumerNo.
  ///
  /// In en, this message translates to:
  /// **'Enter KSEB Consumer No'**
  String get enterKsebConsumerNo;

  /// No description provided for @aadharNumberOfRationCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Aadhar number of the ration card holder*'**
  String get aadharNumberOfRationCardHolder;

  /// No description provided for @enterAadharNumberOfRationCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Enter Aadhar number of the ration card holder'**
  String get enterAadharNumberOfRationCardHolder;

  /// No description provided for @installationAddress.
  ///
  /// In en, this message translates to:
  /// **'Installation Address*'**
  String get installationAddress;

  /// No description provided for @enterInstallationAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Installation Address'**
  String get enterInstallationAddress;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode*'**
  String get pincode;

  /// No description provided for @enterPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter Pincode'**
  String get enterPincode;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Referral Code'**
  String get enterReferralCode;

  /// No description provided for @declarationConsent.
  ///
  /// In en, this message translates to:
  /// **'I hereby give my consent to receive calls, texts, WhatsApp and emails regarding updates, newsletters, and other important information from or on behalf of KFON at the mobile number provided above.'**
  String get declarationConsent;

  /// No description provided for @darkFibreEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Dark Fibre Enquiry'**
  String get darkFibreEnquiry;

  /// No description provided for @darkFibrePreviewStep.
  ///
  /// In en, this message translates to:
  /// **'2. Preview'**
  String get darkFibrePreviewStep;

  /// No description provided for @documentsCollection.
  ///
  /// In en, this message translates to:
  /// **'Documents Collection'**
  String get documentsCollection;

  /// No description provided for @documentsCollectionStep.
  ///
  /// In en, this message translates to:
  /// **'2. Documents Collection'**
  String get documentsCollectionStep;

  /// No description provided for @uploadInternetServiceLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload Internet Service License *'**
  String get uploadInternetServiceLicense;

  /// No description provided for @selectFileHere.
  ///
  /// In en, this message translates to:
  /// **'Select File here'**
  String get selectFileHere;

  /// No description provided for @areaTelecomServiceProvided.
  ///
  /// In en, this message translates to:
  /// **'Area/Circle where Telecom service is provided'**
  String get areaTelecomServiceProvided;

  /// No description provided for @enterAreaTelecomServiceProvided.
  ///
  /// In en, this message translates to:
  /// **'Enter Area/Circle where Telecom service is provided'**
  String get enterAreaTelecomServiceProvided;

  /// No description provided for @uploadExperienceCertificate.
  ///
  /// In en, this message translates to:
  /// **'Upload Certificate in support of Experience'**
  String get uploadExperienceCertificate;

  /// No description provided for @behalfLeaseCompany.
  ///
  /// In en, this message translates to:
  /// **'For and on behalf Lease Company M/S'**
  String get behalfLeaseCompany;

  /// No description provided for @enterBehalfLeaseCompany.
  ///
  /// In en, this message translates to:
  /// **'Enter - For and on behalf Lease Company M/S'**
  String get enterBehalfLeaseCompany;

  /// No description provided for @uploadCoveringLetter.
  ///
  /// In en, this message translates to:
  /// **'Upload Covering Letter'**
  String get uploadCoveringLetter;

  /// No description provided for @downloadCoveringLetterFormat.
  ///
  /// In en, this message translates to:
  /// **'Download Covering Letter Format'**
  String get downloadCoveringLetterFormat;

  /// No description provided for @uploadRouteLeaseCopy.
  ///
  /// In en, this message translates to:
  /// **'Upload Details Of the RouteLease copy'**
  String get uploadRouteLeaseCopy;

  /// No description provided for @downloadRouteLeaseFormat.
  ///
  /// In en, this message translates to:
  /// **'Download Route Lease Format'**
  String get downloadRouteLeaseFormat;

  /// No description provided for @nameOfTheFirm.
  ///
  /// In en, this message translates to:
  /// **'Name Of The Firm*'**
  String get nameOfTheFirm;

  /// No description provided for @enterNameOfTheFirm.
  ///
  /// In en, this message translates to:
  /// **'Enter Name Of The Firm'**
  String get enterNameOfTheFirm;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @enterFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Address'**
  String get enterFullAddress;

  /// No description provided for @firmPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Firm Phone Number*'**
  String get firmPhoneNumber;

  /// No description provided for @enterFirmPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Firm Phone Number'**
  String get enterFirmPhoneNumber;

  /// No description provided for @firmEmail.
  ///
  /// In en, this message translates to:
  /// **'Firm Email*'**
  String get firmEmail;

  /// No description provided for @enterFirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Firm Email'**
  String get enterFirmEmail;

  /// No description provided for @contactPersonName.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Name*'**
  String get contactPersonName;

  /// No description provided for @enterContactPersonName.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Person Name'**
  String get enterContactPersonName;

  /// No description provided for @contactPersonPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Phone Number*'**
  String get contactPersonPhoneNumber;

  /// No description provided for @enterContactPersonPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Person Phone Number'**
  String get enterContactPersonPhoneNumber;

  /// No description provided for @contactPersonEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Person Email*'**
  String get contactPersonEmail;

  /// No description provided for @enterContactPersonEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Person Email'**
  String get enterContactPersonEmail;

  /// No description provided for @purposeOfLeasing.
  ///
  /// In en, this message translates to:
  /// **'Purpose Of Leasing'**
  String get purposeOfLeasing;

  /// No description provided for @enterPurposeOfLeasing.
  ///
  /// In en, this message translates to:
  /// **'Enter Purpose Of Leasing'**
  String get enterPurposeOfLeasing;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @corporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @bplEnquiry.
  ///
  /// In en, this message translates to:
  /// **'BPL Enquiry'**
  String get bplEnquiry;

  /// No description provided for @lnpEnquiry.
  ///
  /// In en, this message translates to:
  /// **'LNP Enquiry'**
  String get lnpEnquiry;

  /// No description provided for @governmentEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Government Enquiry'**
  String get governmentEnquiry;

  /// No description provided for @corporateEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Corporate Enquiry'**
  String get corporateEnquiry;

  /// No description provided for @letsGetToKnowYouStep.
  ///
  /// In en, this message translates to:
  /// **'1. Let\'s get to know you'**
  String get letsGetToKnowYouStep;

  /// No description provided for @whereShouldWeBringInternetStep.
  ///
  /// In en, this message translates to:
  /// **'2. Where should we bring the internet?'**
  String get whereShouldWeBringInternetStep;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name*'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter First Name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name*'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter Last Name'**
  String get enterLastName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number*'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumber2.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber2;

  /// No description provided for @emailId.
  ///
  /// In en, this message translates to:
  /// **'Email ID*'**
  String get emailId;

  /// No description provided for @enterEmailId.
  ///
  /// In en, this message translates to:
  /// **'Enter Email ID'**
  String get enterEmailId;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter Company Name'**
  String get enterCompanyName;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry*'**
  String get industry;

  /// No description provided for @selectIndustry.
  ///
  /// In en, this message translates to:
  /// **'Select Industry'**
  String get selectIndustry;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service*'**
  String get service;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @homeEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Home Enquiry'**
  String get homeEnquiry;

  /// No description provided for @homePreviewStep.
  ///
  /// In en, this message translates to:
  /// **'4. Preview'**
  String get homePreviewStep;

  /// No description provided for @howCanWeReachYouStep.
  ///
  /// In en, this message translates to:
  /// **'3. How can we reach you?'**
  String get howCanWeReachYouStep;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location*'**
  String get locationLabel;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Location'**
  String get enterLocation;

  /// No description provided for @lnpEnquiryHeading.
  ///
  /// In en, this message translates to:
  /// **'Local Connectivity Network Partner Enquiry'**
  String get lnpEnquiryHeading;

  /// No description provided for @partnerMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Partner Mobile Number*'**
  String get partnerMobileNumber;

  /// No description provided for @partnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Partner Email*'**
  String get partnerEmail;

  /// No description provided for @enterPartnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Email'**
  String get enterPartnerEmail;

  /// No description provided for @partnerFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Partner Full Address*'**
  String get partnerFullAddress;

  /// No description provided for @enterPartnerFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Full Address'**
  String get enterPartnerFullAddress;

  /// No description provided for @partnerLocation.
  ///
  /// In en, this message translates to:
  /// **'Partner Location'**
  String get partnerLocation;

  /// No description provided for @enterPartnerLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Location'**
  String get enterPartnerLocation;

  /// No description provided for @partnerLocationLatitude.
  ///
  /// In en, this message translates to:
  /// **'Partner Location Latitude'**
  String get partnerLocationLatitude;

  /// No description provided for @enterPartnerLocationLatitude.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Location Latitude'**
  String get enterPartnerLocationLatitude;

  /// No description provided for @partnerLocationLongitude.
  ///
  /// In en, this message translates to:
  /// **'Partner Location Longitude'**
  String get partnerLocationLongitude;

  /// No description provided for @enterPartnerLocationLongitude.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Location Longitude'**
  String get enterPartnerLocationLongitude;

  /// No description provided for @partnerPincode.
  ///
  /// In en, this message translates to:
  /// **'Partner Pincode*'**
  String get partnerPincode;

  /// No description provided for @enterPartnerPincode.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Pincode'**
  String get enterPartnerPincode;

  /// No description provided for @uploadCableTvRegistrationLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload CableTV Registration License*'**
  String get uploadCableTvRegistrationLicense;

  /// No description provided for @totalCableTvSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Total No of existing CableTV Subscriber*'**
  String get totalCableTvSubscriber;

  /// No description provided for @enterTotalCableTvSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Enter Total No of existing CableTV Subscriber'**
  String get enterTotalCableTvSubscriber;

  /// No description provided for @totalInternetSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Total No of existing Internet Subscriber*'**
  String get totalInternetSubscriber;

  /// No description provided for @enterTotalInternetSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Enter Total No of existing Internet Subscribe'**
  String get enterTotalInternetSubscriber;

  /// No description provided for @totalFibreAvailable.
  ///
  /// In en, this message translates to:
  /// **'Total quantity of Fibre Available (in KM)*'**
  String get totalFibreAvailable;

  /// No description provided for @enterTotalFibreAvailable.
  ///
  /// In en, this message translates to:
  /// **'Enter Total quantity of Fibre Available (in KM)'**
  String get enterTotalFibreAvailable;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By*'**
  String get createdBy;

  /// No description provided for @chooseCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Choose Created By'**
  String get chooseCreatedBy;

  /// No description provided for @partnerCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Partner Company Name*'**
  String get partnerCompanyName;

  /// No description provided for @enterPartnerCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Company Name'**
  String get enterPartnerCompanyName;

  /// No description provided for @partnerContactName.
  ///
  /// In en, this message translates to:
  /// **'Partner Contact Name*'**
  String get partnerContactName;

  /// No description provided for @enterPartnerContactName.
  ///
  /// In en, this message translates to:
  /// **'Enter Partner Contact Name'**
  String get enterPartnerContactName;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @packageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package Details'**
  String get packageDetails;

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCodeLabel;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER CODE (E.G. ONAM8F3A)'**
  String get referralCodeHint;

  /// No description provided for @referralHelperText.
  ///
  /// In en, this message translates to:
  /// **'Have a referral code? Enter it for an additional discount.'**
  String get referralHelperText;

  /// No description provided for @priceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get priceBreakdown;

  /// No description provided for @packageBreakdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Package — {packageName}'**
  String packageBreakdownLabel(String packageName);

  /// No description provided for @seasonDiscount.
  ///
  /// In en, this message translates to:
  /// **'Season Discount'**
  String get seasonDiscount;

  /// No description provided for @seasonDiscountRule.
  ///
  /// In en, this message translates to:
  /// **'{ruleName} - {discountValue}% OFF via Rule Engine'**
  String seasonDiscountRule(String ruleName, String discountValue);

  /// No description provided for @gstLabel.
  ///
  /// In en, this message translates to:
  /// **'GST (18%)'**
  String get gstLabel;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @billingDetails.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get billingDetails;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @subscriberCategory.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Category'**
  String get subscriberCategory;

  /// No description provided for @subPackage.
  ///
  /// In en, this message translates to:
  /// **'Sub-Package'**
  String get subPackage;

  /// No description provided for @rechargeDays.
  ///
  /// In en, this message translates to:
  /// **'Recharge Days'**
  String get rechargeDays;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay {amount}'**
  String confirmAndPay(String amount);

  /// No description provided for @discountAppliedHeader.
  ///
  /// In en, this message translates to:
  /// **'{ruleName} — {discountValue}% OFF Applied!'**
  String discountAppliedHeader(String ruleName, String discountValue);

  /// No description provided for @discountAppliedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discount resolved via Rule Engine - auto-applied'**
  String get discountAppliedSubtitle;

  /// No description provided for @referralCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Referral Code Applied Successfully!'**
  String get referralCodeApplied;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;
}

class _BssSubLocalizationsDelegate
    extends LocalizationsDelegate<BssSubLocalizations> {
  const _BssSubLocalizationsDelegate();

  @override
  Future<BssSubLocalizations> load(Locale locale) {
    return SynchronousFuture<BssSubLocalizations>(
      lookupBssSubLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BssSubLocalizationsDelegate old) => false;
}

BssSubLocalizations lookupBssSubLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return BssSubLocalizationsEn();
  }

  throw FlutterError(
    'BssSubLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
