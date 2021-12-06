import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MakeMeRich extends ConsumerWidget {
  final Project currentProject;
  final void Function(Project) onUpdate;

  MakeMeRich({
    Key? key,
    required this.currentProject,
    required this.onUpdate,
  })  : assert(currentProject.hasBudget),
        super(key: key);

  final _pod = StateProvider((ref) => 'Make Me Rich! (maybe)');

  @override
  Widget build(BuildContext context, final ref) {
    return ElevatedButton(
      onPressed: () async {
        final response = await MyApp.api.makeMeRich(currentProject.id!);

        final state = ref.read(_pod.state);
        if (!response.isSuccessful) {
          state.state = 'Sorry, try again!';
        } else {
          final data = response.body!;
          onUpdate(data);
          state.state = data.budget.toStringAsFixed(2);
        }

        await Future.delayed(const Duration(seconds: 3));
        state.state = 'Make Me Rich! (maybe)';
      },
      child: Text(ref.watch(_pod)),
    );
  }
}
