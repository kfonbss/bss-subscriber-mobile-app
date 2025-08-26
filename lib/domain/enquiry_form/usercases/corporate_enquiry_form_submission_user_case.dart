import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class CorporateEnquiryFormSubmissionUserCase
    implements UseCase<Either, CorporateEnquiryFormParams> {
  @override
  Future<Either> call({CorporateEnquiryFormParams? param}) async {
    return await sl<EnquiryFormRepository>().submitCorporateEnquiryForm(param!);
  }
}
