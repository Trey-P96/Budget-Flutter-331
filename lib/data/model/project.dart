
class Project {
  String name;
  String ownerId;
  double budget;
  bool hasBudget;
  String? id;

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'budget': this.budget,
      'hasBudget': this.hasBudget,
      'ownerId': this.ownerId,
      if (id != null)
      'id': this.id,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      name: map['name'] as String,
      budget: map['budget'] as double,
      hasBudget: map['hasBudget'] as bool,
      ownerId: map['ownerId'] as String,
      id: map['id'] as String?,
    );
  }

  Project({
    required this.name,
    required this.budget,
    required this.hasBudget,
    required this.ownerId,
    this.id,
  });

  factory Project.of(Project other) {
    return Project(
      name: other.name,
      budget: other.budget,
      hasBudget: other.hasBudget,
      ownerId: other.ownerId,
      id: other.id,
    );
  }
}
