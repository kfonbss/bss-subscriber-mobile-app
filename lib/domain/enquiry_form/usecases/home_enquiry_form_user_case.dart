
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/home_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class HomeEnquiryFormUseCase implements UseCase<Either,HomeEnquiryFormParams>{

  @override
  Future<Either> call({HomeEnquiryFormParams? param})async {
    return await sl<EnquiryFormRepository>().submitHomeEnquiryForm(param!);
  }

}