import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/login_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/new_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/dark_fibre_enquiry_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/gov_and_corp_enquiry_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/home_enquiry_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/lnp_enquiry_form.dart';
import 'package:kfon_subscriber/features/pages/notification_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/pages/account_information_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/settings_page.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/bpl_enquiry_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/agnp_enquiry_form.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/enquiry_list_page.dart';
import 'package:kfon_subscriber/features/pages/intro_screen_page.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/pages/invoice_list_page.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_event.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/pages/main_page.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/pages/transaction_history_page.dart';
import 'package:kfon_subscriber/l10/bss_sub_localizations.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env/.env.dev");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  setUpServiceLocator();
  final showIntro = await PreferenceUtils.showIntroScreen();

  runApp(MyApp(showIntro: showIntro));
}

class MyApp extends StatefulWidget {
  final bool showIntro;

  const MyApp({super.key, required this.showIntro});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthBloc _authBloc = AuthBloc(authRepository: sl<AuthRepository>());
  late final ProfileBloc _profileBloc;
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _authBloc.add(const CheckAuthStatus());
    _profileBloc = ProfileBloc(repository: sl<ProfileRepository>());
    _homeBloc = HomeBloc(repository: sl<HomeRepository>());
    _profileBloc.add(const FetchProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light();
    final textTheme = theme.textTheme.apply(fontFamily: 'GeneralSans');
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _authBloc),
        BlocProvider(create: (context) => _profileBloc),
        BlocProvider(create: (context) => _homeBloc),
      ],
      child: MaterialApp(
        theme: theme.copyWith(
          primaryColor: AppColor.kPrimaryColor,
          scaffoldBackgroundColor: AppColor.kMainBackgroundColor,
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColor.kPrimaryColor,
          ),
          textTheme: textTheme.copyWith(
            titleLarge: textTheme.titleLarge?.copyWith(
              fontSize: 18,
              letterSpacing: 0.0,
            ),
            titleMedium: textTheme.titleMedium?.copyWith(letterSpacing: 0.0),
            titleSmall: textTheme.titleSmall?.copyWith(letterSpacing: 0.0),
            bodyLarge: textTheme.bodyLarge?.copyWith(letterSpacing: 0.0),
            bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: 0.0),
            bodySmall: textTheme.bodySmall?.copyWith(letterSpacing: 0.0),
            labelLarge: textTheme.labelLarge?.copyWith(letterSpacing: 0.0),
            labelMedium: textTheme.labelMedium?.copyWith(letterSpacing: 0.0),
            labelSmall: textTheme.labelSmall?.copyWith(letterSpacing: 0.0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kPrimaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        builder: (context, child) {
          Sizer.init(context);
          return child!;
        },
        localizationsDelegates: [BssSubLocalizations.delegate],
        supportedLocales: [const Locale('en')],
        routes: {
          AppRoutes.login: (context) => LoginPage(),
          AppRoutes.otpVerification: (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return OtpVerificationPage(
              mobileNumber: args?['mobileNumber'] ?? '',
              isFromForgotPassword: args?['isFromForgotPassword'] ?? false,
            );
          },
          AppRoutes.newPassword: (context) => const NewPasswordPage(),
          AppRoutes.mainPage: (context) => MainPage(),
          AppRoutes.forgotPassword: (context) => ForgotPasswordPage(),
          AppRoutes.enquiryListPage: (context) => EnquiryFormList(),
          AppRoutes.homeEnquiryForm: (context) => HomeEnquiryForm(),
          AppRoutes.lnpEnquiryForm: (context) => LNPEnquiryForm(),
          AppRoutes.bplEnquiryForm: (context) => BPLEnquiryForm(),
          AppRoutes.governmentEnquiryForm:
              (context) => GovAndCorpEnquiryForm(isGovernmentEnquiry: true),
          AppRoutes.corporateEnquiryForm:
              (context) => GovAndCorpEnquiryForm(isGovernmentEnquiry: false),
          AppRoutes.agnpEnquiryForm: (context) => AGNPEnquiryForm(),
          AppRoutes.darkFibreEnquiryForm: (context) => DarkFibreEnquiryForm(),
          AppRoutes.accountInformationPage:
              (context) => AccountInformationPage(),
          AppRoutes.notificationPage: (context) => NotificationPage(),
          AppRoutes.transactionHistoryPage:
              (context) => TransactionHistoryPage(),
          AppRoutes.invoiceListPage:
              (context) => BlocProvider(
                create:
                    (context) =>
                        InvoiceListBloc(repository: sl<InvoiceRepository>())
                          ..add(const FetchInvoices()),
                child: const InvoiceListPage(),
              ),
          AppRoutes.settingsPage: (context) => SettingsPage(),
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          bloc: _authBloc,
          builder: (context, state) {
            if (state is Authenticated) {
              return MainPage();
            } else if (widget.showIntro) {
              return IntroScreenPage();
            } else {
              return LoginPage();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _profileBloc.close();
    _homeBloc.close();
    super.dispose();
  }
}
