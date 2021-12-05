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

// class SimpleAnimation extends StatelessWidget {
//   const SimpleAnimation({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: RiveAnimation.asset(
//           'assets/loading.riv',
//         ),
//       ),
//     );
//   }
// }
class PlayOneShotAnimation extends StatefulWidget {
  const PlayOneShotAnimation({Key? key}) : super(key: key);

  @override
  _PlayOneShotAnimationState createState() => _PlayOneShotAnimationState();
}

class _PlayOneShotAnimationState extends State<PlayOneShotAnimation> {
  /// Controller for playback
  late RiveAnimationController _controller;

  /// Is the animation currently playing?
  bool _isPlaying = false;

  Completer<void> _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = OneShotAnimation(
      'Animation 2',
      autoplay: false,
      onStop: () => setState(() => _completer.complete()),
      onStart: () => setState(() => _completer = Completer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Shot Example'),
      ),
      body: Center(
        child: RiveAnimation.asset(
          'assets/loading_F.riv',
          animations: const [],
          controllers: [_controller],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // disable the button while playing the animation
        onPressed: () => _isPlaying ? null : _controller.isActive = true,
        tooltip: 'Play',
        child: const Icon(Icons.arrow_upward),
      ),
    );
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
    MyApp.podRef.read(_pod.projectPagePod(_queryData));
  }

  QueryData _queryData = QueryData()..page = 0;

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      final value = MyApp.podRef.read(_pod.projectPagePod(_queryData));
      assert(value is AsyncData, "Value was not async data");
      final data = value.asData!.value;

      if (!data.hasNextPage) return;
      _queryData = QueryData()
        ..count = _queryData.count
        ..page = (_queryData.page ?? 0) + 1;
      _pod.projectPagePod(_queryData); // update the pod
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
      final query = ref.watch(_pod.projectPagePod(_queryData));

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
                  queryData: _queryData,
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
