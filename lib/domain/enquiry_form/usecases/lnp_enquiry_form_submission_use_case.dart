import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class LnpEnquiryFormSubmissionUserCase
    implements UseCase<Either, LNPEnquiryFormParams> {
  @override
  Future<Either> call({LNPEnquiryFormParams? param}) async {
    return await sl<EnquiryFormRepository>().submitLNPEnquiryForm(
      param!,
    );
  }
}
