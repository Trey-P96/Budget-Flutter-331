import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class MarketItemList extends ConsumerWidget {
  final MarketPod state;
  final ScrollController? controller;
  final QueryData queryData;

  const MarketItemList({
    Key? key,
    required this.state,
    required this.queryData,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context, final ref) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final items = ref.watch(state.itemPod);

    return ref.watch(state.marketFetchingPod(queryData)).map(
        error: (e) => Center(child: Text('Error: $e')),
        loading: (x) {
          return RiveAnimation.asset(
            'assets/loading_F.riv',
            animations: const ['Animation 1'],
          );
        },
        data: (d) {
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Color.lerp(Colors.black, theme.dividerColor, 0.75)!,
                ),
              ),
            ),
            child: Center(
              child: ListView.builder(
                controller: controller,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  final purchaseMap = ref.watch(state.purchasePod);
                  int numInCart = 0;
                  for (final list in purchaseMap.values) for (final purchase in list) if (purchase.itemId == item.id) numInCart++;

                  final tile = ListTile(
                    dense: true,
                    leading: Icon(Icons.shopping_cart),
                    title: Text(item.name, style: const TextStyle(fontSize: 16)),
                    subtitle: Text('Number in cart: $numInCart'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: numInCart == 0
                              ? null
                              : () {
                                  final map = Map.of(ref.read(state.purchasePod));

                                  if (!map.containsKey(item.id!)) return;

                                  final list = map[item.id!]!..removeLast();

                                  if (list.isEmpty)
                                    map.remove(item.id!);
                                  else
                                    map[item.id!] = list;

                                  ref.read(state.purchasePod.state).state = map;
                                },
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: () {
                            final map = Map.of(ref.read(state.purchasePod));
                            final currentProject = ref.read(state.currentProjectPod);
                            final account = MyApp.dataStore.account!;

                            final list = map[item.id!] ??= [];
                            list.add(
                              Purchase(
                                name: item.name,
                                itemId: item.id!,
                                datePurchased: DateTime.now(),
                                projectId: currentProject!.id!,
                                purchasePrice: item.price,
                                userId: account.user.id!,
                              ),
                            );

                            map[item.id!] = list;

                            ref.read(state.purchasePod.state).state = map;
                          },
                          icon: const Icon(Icons.add),
                        ),
                        Center(
                          child: Text('\$${item.price.toString()}'),
                        ),
                      ],
                    ),
                  );

                  return DecoratedBox(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
                    child: Draggable(
                      data: item,
                      childWhenDragging: Opacity(
                        opacity: .5,
                        child: tile,
                      ),
                      feedback: Material(
                        color: Colors.white.withOpacity(0.5),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                            width: mq.size.width / 2,
                          ),
                          child: Opacity(
                            opacity: .5,
                            child: tile,
                          ),
                        ),
                      ),
                      child: tile,
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
