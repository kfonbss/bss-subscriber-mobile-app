class GetTicketsListParams {
  final int page;
  final int size;

  const GetTicketsListParams({
    this.page = 0,
    this.size = 10,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'size': size,
    };
  }

  GetTicketsListParams copyWith({
    int? page,
    int? size,
  }) {
    return GetTicketsListParams(
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }
}
