import 'package:budget_web/data/model/account_data.dart';
import 'package:budget_web/data/model/auth_body.dart';
import 'package:budget_web/data/model/cart_item.dart';
import 'package:budget_web/data/model/item.dart';
import 'package:budget_web/data/model/joined_project.dart';
import 'package:budget_web/data/model/pagination.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/project_user_union.dart';
import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/data/model/purchase_data.dart';
import 'package:budget_web/data/model/user.dart';
import 'package:chopper/chopper.dart';

class ModelCodec extends JsonConverter {
  // Example pagination types to check against Pagination<T>
  static final _paginationItem = Pagination<Item>(page: 0, data: [], hasNextPage: false, hasPreviousPage: false, pageSize: 0);
  static final _paginationProject = Pagination<Project>(page: 0, data: [], hasNextPage: false, hasPreviousPage: false, pageSize: 0);
  static final _paginationUser = Pagination<User>(page: 0, data: [], hasNextPage: false, hasPreviousPage: false, pageSize: 0);
  static final _paginationJoinedProject = Pagination<JoinedProject>(page: 0, data: [], hasNextPage: false, hasPreviousPage: false, pageSize: 0);
  static final _paginationPurchase = Pagination<Purchase>(page: 0, data: [], hasNextPage: false, hasPreviousPage: false, pageSize: 0);

  // Turns json into a data class
  static decode<T, I>(dynamic value) {
    if (T == dynamic) return value;

    print('decoding<$T>: $value');
    for (final t in [String, double, int, bool]) if (t == T && value is T) return value;

    assert(value is Map<String, dynamic>, 'Value is not a Map');

    if (_paginationItem.runtimeType == T) return Pagination<Item>.fromMap(value);
    if (_paginationProject.runtimeType == T) return Pagination<Project>.fromMap(value);
    if (_paginationUser.runtimeType == T) return Pagination<User>.fromMap(value);
    if (_paginationJoinedProject.runtimeType == T) return Pagination<JoinedProject>.fromMap(value);
    if (_paginationPurchase.runtimeType == T) return Pagination<Purchase>.fromMap(value);

    if (value is List) return value.map((x) => ModelCodec.decode<T, I>(x)).toList();
    switch (T) {
      case int:
        return value as int;
      case String:
        return value as String;
      case bool:
        return value as bool;
      case double:
        return value as double;
      case DateTime:
        return DateTime.parse(value as String);
      case AccountData:
        return AccountData.fromMap(value);
      case PurchaseData:
        return PurchaseData.fromMap(value);
      case Purchase:
        return Purchase.fromMap(value);
      case User:
        return User.fromMap(value);
      case CartItem:
        return CartItem.fromMap(value);
      case JoinedProject:
        return JoinedProject.fromMap(value);
      case ProjectUserUnion:
        return ProjectUserUnion.fromMap(value);
      case Item:
        return Item.fromMap(value);
      case Project:
        return Project.fromMap(value);
      case AuthBody:
        return AuthBody.fromMap(value);
    }

    print('Unknown type: $T');
    throw "unable to deserialize";
  }

  // Turns a model into json
  static encode(dynamic value) {
    print('value: $value, ${value == null}');
    if (value is List) return value.map(encode).toList();
    if (value is Pagination<Item>) return value.toMap();
    if (value is Pagination<Project>) return value.toMap();
    if (value is Pagination<User>) return value.toMap();
    if (value is Pagination<JoinedProject>) return value.toMap();
    if (value is Pagination<Purchase>) return value.toMap();
    switch (value.runtimeType) {
      case String:
      case int:
      case double:
      case bool:
        return value;
      case Purchase:
        return (value as Purchase).toMap();
      case DateTime:
        return (value as DateTime).toIso8601String();
      case User:
        return (value as User).toMap();
      case AccountData:
        return (value as AccountData).toMap();
      case PurchaseData:
        return (value as PurchaseData).toMap();
      case CartItem:
        return (value as CartItem).toMap();
      case ProjectUserUnion:
        return (value as ProjectUserUnion).toMap();
      case JoinedProject:
        return (value as JoinedProject).toMap();
      case Item:
        return (value as Item).toMap();
      case Project:
        return (value as Project).toMap();
      case AuthBody:
        return (value as AuthBody).toMap();
    }
  }

  // Decodes a json list into a model list
  static List<T> decodeList<T, I>(dynamic value) {
    assert(value is List, 'Value is not a List');
    return (value as List).map<T>((e) => decode<T, I>(e)).toList();
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    final json = super.convertResponse(response); // convert the response body to json
    print(json.body); // log the json
    final converted = decode<BodyType, InnerType>(json.body); // convert to models
    return json.copyWith<BodyType>(body: converted); // return to request
  }

  @override
  Request convertRequest(Request request) {
    dynamic json = encode(request.body); // Turn the model into json
    return super.convertRequest(request.copyWith(body: json)); // return the transformed request
  }
}
