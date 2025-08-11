import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfon_subscriber/core/constant/constant.dart';
import 'package:kfon_subscriber/presentation/pages/forgot_password.dart' show ForgotPassword;
import 'package:kfon_subscriber/presentation/pages/home_page.dart';
import 'package:kfon_subscriber/presentation/pages/login_page.dart' show LoginPage;
import 'package:kfon_subscriber/presentation/pages/splash_screen.dart' show SplashScreen;
import 'package:kfon_subscriber/service_locator.dart';


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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/splash_screen': (context) => SplashScreen(),
        '/login_page': (context) => LoginPage(),
        '/home_page': (context) => HomePage(),
        '/forgot_password_page': (context) => ForgotPassword(),
      },
      home:  SplashScreen(),
    );
  }
}