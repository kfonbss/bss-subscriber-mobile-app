import 'package:flutter/widgets.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

/// Guards the features RailWire has no API for yet (listed in the BE gap
/// sheet). Does nothing when [ApiUrls.isRailwire] is false.
class RailwireNewApi {
  RailwireNewApi._();

  /// True, after showing the "New API needed" snackbar, when RailWire has no
  /// API for the tapped feature. Callers return early on true.
  static bool blocked(BuildContext context) {
    if (!ApiUrls.isRailwire) return false;
    DialogUtil().showCustomSnackbar(
      context: context,
      content: context.bssSubL10n.newApiNeeded,
    );
    return true;
  }
}
