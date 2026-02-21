import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class GovAndCorpEnquiryFormUseCase
    implements UseCase<Either, GovAndCorpEnquiryFormParams> {
  @override
  Future<Either> call({GovAndCorpEnquiryFormParams? param}) async {
    return await sl<EnquiryFormRepository>().submitGovAndCorpEnquiryForm(
      param!,
    );
  }
}
