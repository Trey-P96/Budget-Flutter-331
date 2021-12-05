import 'package:budget_web/data/model/account_data.dart';
import 'package:budget_web/main.dart';
import 'package:budget_web/routing/routes.dart';

class DataStore {
  AccountData? account;

  bool get isLoggedIn => account != null;

  void logout() {
    if (account == null) return null;
    MyApp.api.logout(account!.user.id!).catchError(print);
    account = null;
    MyApp.router.beamToNamed(Routes.login, replaceCurrent: true);
  }
}
