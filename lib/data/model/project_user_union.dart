
class ProjectUserUnion {
  String id;
  String userId;
  String projectId;

  ProjectUserUnion({
    required this.id,
    required this.userId,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'projectId': this.projectId,
    };
  }

  factory ProjectUserUnion.fromMap(Map<String, dynamic> map) {
    return ProjectUserUnion(
      id: map['id'] as String,
      userId: map['userId'] as String,
      projectId: map['projectId'] as String,
    );
  }
}