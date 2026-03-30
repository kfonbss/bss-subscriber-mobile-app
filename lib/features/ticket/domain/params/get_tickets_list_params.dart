class GetTicketsListParams {
  final int page;
  final int size;
  final String? search;

  const GetTicketsListParams({
    this.page = 0,
    this.size = 10,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'size': size,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    };
  }

  GetTicketsListParams copyWith({
    int? page,
    int? size,
    String? search,
  }) {
    return GetTicketsListParams(
      page: page ?? this.page,
      size: size ?? this.size,
      search: search ?? this.search,
    );
  }
}
