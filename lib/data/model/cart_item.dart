
class CartItem {
  String? id;
  String itemId;
  String projectId;
  int quantity;

  CartItem({
    this.id,
    required this.itemId,
    required this.projectId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'itemId': this.itemId,
      'projectId': this.projectId,
      'quantity': this.quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      projectId: map['projectId'] as String,
      quantity: map['quantity'] as int,
    );
  }
}