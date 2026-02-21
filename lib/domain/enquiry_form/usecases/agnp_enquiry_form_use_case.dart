import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class AgnpEnquiryFormUseCase
    implements UseCase<Either, AGNPEnquiryFormParams> {
  @override
  Future<Either> call({AGNPEnquiryFormParams? param}) async {
    return await sl<EnquiryFormRepository>().submitAGNPEnquiryForm(
      param!,
    );
  }
}
