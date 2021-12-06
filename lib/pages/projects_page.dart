import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:budget_web/data/model/pagination.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:budget_web/widgets/project_page/project_list.dart';
import 'package:budget_web/widgets/project_page/project_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class ProjectPod {
  final queryData = AutoDisposeChangeNotifierProvider((ref) => QueryData());
  late final AutoDisposeFutureProviderFamily<Pagination<Project>, QueryData> projectPagePod;
  late final StateProvider<Map<String, Project>> projectStore;
  late final AutoDisposeStateProvider<Project?> currentProject;

  ProjectPod() {
    currentProject = StateProvider.autoDispose((r) => null);
    projectStore = StateProvider((r) => <String, Project>{});
    projectPagePod = FutureProvider.autoDispose.family<Pagination<Project>, QueryData>((ref, i) async {
      final userId = MyApp.dataStore.account!.user.id;
      final projects = await MyApp.api.getProjects(userId: userId).then((res) {
        if (!res.isSuccessful) {
          print('failed(${res.statusCode}): ${res.error}');
          throw res.error!;
        }
        return res.body!;
      });
      print('got');
      final map = ref.read(projectStore);
      for (final project in projects.data) map[project.id!] = project;
      ref.read(projectStore.state).state = map;
      MyApp.dataStore.account!.projects.addAll(map);
      print('Map: $map');
      return projects;
    });
  }
}

class Projects extends StatefulWidget {
  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  final _pod = ProjectPod();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final qd = MyApp.podRef.read(_pod.queryData);
    MyApp.podRef.read(_pod.projectPagePod(qd));
  }

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      final qd = MyApp.podRef.read(_pod.queryData);
      final value = MyApp.podRef.read(_pod.projectPagePod(qd));
      if (value is AsyncLoading) return;
      if (value is AsyncError) {
        _pod.projectPagePod(qd..update());
        return;
      }
      final data = value.asData!.value;

      if (!data.hasNextPage) return;
      qd.page++;
      _pod.projectPagePod(qd); // update the pod
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final qd = ref.watch(_pod.queryData);
      final query = ref.watch(_pod.projectPagePod(qd));

      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.beamBack()),
          backgroundColor: Theme.of(context).primaryColorDark,
          title: Text('Projects'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () => MyApp.dataStore.logout(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Row(
          children: [
            Flexible(
              flex: 2,
              child: query.map(
                data: (d) => ProjectList(
                  state: _pod,
                  queryData: qd,
                ),
                error: (e) => Center(
                  child: Text(
                    'Error: $e',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                loading: (x) => SizedBox(
                  width: 400,
                  height: 400,
                  child: RiveAnimation.asset(
                    'assets/loading_F.riv',
                    animations: const ['Animation 2'],
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 0,
              endIndent: 0,
              indent: 0,
            ),
            Expanded(
              child: Builder(builder: (context) {
                final project = ref.watch(_pod.currentProject);
                if (project == null) return Center(child: Text('No project selected'));

                return ProjectView(
                  key: ValueKey(project.id),
                  project: project,
                  state: _pod,
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
