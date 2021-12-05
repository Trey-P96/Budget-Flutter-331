import 'package:budget_web/data/api/converter.dart';

class Pagination<T> {
  List<T> data;
  int page;
  int pageSize;
  bool hasNextPage;
  bool hasPreviousPage;

  Pagination({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': this.data,
      'page': this.page,
      'pageSize': this.pageSize,
      'hasNextPage': this.hasNextPage,
      'hasPreviousPage': this.hasPreviousPage,
    };
  }

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      data: ModelCodec.decodeList<T, dynamic>(map['data']),
      page: map['page'] as int,
      pageSize: map['pageSize'] as int,
      hasNextPage: map['hasNextPage'] as bool,
      hasPreviousPage: map['hasPreviousPage'] as bool,
    );
  }
}
