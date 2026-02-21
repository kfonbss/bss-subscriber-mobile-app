import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../source/enquiry_form_api_service.dart';

class EnquiryFormRepositoryImp extends EnquiryFormRepository {
  @override
  Future<Either> submitHomeEnquiryForm(HomeEnquiryFormParams params) async {
    return await sl<EnquiryFormApiService>().submitHomeEnquiryForm(params);
  }

  @override
  Future<Either> submitLNPEnquiryForm(LNPEnquiryFormParams params) async {
    return await sl<EnquiryFormApiService>().submitLNPEnquiryForm(params);
  }

  @override
  Future<Either> submitAGNPEnquiryForm(AGNPEnquiryFormParams params) async {
    return await sl<EnquiryFormApiService>().submitAGNPEnquiryForm(params);
  }

  @override
  Future<Either> submitGovAndCorpEnquiryForm(
    GovAndCorpEnquiryFormParams params,
  ) async {
    return await sl<EnquiryFormApiService>().submitGovAndCorpEnquiryForm(
      params,
    );
  }

  @override
  Future<Either> submitDarkFibreEnquiryForm(
    DarkFibreEnquiryFormParams params,
  ) async {
    return await sl<EnquiryFormApiService>().submitDarkFibreEnquiryForm(params);
  }

  @override
  Future<Either> downloadLetterFormat(String url) async {
    return await sl<EnquiryFormApiService>().downloadLetterFormat(url);
  }

  @override
  Future<Either> submitBPLEnquiryForm(BplEnquiryFormParams params) async {
    return await sl<EnquiryFormApiService>().submitBPLEnquiryForm(params);
  }
}
