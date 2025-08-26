import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/constant/mis_constant.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:path_provider/path_provider.dart';

abstract class EnquiryFormApiService {
  Future<Either> submitSubscriptionEnquiryForm(
    SubscriptionEnquiryFormParams params,
  );

  Future<Either> submitLNPEnquiryForm(LNPEnquiryFormParams params);

  Future<Either> submitAGNPEnquiryForm(AGNPEnquiryFormParams params);

  Future<Either> submitCorporateEnquiryForm(CorporateEnquiryFormParams params);

  Future<Either> submitDarkFibreEnquiryForm(DarkFibreEnquiryFormParams params);
  Future<Either> submitBPLEnquiryForm( BplEnquiryFormParams params);

  Future<Either> getPostOfficesDistricts(String pinCode);

  Future<Either> downloadLetterFormat(String url);
}

class EnquiryFormApiServiceImp extends EnquiryFormApiService {
  @override
  Future<Either> submitSubscriptionEnquiryForm(
    SubscriptionEnquiryFormParams params,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.subscriptionEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> getPostOfficesDistricts(String pinCode) async {
    var response = await sl<DioClient>().post(
      ApiUrls.getPostOfficesDistrictURL,
      data: FormData.fromMap({'pincode': pinCode}),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitLNPEnquiryForm(LNPEnquiryFormParams params) async {
    var response = await sl<DioClient>().post(
      ApiUrls.lnpEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitAGNPEnquiryForm(AGNPEnquiryFormParams params) async {
    var response = await sl<DioClient>().post(
      ApiUrls.agnpEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitCorporateEnquiryForm(
    CorporateEnquiryFormParams params,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.corporateEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitDarkFibreEnquiryForm(
    DarkFibreEnquiryFormParams params,
  ) async {
    var response = await sl<DioClient>().post(
      ApiUrls.darkFibreEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> downloadLetterFormat(String url) async {
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory(MisConstant.kDownloadDirectoryPath);
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    final File file = File('${downloadsDir.path}/${url.split('/').last}');

    var response = await sl<DioClient>().download(url, file.path);
    if (response.status == 'success') {
      return Right(true);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitBPLEnquiryForm(BplEnquiryFormParams params) async{
    var response = await sl<DioClient>().post(
      ApiUrls.bplEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.status == 'success') {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }
}
