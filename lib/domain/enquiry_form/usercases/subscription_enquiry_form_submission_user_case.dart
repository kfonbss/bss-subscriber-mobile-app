
import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class SubscriptionEnquiryFormSubmissionUserCase implements UseCase<Either,SubscriptionEnquiryFormParams>{

  @override
  Future<Either> call({SubscriptionEnquiryFormParams? param})async {
    return await sl<EnquiryFormRepository>().submitSubscriptionEnquiryForm(param!);
  }

}