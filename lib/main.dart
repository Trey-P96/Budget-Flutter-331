import 'package:beamer/beamer.dart';
import 'package:budget_web/data/api/api.dart';
import 'package:budget_web/data/repo/data_store.dart';
import 'package:budget_web/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(
    UncontrolledProviderScope(
      container: MyApp.podRef,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  static final api = Api.create();
  static final dataStore = DataStore();
  static final BeamerDelegate router = createRouter();
  static final podRef = ProviderContainer();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerParser(),
      routerDelegate: router,
    );
  }
}
