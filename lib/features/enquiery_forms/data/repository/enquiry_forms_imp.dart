import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/constant/mis_constant.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/data/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/features/enquiery_forms/domain/repository/enquiery_form.dart';
import 'package:path_provider/path_provider.dart';

class EnquiryFormRepositoryImp extends EnquiryFormRepository {
  final DioClient _client;

  EnquiryFormRepositoryImp({required DioClient client}) : _client = client;

  @override
  Future<Either> submitHomeEnquiryForm(HomeEnquiryFormParams params) async {
    final response = await _client.post(
      ApiUrls.subscriptionEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitLNPEnquiryForm(LNPEnquiryFormParams params) async {
    final response = await _client.post(
      ApiUrls.lnpEnquiryFormURL,
      data: await params.toFormData(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
    }
  }

  @override
  Future<Either> submitAGNPEnquiryForm(AGNPEnquiryFormParams params) async {
    final response = await _client.post(
      ApiUrls.agnpEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
    }
  }

  @override
  Future<Either> submitGovAndCorpEnquiryForm(
    GovAndCorpEnquiryFormParams params,
  ) async {
    final response = await _client.post(
      ApiUrls.govAndCorpEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
    }
  }

  @override
  Future<Either> submitDarkFibreEnquiryForm(
    DarkFibreEnquiryFormParams params,
  ) async {
    final response = await _client.post(
      ApiUrls.darkFibreEnquiryFormURL,
      data: await params.toFormData(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
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

    final response = await _client.download(url, file.path);
    if (response.error.isEmpty) {
      return Right(true);
    } else {
      return Left(response.message);
    }
  }

  @override
  Future<Either> submitBPLEnquiryForm(BplEnquiryFormParams params) async {
    final response = await _client.post(
      ApiUrls.bplEnquiryFormURL,
      data: params.toMap(),
    );
    if (response.error.isEmpty) {
      return Right(response.data);
    } else {
      return Left(response.error);
    }
  }
}
