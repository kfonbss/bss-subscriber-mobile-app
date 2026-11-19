import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/network/railwire_api.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/params/change_password_params.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

class RailwireProfileRepositoryImp extends ProfileRepository {
  /// The portal password `changepasswordfor` value. Whether other values exist
  /// (e.g. the internet password) is an open question with the PHP team.
  static const _portalPassword = 'Bill';

  /// `subscriber_update_password` doesn't check the current password, so it's
  /// checked first by logging in with it.
  @override
  Future<Either<Failure, void>> changePortalPassword(
    ChangePasswordParams params,
  ) async {
    final check = await RailwireApi.post(
      ApiUrls.railwireUserLoginURL,
      (session) => {
        'username': session.username,
        'password': params.oldPassword,
      },
      sensitive: true,
    );
    final checkFailure = check.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (checkFailure != null) {
      // The API refusing the login means a wrong password; anything else
      // (no network, timeout) is shown as it is.
      return Left(
        checkFailure is ServerFailure
            ? ValidationFailure(appL10n.currentPasswordIncorrect)
            : checkFailure,
      );
    }

    final result = await RailwireApi.post(
      ApiUrls.railwireUpdatePasswordURL,
      (session) => {
        ...session.byUsername,
        'changepasswordfor': _portalPassword,
        'newpassword': params.newPassword,
      },
      sensitive: true,
    );
    return result.map((_) {});
  }

  Future<Either<Failure, Map<String, dynamic>>> _userProfile() =>
      RailwireApi.post(
        ApiUrls.railwireUserProfileURL,
        (session) => session.byUsername,
      );

  String _text(dynamic value) => value?.toString() ?? '';

  int _subscriberId(Map<String, dynamic> json) =>
      int.tryParse(_text(json['subscriberid'])) ?? 0;

  /// `middlename` and `lastname` are often null.
  String _name(Map<String, dynamic> json) => [
    json['firstname'],
    json['middlename'],
    json['lastname'],
  ].map(_text).where((part) => part.trim().isNotEmpty).join(' ');

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final result = await _userProfile();
    return result.map(
      (json) => ProfileEntity(
        subscriberId: _subscriberId(json),
        name: _name(json),
        status: _text(json['status_user']),
      ),
    );
  }

  /// KYC status, PAN and GST aren't in `userprofile` yet.
  @override
  Future<Either<Failure, AccountInformationEntity>>
  getAccountInformation() async {
    final result = await _userProfile();
    return result.map(
      (json) => AccountInformationEntity(
        personalInfo: PersonalInfo(
          subscriberId: _subscriberId(json),
          username: _text(json['username']),
          name: _name(json),
          mobileNo: _text(json['mobileno']),
          address: _text(json['address']),
          email: _text(json['email']),
        ),
        accountInfo: AccountInfo(
          kycStatus: '',
          subscriptionName: _text(json['packagename']),
          subscriptionStatus: _text(json['status_user']),
          onlineStatus: _text(json['onlineflag']),
        ),
        taxInfo: const TaxInfo(pan: '', gst: ''),
        lnpInfo: LnpInfo(
          lnpName: _text(json['partnercompanyname']),
          lnpEmail: _text(json['pemail']),
          lnpMobile: _text(json['pcontactnumber']),
          lnpAddress: _text(json['paddress']),
        ),
      ),
    );
  }
}
