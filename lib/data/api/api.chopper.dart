// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$Api extends Api {
  _$Api([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = Api;

  @override
  Future<Response<User>> createUser(User user) {
    final $url = 'https://budget-api-331.herokuapp.com/users/';
    final $body = user;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<User, User>($request);
  }

  @override
  Future<Response<AccountData>> login(AuthBody body) {
    final $url = 'https://budget-api-331.herokuapp.com/auth';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<AccountData, AccountData>($request);
  }

  @override
  Future<Response<String>> logout(String id) {
    final $url = 'https://budget-api-331.herokuapp.com/auth/${id}';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<String, String>($request);
  }

  @override
  Future<Response<Pagination<Item>>> getItems({int? count, int? page}) {
    final $url = 'https://budget-api-331.herokuapp.com/items';
    final $params = <String, dynamic>{'count': count, 'page': page};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Pagination<Item>, Item>($request);
  }

  @override
  Future<Response<JoinedProject>> createProject(Project project) {
    final $url = 'https://budget-api-331.herokuapp.com/projects';
    final $body = project;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<JoinedProject, JoinedProject>($request);
  }

  @override
  Future<Response<PurchaseData>> createPurchases(List<Purchase> purchase) {
    final $url = 'https://budget-api-331.herokuapp.com/purchases/many';
    final $body = purchase;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<PurchaseData, PurchaseData>($request);
  }

  @override
  Future<Response<Project>> makeMeRich(String projectId) {
    final $url =
        'https://budget-api-331.herokuapp.com/projects/${projectId}/make-me-rich';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<Project, Project>($request);
  }

  @override
  Future<Response<Pagination<Project>>> getProjects(
      {int? count, int? page, String? userId}) {
    final $url = 'https://budget-api-331.herokuapp.com/projects';
    final $params = <String, dynamic>{
      'count': count,
      'page': page,
      'userId': userId
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Pagination<Project>, Project>($request);
  }

  @override
  Future<Response<Pagination<User>>> getUsers(
      {int? count, int? page, String? projectId}) {
    final $url = 'https://budget-api-331.herokuapp.com/users';
    final $params = <String, dynamic>{
      'count': count,
      'page': page,
      'projectId': projectId
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Pagination<User>, User>($request);
  }

  @override
  Future<Response<Project>> updateProject(
      {required String id, required Project project}) {
    final $url = 'https://budget-api-331.herokuapp.com/projects/${id}';
    final $body = project;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<Project, Project>($request);
  }

  @override
  Future<Response<dynamic>> deleteProject(String id) {
    final $url = 'https://budget-api-331.herokuapp.com/projects/${id}';
    final $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Pagination<Purchase>>> getPurchases(
      {int? count, int? page, String? projectId}) {
    final $url = 'https://budget-api-331.herokuapp.com/purchases';
    final $params = <String, dynamic>{
      'count': count,
      'page': page,
      'projectId': projectId
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Pagination<Purchase>, Purchase>($request);
  }

  @override
  Future<Response<JoinedProject>> joinProject(
      {required String username, required String projectId}) {
    final $url =
        'https://budget-api-331.herokuapp.com/projects/${projectId}/join/${username}';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<JoinedProject, JoinedProject>($request);
  }
}
