import 'package:budget_web/data/api/converter.dart';
import 'package:budget_web/data/model/account_data.dart';
import 'package:budget_web/data/model/auth_body.dart';
import 'package:budget_web/data/model/item.dart';
import 'package:budget_web/data/model/joined_project.dart';
import 'package:budget_web/data/model/pagination.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/data/model/purchase_data.dart';
import 'package:budget_web/data/model/user.dart';
import 'package:chopper/chopper.dart';

part 'api.chopper.dart';

// The /users resource on the api
@ChopperApi(baseUrl: "http://localhost:8888")
abstract class Api extends ChopperService {
  @Post(path: '/users/')
  Future<Response<User>> createUser(@Body() User user);

  @Post(path: '/auth')
  Future<Response<AccountData>> login(@Body() AuthBody body);

  @Post(path: '/auth/{id}', optionalBody: true)
  Future<Response<String>> logout(@Path('id') String id);

  @Get(path: "/items")
  Future<Response<Pagination<Item>>> getItems({
    @Query("count") int? count,
    @Query("page") int? page,
  });

  @Post(path: '/projects')
  Future<Response<JoinedProject>> createProject(@Body() Project project);

  @Post(path: '/purchases/many')
  Future<Response<PurchaseData>> createPurchases(@Body() List<Purchase> purchase);

  @Post(path: '/projects/{id}/make-me-rich')
  Future<Response<Project>> makeMeRich(@Path('id') String id);

  @Get(path: '/projects')
  Future<Response<Pagination<Project>>> getProjects({
    @Query("count") int? count,
    @Query("page") int? page,
    @Query("userId") String? userId,
  });

  @Get(path: '/users')
  @Header()
  Future<Response<Pagination<User>>> getUsers({
    @Query("count") int? count,
    @Query("page") int? page,
    @Query("projectId") String? projectId,
  });

  @Post(path: '/projects/{id}')
  Future<Response<Project>> updateProject({
    @Path('id') required String id,
    @Body() required Project project,
  });

  @Delete(path: '/projects/{id}')
  Future<Response> deleteProject(@Path('id') String id);

  @Get(path: '/purchases')
  Future<Response<Pagination<Purchase>>> getPurchases({
    @Query("count") int? count,
    @Query("page") int? page,
    @Query("projectId") String? projectId,
  });

  @Post(path: '/projects/{projectId}/join/{username}')
  Future<Response<JoinedProject>> joinProject({
    @Path('username') required String username,
    @Path('projectId') required String projectId,
  });

  Api();

  /// Creates the instance with the converter for Built Value serialization
  factory Api.create() {
    final client = ChopperClient(
      baseUrl: 'http://localhost:8888',
      converter: ModelCodec(),
      interceptors: <RequestInterceptor>[HttpLoggingInterceptor()],
    );
    return _$Api(client);
  }
}
