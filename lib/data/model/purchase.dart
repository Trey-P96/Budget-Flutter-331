
class Purchase {
  String? id;
  String userId;
  String itemId;
  String projectId;
  DateTime datePurchased;
  double purchasePrice;
  String name;

  Purchase({
    this.id,
    required this.name,
    required this.userId,
    required this.itemId,
    required this.projectId,
    required this.datePurchased,
    required this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'itemId': this.itemId,
      'projectId': this.projectId,
      'datePurchased': this.datePurchased.toIso8601String(),
      'purchasePrice': this.purchasePrice,
      'name': this.name,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      name: map['name'] as String,
      id: map['id'] as String?,
      userId: map['userId'] as String,
      itemId: map['itemId'] as String,
      projectId: map['projectId'] as String,
      datePurchased: DateTime.parse(map['datePurchased']),
      purchasePrice: map['purchasePrice'] as double,
    );
  }
}