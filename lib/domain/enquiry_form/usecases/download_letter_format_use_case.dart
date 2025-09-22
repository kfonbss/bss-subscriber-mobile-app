import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/domain/enquiry_form/repository/enquiery_form.dart';
import 'package:kfon_subscriber/service_locator.dart';

class DownloadLetterFormatUserCase implements UseCase<Either,String>{

  @override
  Future<Either> call({String? param})async {
    return await sl<EnquiryFormRepository>().downloadLetterFormat(param!);
  }

}