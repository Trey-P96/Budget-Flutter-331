import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:budget_web/widgets/create_project_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectList extends ConsumerWidget {
  final MarketPod state;

  const ProjectList({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context, final ref) {
    final projects = MyApp.dataStore.account!.projects;

    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: ElevatedButton(
          onPressed: () async {
            await showProjectPopup(context);

            final account = MyApp.dataStore.account!;
            if (account.projects.isNotEmpty) ref.read(state.currentProjectPod.state).state = account.projects.first;
          },
          child: const Text('Create a project'),
        ),
      );
    }

    final currentProject = ref.watch(state.currentProjectPod);
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];

        return DecoratedBox(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: ListTile(
            dense: true,
            trailing: project == currentProject ? Icon(Icons.star, color: Colors.orange) : null,
            onTap: () {
              ref.read(state.currentProjectPod.state).state = project;
              ref.read(state.purchasePod.state).state = {};
            },
            title: Text(project.name),
            subtitle: Text(project.hasBudget ? 'Budget: \$${project.budget}' : 'Unlimited budget'),
          ),
        );
      },
    );
  }
}