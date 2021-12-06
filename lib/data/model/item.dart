

class Item {
  String name;
  double price;
  String? id;

  Item({
    required this.name,
    required this.price,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'price': this.price,
      'id': this.id,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String?,
      name: map['name'] as String,
      price: map['price'] as double,
    );
  }
}
