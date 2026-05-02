class GetTicketsListParams {
  final int page;
  final int size;
  final String? search;
  final String? priority;
  final String? status;
  final String? createdDateFrom;
  final String? createdDateTo;
  final String? type;

  const GetTicketsListParams({
    this.page = 0,
    this.size = 10,
    this.search,
    this.priority,
    this.status,
    this.createdDateFrom,
    this.createdDateTo,
    this.type,
  });

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (search != null && search!.trim().isNotEmpty) {
      map['search'] = search!.trim();
    }
    if (priority != null && priority!.trim().isNotEmpty) {
      map['priority'] = priority!.trim();
    }
    if (status != null && status!.trim().isNotEmpty) {
      map['status'] = status!.trim();
    }
    if (createdDateFrom != null && createdDateFrom!.trim().isNotEmpty) {
      map['createdDateFrom'] = createdDateFrom!.trim();
    }
    if (createdDateTo != null && createdDateTo!.trim().isNotEmpty) {
      map['createdDateTo'] = createdDateTo!.trim();
    }
    if (type != null && type!.trim().isNotEmpty) {
      map['type'] = type!.trim();
    }
    return map;
  }

  GetTicketsListParams copyWith({
    int? page,
    int? size,
    String? search,
    String? priority,
    String? status,
    String? createdDateFrom,
    String? createdDateTo,
    String? type,
  }) {
    return GetTicketsListParams(
      page: page ?? this.page,
      size: size ?? this.size,
      search: search ?? this.search,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdDateFrom: createdDateFrom ?? this.createdDateFrom,
      createdDateTo: createdDateTo ?? this.createdDateTo,
      type: type ?? this.type,
    );
  }
}
