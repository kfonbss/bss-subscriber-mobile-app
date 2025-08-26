import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../source/enquiry_form_api_service.dart';

class EnquiryFormRepositoryImp extends EnquiryFormRepository {
  @override
  Future<Either> submitSubscriptionEnquiryForm(
    SubscriptionEnquiryFormParams params,
  ) async {
    return await sl<EnquiryFormApiService>().submitSubscriptionEnquiryForm(
      params,
    );
  }

  @override
  Future<Either> getPostOfficesDistricts(String pinCode) async {
    return await sl<EnquiryFormApiService>().getPostOfficesDistricts(pinCode);
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
  Future<Either> submitCorporateEnquiryForm(
    CorporateEnquiryFormParams params,
  ) async {
    return await sl<EnquiryFormApiService>().submitCorporateEnquiryForm(params);
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
  Future<Either> submitBPLEnquiryForm(BplEnquiryFormParams params)async {
    return await sl<EnquiryFormApiService>().submitBPLEnquiryForm(params);
  }
}
