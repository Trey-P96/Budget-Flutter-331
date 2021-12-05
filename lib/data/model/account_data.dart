import 'package:budget_web/data/api/converter.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/user.dart';

class AccountData {
  User user;
  Map<String, Project> projects;

  AccountData({
    required this.user,
    required this.projects,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': this.user,
      'projects': this.projects,
    };
  }

  factory AccountData.fromMap(Map<String, dynamic> map) {
    return AccountData(
      user: ModelCodec.decode<User, dynamic>(map['user']),
      projects:
          Map.fromEntries(ModelCodec.decodeList<Project, dynamic>(map['projects']).map((x) => MapEntry(x.id!, x))),
    );
  }
}
