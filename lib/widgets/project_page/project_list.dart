import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:budget_web/pages/projects_page.dart';
import 'package:budget_web/widgets/create_project_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectList extends ConsumerWidget {
  const ProjectList({
    Key? key,
    required this.state,
    required this.queryData,
    this.controller,
  }) : super(key: key);

  final ProjectPod state;
  final ScrollController? controller;
  final QueryData queryData;

  @override
  Widget build(final BuildContext context, final ref) {
    final projects = ref.watch(state.projectStore);
    print(projects);
    final fetch = ref.watch(state.projectPagePod(queryData));
    final values = projects.values.toList();
    print(values);

    if (values.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            if (await showProjectPopup(context)) {
              final projects = ref.read(state.projectStore.state);
              final map = Map.of(projects.state);
              final newPj = MyApp.dataStore.account!.projects.last;
              map[newPj.id!] = newPj;
              projects.state = map;
            }
          },
          child: Text('Create a project'),
        ),
      );
    }

    print('Project(${projects.length} - $values)');

    return ListView.builder(
      controller: controller,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = values[index];

        return ListTile(
          title: Text(project.name),
          subtitle: Text(project.hasBudget ? '${project.budget}' : 'No budget'),
          trailing: ref.watch(state.currentProject) == project ? Icon(Icons.star, color: Colors.orange) : null,
          onTap: () => ref.read(state.currentProject.state).state = project,
        );
      },
    );
  }
}
