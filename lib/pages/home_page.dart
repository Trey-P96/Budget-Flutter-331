//ALT-ENTER
//ctrl-Space
import 'package:beamer/beamer.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/routing/routes.dart';
import 'package:budget_web/widgets/create_project_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final user = MyApp.dataStore.account!.user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text("Hello, ${user.username}"),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => MyApp.dataStore.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Tooltip(
                message: "Market",
                child: InkWell(
                  onTap: () {
                    Beamer.of(context).beamToNamed(Routes.market, stacked: true);
                  },
                  child: Transform.scale(
                    scale: .5,
                    child: RiveAnimation.asset(
                      'assets/store.riv',
                      animations: [
                        'store',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Tooltip(
                message: "Create new project",
                child: InkWell(
                  onTap: () {
                    showProjectPopup(context);
                  },
                  child: Transform.scale(
                    scale: .5,
                    child: RiveAnimation.asset(
                      'assets/create.riv',
                      animations: [
                        'create',
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Tooltip(
                message: "My Projects",
                child: InkWell(
                  onTap: () {
                    Beamer.of(context).beamToNamed(Routes.projects, stacked: true);
                  },
                  child: Transform.scale(
                    scale: .5,
                    child: RiveAnimation.asset(
                      'assets/folder.riv',
                      animations: [
                        'folder',
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
