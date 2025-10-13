import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/bpl_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/corporate_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/agnp_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/dark_fibre_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/enquiry_list_page.dart';
import 'package:kfon_subscriber/presentation/pages/enquiry_forms/subscription_enquiry_form.dart';
import 'package:kfon_subscriber/presentation/pages/faq_page.dart';
import 'package:kfon_subscriber/presentation/pages/forgot_password.dart' show ForgotPassword;
import 'package:kfon_subscriber/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/presentation/pages/login_page.dart' show LoginPage;
import 'package:kfon_subscriber/presentation/pages/main_page.dart';
import 'package:kfon_subscriber/presentation/pages/splash_screen.dart' show SplashScreen;
import 'package:kfon_subscriber/service_locator.dart';

import 'presentation/pages/enquiry_forms/lnp_enquiry_form.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  setUpServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColor.kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/splash_screen': (context) => SplashScreen(),
        '/login_page': (context) => LoginPage(),
        '/main_page': (context) => MainPage(),
        '/forgot_password_page': (context) => ForgotPassword(),
        '/enquiry_list_page': (context) => EnquiryFormList(),
        '/subscription_enquiry_form': (context) => SubscriptionEnquiryForm(),
        '/lnp_enquiry_form': (context) => LNPEnquiryForm(),
        '/bpl_enquiry_form': (context) => BPLEnquiryForm(),
        '/agnp_enquiry_form': (context) => AGNPEnquiryForm(),
        '/corporate_enquiry_form': (context) => CorporateEnquiryForm(),
        '/dark_fibre_enquiry_form': (context) => DarkFibreEnquiryForm(),
        '/faq_page': (context) => FaqPage(),
      },
      home:  SplashScreen(),
    );
  }
}