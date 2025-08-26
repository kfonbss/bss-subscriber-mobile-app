import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class DarkFibreEnquiryFormSubmissionUserCase
    implements UseCase<Either, DarkFibreEnquiryFormParams> {
  @override
  Future<Either> call({DarkFibreEnquiryFormParams? param}) async {
    return await sl<EnquiryFormRepository>().submitDarkFibreEnquiryForm(param!);
  }
}
