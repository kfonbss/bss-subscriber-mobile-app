import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/agnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/bpl_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/corporate_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/dark_fibre_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/lnp_enquiry_form_params.dart';
import 'package:kfon_subscriber/data/enquiry_form/model/subscription_enquiry_form_params.dart';

abstract class EnquiryFormRepository{
  Future<Either> submitSubscriptionEnquiryForm( SubscriptionEnquiryFormParams params);
  Future<Either> submitLNPEnquiryForm( LNPEnquiryFormParams params);
  Future<Either> submitAGNPEnquiryForm( AGNPEnquiryFormParams params);
  Future<Either> submitCorporateEnquiryForm( CorporateEnquiryFormParams params);
  Future<Either> submitDarkFibreEnquiryForm( DarkFibreEnquiryFormParams params);
  Future<Either> submitBPLEnquiryForm( BplEnquiryFormParams params);
  Future<Either> getPostOfficesDistricts( String pinCode);
  Future<Either> downloadLetterFormat( String url);
}