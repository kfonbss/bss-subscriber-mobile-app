import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/domain/repository/autopay_repository.dart';

/// Autopay status for the home wallet card's Auto Pay pill. `null` means
/// unknown (not loaded yet, or the first load failed); the pill then hides
/// the switch instead of guessing ON/OFF.
///
/// TODO(BE): switch to the home API once it returns the autopay status, and
/// drop this extra `upi-mandate/status` call.
class HomeAutopayCubit extends Cubit<AutopayStatus?> {
  HomeAutopayCubit({required this.repository}) : super(null);

  final AutopayRepository repository;

  /// Ignores responses from older calls, so a slow earlier load can't
  /// overwrite a newer one (e.g. pull-to-refresh, then back from Autopay).
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    final result = await repository.getStatus();
    if (isClosed || requestId != _requestId) return;
    // On failure keep the last known status; it is still the best guess.
    result.fold((_) {}, emit);
  }
}
