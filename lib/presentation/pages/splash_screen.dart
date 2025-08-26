import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/auth/auth_state.dart';
import 'package:kfon_subscriber/common/bloc/auth/auth_state_cubit.dart';
import 'package:kfon_subscriber/domain/auth/usecases/is_logged_in.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;
  final AuthStateCubit _authStateCubit = AuthStateCubit();

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      _authStateCubit.checkLoginStatus(useCase: sl<IsLoggedInUseCase>());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _authStateCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthStateCubit, AuthState>(
      bloc: _authStateCubit,
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, '/home_page');
        } else if (state is UnAuthenticated) {
          Navigator.pushReplacementNamed(context, '/login_page');
        }
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Image.asset('assets/images/kfon_logo.jpg', width: 120),
          ),
        ),
      ),
    );
  }
}
