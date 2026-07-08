class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.meta});

  PaginatedResponse.fromJson(Map<String, dynamic> meta, this.data)
      : meta = PaginationMeta.fromJson(meta);
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta(
      {required this.currentPage,
      required this.lastPage,
      required this.perPage,
      required this.total});

  bool get canGetNext => currentPage < lastPage;

  PaginationMeta.fromJson(Map<String, dynamic> json)
      : currentPage = json['current_page'],
        lastPage = json['last_page'],
        perPage = json['per_page'],
        total = json['total'];
}
