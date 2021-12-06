
import 'package:budget_web/data/api/converter.dart';
import 'package:budget_web/data/model/project.dart';
import 'package:budget_web/data/model/project_user_union.dart';
import 'package:budget_web/data/model/user.dart';

class JoinedProject {
  Project project;
  ProjectUserUnion union;
  User user;

  JoinedProject({
    required this.project,
    required this.union,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'project': this.project,
      'union': this.union,
      'user': this.user,
    };
  }

  factory JoinedProject.fromMap(Map<String, dynamic> map) {
    return JoinedProject(
      project: ModelCodec.decode<Project, dynamic>(map['project']),
      union: ModelCodec.decode<ProjectUserUnion, dynamic>(map['union']),
      user: ModelCodec.decode<User, dynamic>(map['user']),
    );
  }
}