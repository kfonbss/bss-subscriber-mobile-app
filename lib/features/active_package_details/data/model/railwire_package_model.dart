/// The `data` object of the RailWire `currentpackage` response. Speed, plan
/// type, validity and renewal fee aren't in it yet, so those screens show their
/// empty values until the API adds them. [category] (e.g. "Fiber Ultra") is
/// read as soon as the API sends it.
class RailwirePackageModel {
  final String packageId;
  final String packageName;
  final DateTime activeUntil;
  final String? category;

  const RailwirePackageModel({
    required this.packageId,
    required this.packageName,
    required this.activeUntil,
    this.category,
  });

  factory RailwirePackageModel.fromJson(Map<String, dynamic> json) =>
      RailwirePackageModel(
        packageId: json['packageid']?.toString() ?? '',
        packageName: json['packagename']?.toString() ?? '',
        activeUntil:
            DateTime.tryParse(json['expiry']?.toString() ?? '') ??
            DateTime.now(),
        category: json['category']?.toString().trim(),
      );

  int get daysLeft {
    final days = activeUntil.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }
}
