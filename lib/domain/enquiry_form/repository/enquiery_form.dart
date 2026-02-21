import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/gov_and_corp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/home_enquiry_form_params.dart';

abstract class EnquiryFormRepository{
  Future<Either> submitHomeEnquiryForm( HomeEnquiryFormParams params);
  Future<Either> submitLNPEnquiryForm( LNPEnquiryFormParams params);
  Future<Either> submitAGNPEnquiryForm( AGNPEnquiryFormParams params);
  Future<Either> submitGovAndCorpEnquiryForm(GovAndCorpEnquiryFormParams params);
  Future<Either> submitDarkFibreEnquiryForm( DarkFibreEnquiryFormParams params);
  Future<Either> submitBPLEnquiryForm( BplEnquiryFormParams params);
  Future<Either> downloadLetterFormat( String url);
}