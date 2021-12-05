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
  static decode<T>(dynamic value) {
    if (T == dynamic) return value;

    print('decoding<$T>: $value');
    for (final t in [String, double, int, bool])
      if (t == T && value is T) return value;

    assert(value is Map<String, dynamic>, 'Value is not a Map');
    if (value is List) return value.map((x) => ModelCodec.decode<T>(x)).toList();
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
      case Pagination<Item>:
        return Pagination<Item>.fromMap(value);
      case Pagination<Project>:
        return Pagination<Project>.fromMap(value);
      case Pagination<User>:
        return Pagination<User>.fromMap(value);
      case Pagination<JoinedProject>:
        return Pagination<JoinedProject>.fromMap(value);
      case Pagination<Purchase>:
        return Pagination<Purchase>.fromMap(value);
      case Project:
        return Project.fromMap(value);
      case AuthBody:
        return AuthBody.fromMap(value);
    }

    print('Unknown type: $T');
    throw "unable to deserialize";
  }

  static encode(dynamic value) {
    print('value: $value, ${value == null}');
    if (value is List) return value.map(encode).toList();
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
      case Pagination<Item>:
        return (value as Pagination<Item>).toMap();
      case Pagination<Project>:
        return (value as Pagination<Project>).toMap();
      case Pagination<User>:
        return (value as Pagination<User>).toMap();
      case Pagination<JoinedProject>:
        return (value as Pagination<JoinedProject>).toMap();
      case Pagination<Purchase>:
        return (value as Pagination<Purchase>).toMap();
      case Project:
        return (value as Project).toMap();
      case AuthBody:
        return (value as AuthBody).toMap();
    }
  }

  static List<T> decodeList<T>(dynamic value) {
    assert(value is List, 'Value is not a List');
    return (value as List).map<T>((e) => decode<T>(e)).toList();
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    final json = super.convertResponse(response);
    print(json.body);
    return json.copyWith<BodyType>(body: decode<BodyType>(json.body));
  }

  @override
  Request convertRequest(Request request) {
    dynamic json = encode(request.body);
    return super.convertRequest(request.copyWith(body: json));
  }
}
