import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showProjectPopup(BuildContext context) async {
  final name = TextEditingController(text: 'New Project');
  final budget = TextEditingController(text: '0');
  final budgetFocus = FocusNode()
    ..addListener(() {
      if (budget.text == '0') budget.selection = TextSelection(baseOffset: 0, extentOffset: 1, isDirectional: false);
    });
  final nameFocus = FocusNode()
    ..addListener(() {
      if (name.text == 'New Project')
        name.selection = TextSelection(baseOffset: 0, extentOffset: 11, isDirectional: false);
    });

  final hasNoBudget = StateProvider.autoDispose((ref) => true);
  final error = StateProvider.autoDispose<String?>((_) => null);

  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create a Project'),
            content: SizedBox(
              height: 180,
              child: Consumer(
                builder: (context, ref, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          autofocus: true,
                          controller: name,
                          focusNode: nameFocus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Project Name',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: budget,
                          inputFormatters: [
                            TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) {
                              final oldValueValid = RegExp(r'^\d+(\.\d+)$').hasMatch(oldValue.text);
                              final newValueValid = RegExp(r'^\d+(\.\d{0,2})$').hasMatch(newValue.text);
                              if (oldValueValid && !newValueValid) return oldValue;
                              return newValue;
                            }),
                          ],
                          focusNode: budgetFocus,
                          validator: (s) => double.tryParse(s ?? '') == null ? "Invalid number" : null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: r'Budget',
                            prefix: Text(r'$'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            return Row(
                              children: [
                                const Text('No budget: '),
                                Checkbox(
                                  value: ref.watch(hasNoBudget),
                                  tristate: false,
                                  onChanged: (bool? value) {
                                    final state = ref.read(hasNoBudget.state);
                                    state.state = value!;
                                  },
                                ),
                              ],
                            );
                          },
                          child: const Text('Has a budget: '),
                        ),
                        if (ref.watch(error) != null) Text(ref.watch(error)!),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                      onPressed: () async {
                        ref.read(error.state).state = null;
                        final store = MyApp.dataStore;

                        final res = await MyApp.api.createProject(Project(
                          name: name.text,
                          budget: double.parse(budget.text),
                          hasBudget: !ref.read(hasNoBudget),
                          ownerId: store.account!.user.id!,
                        ));

                        if (!res.isSuccessful) {
                          ref.read(error.state).state = res.error?.toString();
                          return;
                        }

                        final proj = res.body!;
                        store.account!.projects[proj.project.id!] = proj.project;

                        Navigator.of(context).pop(true);
                      },
                      child: child);
                },
                child: Text('Create'),
              ),
            ],
          );
        },
      ) ??
      false;
}
