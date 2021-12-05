import 'package:beamer/beamer.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/pages/home_page.dart';
import 'package:budget_web/pages/login_page.dart';
import 'package:budget_web/pages/market_page.dart';
import 'package:budget_web/pages/projects_page.dart';
import 'package:budget_web/pages/sign_up_page.dart';
import 'package:budget_web/routing/routes.dart';
import 'package:flutter/material.dart';

BeamerDelegate createRouter() {
  return BeamerDelegate(
    initialPath: Routes.login,
    notFoundPage: BeamPage(
      title: 'Not Found',
      child: Scaffold(
        body: Center(
          child: Text('Not found!'),
        ),
      ),
    ),
    guards: [
      BeamGuard(
        pathBlueprints: [
          Routes.home,
          Routes.market,
          Routes.projects,
        ],
        check: (context, location) {
          print('CHECK DAMNIT CHECK\n\n\n\n\n\n');
          return MyApp.dataStore.isLoggedIn;
        },
        beamToNamed: Routes.login,
      ),
    ],
    locationBuilder: SimpleLocationBuilder(
      routes: {
        Routes.signUp: (context, _) => SignUpPage(),
        Routes.login: (context, _) => LoginPage(title: "Router Home Page"),
        Routes.home: (context, _) => HomePage(),
        Routes.market: (context, _) => MarketPage(),
        Routes.projects: (context, _) => Projects(),
      },
    ),
  );
}
