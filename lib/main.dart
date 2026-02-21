import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/auth/auth_state.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/account_information_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/settings_page.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/bpl_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/agnp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/dark_fibre_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/enquiry_list_page.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/gov_and_corp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/home_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/forgot_password.dart';
import 'package:kfon_subscriber/presentation/pages/intro_screen_page.dart';
import 'package:kfon_subscriber/presentation/pages/invoice_page.dart';
import 'package:kfon_subscriber/presentation/pages/login_page.dart';
import 'package:kfon_subscriber/presentation/pages/main_page.dart';
import 'package:kfon_subscriber/presentation/pages/notification_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/presentation/pages/sign_up_page.dart';
import 'package:kfon_subscriber/presentation/pages/transaction_details_page.dart';
import 'package:kfon_subscriber/presentation/pages/transaction_history_page.dart';
import 'package:kfon_subscriber/service_locator.dart';

import 'common/bloc/auth/auth_state_cubit.dart';
import 'presentation/pages/enquiry_forms/lnp_enquiry_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  setUpServiceLocator();
  // if(Platform.isAndroid) {
  //   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  // }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthStateCubit _authStateCubit = AuthStateCubit();

  @override
  void initState() {
    super.initState();
    _authStateCubit.checkLoginStatus(useCase: sl<IsLoggedInUseCase>());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light();
    final textTheme = theme.textTheme.apply(fontFamily: 'GeneralSans');
    return MaterialApp(
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
        '/sign_up': (context) => SignUpPage(),
        '/main_page': (context) => MainPage(),
        '/forgot_password_page': (context) => ForgotPassword(),
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
        '/security_settings_page': (context) => SecuritySettingsPage(),
        '/notification_page': (context) => NotificationPage(),
        '/transaction_history_page': (context) => TransactionHistoryPage(),
        '/invoice_page': (context) => InvoicePage(),
        '/settings_page': (context) => SettingsPage(),
      },
      home: BlocBuilder<AuthStateCubit, AuthState>(
        bloc: _authStateCubit,
        builder: (context, state) {
          if (state is Authenticated) {
            return MainPage();
          } else {
            return IntroScreenPage();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _authStateCubit.close();
    super.dispose();
  }
}
