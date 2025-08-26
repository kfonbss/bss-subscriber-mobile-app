class PostOfficeDistrictResponse {
  PostOfficeDistrictResponse({this.status, this.postOffices, this.district});

  String? status;
  List<String>? postOffices;
  List<String>? district;

  factory PostOfficeDistrictResponse.fromJson(Map<String, dynamic> json) =>
      PostOfficeDistrictResponse(
        status: json["status"],
        postOffices:
            (json['postOffices'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList(),
        district:
            (json['district'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList(),
      );
}
