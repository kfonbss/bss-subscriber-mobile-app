import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/routes/navigator_key.dart';
import 'package:kfon_subscriber/core/util/app_locale.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/login_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/new_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/tenant_screen.dart';
import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/domain/repository/invoice_repository.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_bloc.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/bloc/invoice_list_event.dart';
import 'package:kfon_subscriber/features/invoice_list/presentation/pages/invoice_list_page.dart';
import 'package:kfon_subscriber/features/notfication/presentation/pages/notification_page.dart';
import 'package:kfon_subscriber/features/pages/intro_screen_page.dart';
import 'package:kfon_subscriber/features/pages/main_page.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/pages/account_information_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/settings_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/tranasactions/presentation/pages/transaction_history_page.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/service_locator.dart';

import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
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
  final tenantId = await PreferenceUtils.getTenantId() ?? '';
  AppBrand.setTenant(tenantId);
  await AppLocale.load();
  runApp(MyApp(showIntro: showIntro, tenantId: tenantId));
}

class MyApp extends StatefulWidget {
  final bool showIntro;
  final String tenantId;

  const MyApp({super.key, required this.showIntro, required this.tenantId});

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
    _profileBloc = ProfileBloc(repository: sl<ProfileRepository>());
    _homeBloc = HomeBloc(repository: sl<HomeRepository>());
    _authBloc.add(const CheckAuthStatus());
    AppLocale.notifier.addListener(_onLocaleChanged);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _homeBloc),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) {
          Sizer.init(context, designHeight: 812.0, designWidth: 375.0);
          return child!;
        },
        localizationsDelegates: BssSubLocalizations.localizationsDelegates,
        locale: AppLocale.notifier.value,
        supportedLocales: AppLocale.supported,
        routes: {
          AppRoutes.tenant: (context) => TenantScreen(),
          AppRoutes.login: (context) => LoginPage(),
          AppRoutes.otpVerification: (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return OtpVerificationPage(
              mobileNumber: args?['mobileNumber'] ?? '',
              token: args?['token'] ?? '',
              isFromForgotPassword: args?['isFromForgotPassword'] ?? false,
            );
          },
          AppRoutes.newPassword: (context) => const NewPasswordPage(),
          AppRoutes.mainPage: (context) => MainPage(),
          AppRoutes.forgotPassword: (context) => ForgotPasswordPage(),
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
        home: BlocConsumer<AuthBloc, AuthState>(
          bloc: _authBloc,
          listener: (context, state) {
            FlutterNativeSplash.remove();
          },
          builder: (context, state) {
            // Flow: tenant → intro (first launch) → login. The tenant comes
            // first because the intro uses the tenant's primary colour.
            if (state is Authenticated) {
              return MainPage();
            } else if (widget.tenantId.isEmpty) {
              return TenantScreen();
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
  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppLocale.notifier.removeListener(_onLocaleChanged);
    _authBloc.close();
    _profileBloc.close();
    _homeBloc.close();
    super.dispose();
  }
}
