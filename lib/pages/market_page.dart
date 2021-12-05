//ALT-ENTER
//ctrl-Space
import 'package:beamer/beamer.dart';
import 'package:budget_web/data/model/item.dart';
import 'package:budget_web/data/model/pagination.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/purchase.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/routing/routes.dart';
import 'package:budget_web/widgets/market/item_list.dart';
import 'package:budget_web/widgets/market/make_me_rich.dart';
import 'package:budget_web/widgets/market/project_list.dart';
import 'package:budget_web/widgets/market/project_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueryData {
  int? count;
  int? page;

  QueryData();
}

class MarketPage extends StatefulWidget {
  MarketPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MarketPageState();
  }
}

class MarketPod {
  late final AutoDisposeStateProvider<List<Item>> itemPod;
  late final AutoDisposeStateProvider<Project?> currentProjectPod;
  late final AutoDisposeStateProvider<Map<String, List<Purchase>>> purchasePod;
  late final AutoDisposeFutureProviderFamily<Pagination<Item>, QueryData> marketFetchingPod;
  late final AutoDisposeProvider<double> costPod;

  MarketPod() {
    itemPod = StateProvider.autoDispose<List<Item>>((ref) => <Item>[]);
    currentProjectPod = StateProvider.autoDispose<Project?>((ref) {
      final projs = MyApp.dataStore.account!.projects;
      return projs.isEmpty ? null : projs[projs.keys.elementAt(0)];
    });
    purchasePod = StateProvider.autoDispose<Map<String, List<Purchase>>>((ref) => {});
    marketFetchingPod = FutureProvider.autoDispose.family<Pagination<Item>, QueryData>((r, p) => _getMarketPage(r, p, itemPod));
    costPod = Provider.autoDispose((ref) {
      double cost = 0;
      for (final item in ref.watch(purchasePod).values) for (final purchase in item) cost += purchase.purchasePrice;
      return double.parse(cost.toStringAsFixed(2));
    });
  }

  static Future<Pagination<Item>> _getMarketPage(
    AutoDisposeFutureProviderRef ref,
    QueryData q,
    AutoDisposeStateProvider<List<Item>> itemPod,
  ) async {
    final data = await MyApp.api.getItems(count: q.count, page: q.page).then((x) {
      if (x.isSuccessful) return x.body!;
      print("Error: ${x.error}");
      throw x.error!;
    });
    ref.read(itemPod).addAll(data.data);
    return data;
  }
}

class _MarketPageState extends State<MarketPage> {
  final _pod = MarketPod();

  @override
  void initState() {
    super.initState();
    _pod.marketFetchingPod.call(QueryData()..page = 0);
    _scrollController.addListener(_onScroll);
  }

  final _scrollController = ScrollController();
  var _queryData = QueryData();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final fetchingData = ref.watch(_pod.marketFetchingPod(_queryData));
      final currentProject = ref.watch(_pod.currentProjectPod);

      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.beamBack()),
          backgroundColor: Theme.of(context).primaryColorDark,
          //title: Text("Signed in as: $userName"),
          title: Text('Market'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => MyApp.dataStore.logout(),
            ),
            if (currentProject != null && currentProject.hasBudget)
              MakeMeRich(
                currentProject: currentProject,
                onUpdate: (x) {
                  final state = ref.read(_pod.currentProjectPod.state);
                  final p = state.state!..budget = x.budget;
                  state.state = null;
                  state.state = p;
                },
              ),
            if (fetchingData is AsyncLoading)
              SizedBox.square(
                dimension: 48,
                child: CircularProgressIndicator(),
              )
            else if (fetchingData is AsyncError)
              SizedBox.square(
                dimension: 48,
                child: Icon(Icons.close, color: Theme.of(context).disabledColor),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, layout) {
            return SizedBox(
              height: layout.maxHeight,
              child: Row(
                children: [
                  Expanded(child: ProjectList(state: _pod)),
                  Flexible(
                    flex: 2,
                    child: MarketItemList(
                      state: _pod,
                      queryData: _queryData,
                      controller: _scrollController,
                    ),
                  ),
                  Expanded(child: ProjectPane(state: _pod)),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      final value = MyApp.podRef.read(_pod.marketFetchingPod.call(_queryData));
      assert(value is AsyncData, "Value was not async data");
      final data = value.asData!.value;
      if (!data.hasNextPage) return;
      _queryData = QueryData()
        ..count = _queryData.count
        ..page = (_queryData.page ?? 0) + 1;
      _pod.marketFetchingPod(_queryData);
    }
  }
}
