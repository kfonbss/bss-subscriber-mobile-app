import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/auth/model/login_req_params.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../util/preference_util.dart';

abstract class AuthLocalService {
  Future<bool> isLoggedIn();
}

class AuthLocalServiceImp extends AuthLocalService {
  @override
  Future<bool> isLoggedIn() async {
    var token = await PreferenceUtils.getLoginToken();
    if (token.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
