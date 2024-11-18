
import 'package:food_delivery_app/models/food.dart';

class CartItem {
  Food food;
  List<Addon> selectAddons;
  int quantity; // so luong

  CartItem({
    required this.food,
    required this.selectAddons,
    this.quantity = 1,
  });

  double get totalPrice {
    double addonPrice = selectAddons.fold(0, (sum, addon) => sum + addon.price);
    return (food.price + addonPrice) * quantity;
  }

  // Phương thức chuyển đổi từ Firestore Document
  // factory CartItem.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;

  //   Food food = Food.fromFirestore(data['food']);
  //   List<Addon> addons = (data['addons'] as List<dynamic>)
  //       .map((addonData) => Addon.fromMap(addonData as Map<String, dynamic>))
  //       .toList();

  //   return CartItem(
  //     food: food,
  //     selectAddons: addons,
  //     quantity: data['quantity'] ?? 1,
  //   );
  // }
}
