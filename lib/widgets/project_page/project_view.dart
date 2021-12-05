import 'package:budget_web/data/model/pagination.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/data/model/user.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:budget_web/pages/projects_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class ProjectView extends StatefulWidget {
  final Project project;
  final ProjectPod state;

  const ProjectView({
    Key? key,
    required this.project,
    required this.state,
  }) : super(key: key);

  @override
  State<ProjectView> createState() => _ProjectViewState();
}

class _ProjectViewPod {
  late final StateProvider<Map<String, User>> usersStore;
  late StateProvider<Project> projectStore;
  late final StateProvider<Map<String, Purchase>> purchasesStore;
  late final FutureProviderFamily<Pagination<User>, QueryData> usersFetcher;
  late final FutureProviderFamily<Pagination<Purchase>, QueryData> purchaseFetcher;

  static createProjectStore(Project project) => StateProvider((ref) => project);

  _ProjectViewPod(Project proj) {
    projectStore = createProjectStore(proj);
    usersStore = StateProvider((r) => <String, User>{});
    purchasesStore = StateProvider((r) => <String, Purchase>{});
    usersFetcher = FutureProvider.family<Pagination<User>, QueryData>((ref, q) async {
      final project = ref.watch(projectStore);

      final res = await MyApp.api.getUsers(count: q.count, page: q.page, projectId: project.id!).then((res) {
        if (res.isSuccessful) return res.body!;
        throw res.error!;
      });

      final state = ref.read(usersStore.state);
      final map = Map.of(state.state);
      for (final user in res.data) map[user.id!] = user;
      state.state = map;
      print(state.state);
      return res;
    });
    purchaseFetcher = FutureProvider.family<Pagination<Purchase>, QueryData>((ref, q) async {
      final project = ref.watch(projectStore);

      final res = await MyApp.api
          .getPurchases(
        count: q.count,
        page: q.page,
        projectId: project.id!,
      )
          .then((res) {
        if (res.isSuccessful) return res.body!;
        throw res.error!;
      });

      final state = ref.read(purchasesStore.state);
      final map = Map.of(state.state);
      for (final purchase in res.data) map[purchase.id!] = purchase;
      state.state = map;
      print(state.state);
      return res;
    });
  }
}

class _ProjectViewState extends State<ProjectView> {
  late TextEditingController _controller;
  late final _pod = _ProjectViewPod(widget.project);
  var _queryData = QueryData()..page = 0;
  var _purchaseQueryData = QueryData()..page = 0;

  ScrollController _usersController = ScrollController();
  ScrollController _purchasesController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.project.name;

    _usersController.addListener(() => _onScroll(_pod.usersFetcher, _queryData, _usersController));
    _purchasesController.addListener(() => _onScroll(_pod.purchaseFetcher, _purchaseQueryData, _purchasesController));

    MyApp.podRef.read(_pod.usersFetcher(_queryData));
    MyApp.podRef.read(_pod.purchaseFetcher(_purchaseQueryData));
  }

  void _onScroll(
    FutureProviderFamily<Pagination<dynamic>, QueryData> pod,
    QueryData data,
    ScrollController controller,
  ) {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      final value = MyApp.podRef.read(pod(data));
      assert(value is AsyncData, "Value was not async data");
      final pageData = value.asData!.value;
      if (!pageData.hasNextPage) return;
      data.page = (data.page ?? 0) + 1;
      pod(data);
    }
  }

  @override
  void didUpdateWidget(covariant ProjectView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _pod.projectStore = _ProjectViewPod.createProjectStore(widget.project);
      _controller.text = widget.project.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final pagination = ref.watch(_pod.usersFetcher(_queryData));
      final userMap = ref.watch(_pod.usersStore);
      final userList = userMap.values.toList();

      final purchasePagination = ref.watch(_pod.purchaseFetcher(_purchaseQueryData));
      final purchaseMap = ref.watch(_pod.purchasesStore);
      final purchaseList = purchaseMap.values.toList();

      final purchaseListView = ListView.builder(
        controller: _purchasesController,
        itemCount: purchaseList.length,
        itemBuilder: (context, item) {
          final purchase = purchaseList[item];
          User? user = userMap[purchase.userId];

          return ListTile(
            title: Text(purchase.name),
            subtitle: Text("Purchased by ${user == null ? "Unknown" : user.username} on ${purchase.datePurchased.toLocal().toString()}"),
            trailing: Text('\$${purchase.purchasePrice.toString()}'),
            isThreeLine: true,
          );
        },
      );

      final list = ListView.builder(
        controller: _usersController,
        itemCount: userMap.length,
        itemBuilder: (context, index) {
          final user = userList[index];

          return ListTile(title: Text(user.username));
        },
      );

      return Column(
        children: [
          // A text field to edit the name of the project
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final response = await MyApp.api.updateProject(
                      id: widget.project.id!,
                      project: widget.project..name = _controller.text,
                    );

                    print('Got response: ${response.statusCode}');

                    final msgnr = ScaffoldMessenger.of(context);
                    if (response.isSuccessful) {
                      final state = ref.watch(widget.state.projectStore.state);
                      final map = Map.of(state.state);
                      map[widget.project.id!] = widget.project..name = _controller.text;
                      state.state = map;

                      msgnr.showSnackBar(SnackBar(content: Text('Project updated')));
                    } else {
                      msgnr.showSnackBar(SnackBar(content: Text('Error updating project')));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final name = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: SingleChildScrollView(
                          child: TextField(
                            autofocus: true,
                            controller: name,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text('Add'),
                            onPressed: () async {
                              final response = await MyApp.api.joinProject(
                                projectId: widget.project.id!,
                                username: name.text,
                              );

                              if (response.isSuccessful) {
                              final body = response.body!;
                                final state = ref.read(_pod.usersStore.state);
                                final map = Map.of(state.state);
                                map[body.union.userId] = body.user;
                                state.state = map;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User added')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding user')));
                              }
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Invite user'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () async {
                    if (!await _areYouSure()) return;

                    final response = await MyApp.api.deleteProject(widget.project.id!);

                    if (response.isSuccessful) {
                      final state = ref.read(widget.state.projectStore.state);
                      final map = Map.of(state.state);
                      map.remove(widget.project.id!);
                      state.state = map;

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project deleted')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting project')));
                    }
                  },
                  child: const Text('Delete Project'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: (userMap.isEmpty)
                ? pagination.map(
                    loading: (_) => RiveAnimation.asset('loading_F.riv', animations: const ['Animation 1']),
                    error: (error) => Text('Error: $error'),
                    data: (data) => list,
                  )
                : list,
          ),
          const Divider(height: 0),
          Expanded(
            child: (purchaseMap.isEmpty)
                ? purchasePagination.map(
                    data: (x) => purchaseListView,
                    loading: (_) => RiveAnimation.asset('loading_F.riv', animations: const ['Animation 1']),
                    error: (error) => Center(child: Text('Error: $error')),
                  )
                : purchaseListView,
          )
        ],
      );
    });
  }

  Future<bool> _areYouSure() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  child: const Text('Remove'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
