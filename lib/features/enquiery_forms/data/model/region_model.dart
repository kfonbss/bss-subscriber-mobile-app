class RegionModel {
  final String id;
  final int? masterId;
  final String code;
  final String? pincode;
  final String name;
  final String? nameInLocal;
  final bool isActive;
  final String? district;
  final String? districtId;
  final String? villageTypeId;
  final String? districtCode;
  final int? stCode;

  const RegionModel({
    required this.id,
    this.masterId,
    required this.code,
    this.pincode,
    required this.name,
    this.nameInLocal,
    required this.isActive,
    this.district,
    this.districtId,
    this.villageTypeId,
    this.districtCode,
    this.stCode,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: json['id']?.toString() ?? '',
    masterId: (json['masterId'] as num?)?.toInt(),
    code: json['code']?.toString() ?? '',
    pincode: json['pincode']?.toString(),
    name: json['name']?.toString() ?? '',
    nameInLocal: json['nameInLocal']?.toString(),
    isActive: json['isActive'] as bool? ?? true,
    district: json['district']?.toString(),
    districtId: json['districtId']?.toString(),
    villageTypeId: json['villageTypeId']?.toString(),
    districtCode: json['districtCode']?.toString(),
    stCode: (json['stCode'] as num?)?.toInt(),
  );
}
