import 'package:budget_web/data/model/item.dart';
import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class ProjectPane extends ConsumerWidget {
  final MarketPod state;

  final _loadingPod = StateProvider<bool>((_) => false);

  ProjectPane({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context, final ref) {
    final currentProject = ref.watch(state.currentProjectPod);
    final itemPurchaseMap = ref.watch(state.purchasePod);
    final purchaseLists = itemPurchaseMap.values.toList();

    if (currentProject == null) return ListTile(title: Text('No project selected'));

    final cost = ref.watch(state.costPod);
    double postCost = currentProject.budget - cost;
    final budget = currentProject.budget;

    return DragTarget<Item>(
      onAccept: (item) {
        final account = MyApp.dataStore.account!;
        final currentProject = ref.read(state.currentProjectPod);

        final purchase = Purchase(
          userId: account.user.id!,
          itemId: item.id!,
          projectId: currentProject!.id!,
          datePurchased: DateTime.now(),
          name: item.name,
          purchasePrice: item.price,
        );

        final records = Map.of(ref.read(state.purchasePod));
        // Get list and set records[item.id] to an empty list if it is null
        final list = records[item.id!] ??= [];
        list.add(purchase);
        records[item.id!] = list;
        ref.read(state.purchasePod.state).state = records;
      },
      builder: (context, acc, den) => Column(
        children: [
          ListTile(
            title: Text('Project: ${currentProject.name}'),
            subtitle: !currentProject.hasBudget
                ? null
                : Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                      const TextSpan(text: ' | '),
                      TextSpan(
                        text: '${postCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: postCost < 0 ? Colors.red : Color.lerp(Colors.red, Colors.green, postCost / budget),
                          fontWeight: postCost < 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const TextSpan(text: ' | '),
                      TextSpan(text: '${currentProject.budget}'),
                    ]),
                  ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: purchaseLists.length,
              itemBuilder: (context, index) {
                final records = purchaseLists[index];
                final name = records.first.name;

                return ExpansionTile(
                  title: Text("$name (${records.length})"),
                  children: [
                    for (final purchase in records)
                      ListTile(
                        title: Text(purchase.datePurchased.toString()),
                        subtitle: Text('${purchase.purchasePrice}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final records = ref.read(state.purchasePod.state);
                            final map = Map.of(records.state);
                            final list = map[purchase.itemId]!;
                            list.remove(purchase);

                            if (list.isNotEmpty)
                              map[purchase.itemId] = list;
                            else
                              map.remove(purchase.itemId);

                            records.state = map;
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: Theme.of(context).primaryColor,
              child: InkWell(
                child: Center(
                  child: ref.read(_loadingPod)
                      ? RiveAnimation.asset('loading_F.riv', animations: const ['Animation 1'])
                      : const Text(
                          'Purchase',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                onTap: ref.watch(_loadingPod) == true
                    ? null
                    : () async {
                        final cost = ref.read(state.costPod);
                        final project = ref.read(state.currentProjectPod)!;

                        if (project.hasBudget && cost > project.budget) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You cannot item more than your budget'),
                            ),
                          );
                          return;
                        }

                        final records = ref.read(state.purchasePod);
                        final purchases = <Purchase>[];
                        for (final list in records.values) purchases.addAll(list);

                        ref.read(_loadingPod.state).state = true;
                        final response = await MyApp.api.createPurchases(purchases);
                        ref.read(_loadingPod.state).state = false;

                        if (!response.isSuccessful) {
                          print(response.statusCode);
                          print(response.error);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to purchases items')));
                          return;
                        }

                        final data = response.body!;
                        final projectState = ref.read(state.currentProjectPod.state);
                        ref.read(state.purchasePod.state).state = {};
                        final pj = projectState.state!;
                        pj.budget = data.budget;
                        projectState.state = null;
                        projectState.state = pj;

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchased ${data.purchased.length} items')));
                      },
              ),
            ),
          )
        ],
      ),
    );
  }
}
