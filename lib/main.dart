import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/login_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/new_password_page.dart';
import 'package:kfon_subscriber/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/account_information_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/settings_page.dart';
import 'package:kfon_subscriber/features/self_care/presentation/pages/diagnostics_page.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/bpl_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/agnp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/dark_fibre_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/enquiry_list_page.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/gov_and_corp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/home_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/intro_screen_page.dart';
import 'package:kfon_subscriber/presentation/pages/invoice_list_page.dart';
import 'package:kfon_subscriber/presentation/pages/main_page.dart';
import 'package:kfon_subscriber/presentation/pages/notification_page.dart';
import 'package:kfon_subscriber/presentation/pages/sign_up_page.dart';
import 'package:kfon_subscriber/presentation/pages/transaction_history_page.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'presentation/pages/enquiry_forms/lnp_enquiry_form.dart';

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

  @override
  void initState() {
    super.initState();
    _authBloc.add(const CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light();
    final textTheme = theme.textTheme.apply(fontFamily: 'GeneralSans');
    return BlocProvider(
      create: (context) => _authBloc,
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
        routes: {
          '/login_page': (context) => LoginPage(),
          '/otp_verification': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return OtpVerificationPage(
              mobileNumber: args?['mobileNumber'] ?? '',
              isFromForgotPassword: args?['isFromForgotPassword'] ?? false,
            );
          },
          '/new_password': (context) => const NewPasswordPage(),
          '/sign_up': (context) => SignUpPage(),
          '/main_page': (context) => MainPage(),
          '/forgot_password': (context) => ForgotPasswordPage(),
          '/enquiry_list_page': (context) => EnquiryFormList(),
          '/home_enquiry_form': (context) => HomeEnquiryForm(),
          '/lnp_enquiry_form': (context) => LNPEnquiryForm(),
          '/bpl_enquiry_form': (context) => BPLEnquiryForm(),
          '/government_enquiry_form':
              (context) => GovAndCorpEnquiryForm(isGovernmentEnquiry: true),
          '/corporate_enquiry_form':
              (context) => GovAndCorpEnquiryForm(isGovernmentEnquiry: false),
          '/agnp_enquiry_form': (context) => AGNPEnquiryForm(),
          '/dark_fibre_enquiry_form': (context) => DarkFibreEnquiryForm(),
          '/account_information_page': (context) => AccountInformationPage(),
          '/notification_page': (context) => NotificationPage(),
          '/transaction_history_page': (context) => TransactionHistoryPage(),
          '/invoice_list_page': (context) => InvoiceListPage(),
          '/settings_page': (context) => SettingsPage(),
          '/self_care': (context) => DiagnosticsPage(),
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
    super.dispose();
  }
}
