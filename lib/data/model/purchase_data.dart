
import 'package:budget_web/data/api/converter.dart';
import 'package:budget_web/data/model/purchase.dart';

class PurchaseData {
  List<Purchase> purchased;
  double budget;
  double spent;
  double remaining;

  PurchaseData({
    required this.purchased,
    required this.budget,
    required this.spent,
    required this.remaining,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchased': this.purchased,
      'budget': this.budget,
      'spent': this.spent,
      'remaining': this.remaining,
    };
  }

  factory PurchaseData.fromMap(Map<String, dynamic> map) {
    return PurchaseData(
      purchased: ModelCodec.decodeList<Purchase>(map['purchased']),
      budget: map['budget'] as double,
      spent: map['spent'] as double,
      remaining: map['remaining'] as double,
    );
  }
}