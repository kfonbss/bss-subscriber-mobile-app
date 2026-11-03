/// The `data` object of the RailWire `currentpackage` response. Speed, plan
/// type, validity and renewal fee aren't in it yet, so those screens show their
/// empty values until the API adds them.
class RailwirePackageModel {
  final String packageId;
  final String packageName;
  final DateTime activeUntil;

  const RailwirePackageModel({
    required this.packageId,
    required this.packageName,
    required this.activeUntil,
  });

  factory RailwirePackageModel.fromJson(Map<String, dynamic> json) =>
      RailwirePackageModel(
        packageId: json['packageid']?.toString() ?? '',
        packageName: json['packagename']?.toString() ?? '',
        activeUntil:
            DateTime.tryParse(json['expiry']?.toString() ?? '') ??
            DateTime.now(),
      );

  int get daysLeft {
    final days = activeUntil.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }
}
