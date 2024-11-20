// nhà hàng
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/cart_item.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/services/database/firestore.dart';
import 'package:intl/intl.dart';

class Restaurant extends ChangeNotifier {
  // danh sách menu đồ ăn
  List<Food> _menu = [];

  // tìm kiếm
  List<Food> _suggestions = [];

  // giỏ hàng người dùng
  List<CartItem> _cart = [];

  // địa chỉ giao hàng
  String _deliveryAddress = 'Đà Nẵng';

  // người nhận

  List<Food> get menu => _menu;
  List<Food> get suggestions => _suggestions;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;

  // Thêm đồ ăn vào menu
  void addFood(Food food) {
    _menu.add(food);
    notifyListeners(); // Thông báo cập nhật trạng thái
  }

  // Tải dữ liệu từ Firestore hiện thị home
  Future<void> fetchMenu() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('food').get();
      _menu = snapshot.docs.map((doc) => Food.fromFirestore(doc)).toList();
      notifyListeners(); // Cập nhật Provider để thông báo cho UI
    } catch (e) {
      print("Error fetching menu: $e");
    }
  }

  // nguoi nhan

  /*
  hoạt động
  */

  // thêm vào giỏ hàng
  Future<void> addToCart(Food food, List<Addon> selectAddons) async {
    // xem thử có mặt hàng nào trong giỏ hàng có cùng loại thực phẩm và các phần thêm thức ăn chưa
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // Kiểm tra món ăn có giống nhau không
      bool isSameFood = item.food == food;

      // kiểm tra các thức ăn thêm có giống nhau ko
      bool isSameAddons =
          ListEquality().equals(item.selectAddons, selectAddons);

      return isSameFood & isSameAddons;
    });
    // nếu mặt hàng đã có thì tăng số lượng lên
    if (cartItem != null) {
      cartItem.quantity++;
      await FirestoreService().updateCartItemInDatabase(cartItem);
    }
    //nếu ko có thêm 1 mặt hàng mới vào giỏ hàng
    else {
      cartItem = CartItem(
        food: food,
        selectAddons: selectAddons,
        quantity: 1,
      );
      _cart.add(cartItem);
      await FirestoreService().saveCartItemToDatabase(cartItem);
    }
    // Gọi phương thức để lưu vào Firestore
    notifyListeners();
  }

  //Cập nhật số lượng sản phẩm
  void updateCart(CartItem cartItem) {
    final existingItem =
        _cart.firstWhereOrNull((item) => item.food == cartItem.food);

    if (existingItem != null) {
      existingItem.quantity = cartItem.quantity; // Chỉ cập nhật số lượng
    } else {
      _cart.add(cartItem); // Nếu không có sản phẩm trong giỏ, thêm mới
    }

    notifyListeners();
  }

  // Cập nhật CartItem trong Firestore
  void updateCartItemInDatabase(CartItem cartItem) async {
    await FirestoreService().updateCartItemInDatabase(cartItem);
    notifyListeners(); // Thông báo cập nhật giỏ hàng
  }

  // xóa khỏi giỏ hàng
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  // tổng giá trong giỏ hàng
  double getTotalPrice() {
    double total = 0.0;

    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;

      for (Addon addon in cartItem.selectAddons) {
        itemTotal += addon.price;
      }

      total += itemTotal * cartItem.quantity;
    }
    return total;
  }

  // tổng số lượng item trong giỏ hàng
  int getTotalItemCount() {
    int totalItemCount = 0;

    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }

    return totalItemCount;
  }

  //xóa tất cả
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // cập nhật địa chỉ giao hàng
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  /*
  hoạt động
  */

  /*
  trợ giúp
  */

  // tạo biên nhận
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Đây là biên lai của bạn.");
    receipt.writeln();

    // định dạng ngày, tháng, năm, giờ, phút, giây
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln("------------");

    for (final cartItem in _cart) {
      receipt.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");
      if (cartItem.selectAddons.isNotEmpty) {
        receipt.writeln("   Add-ons: ${_formatAddons(cartItem.selectAddons)}");
      }
      receipt.writeln();
    }
    receipt.writeln("-------------");
    receipt.writeln();
    receipt.writeln("Tổng mặt hàng: ${getTotalItemCount()}");
    receipt.writeln("Tổng giá: ${_formatPrice(getTotalPrice())}");
    receipt.writeln();
    receipt.writeln("Giao hàng tới: $deliveryAddress");

    return receipt.toString();
  }

  // tạo biên lai và xóa dữ liệu
  void clearCartPage() async {
    await FirestoreService().clearCart();
  }

  // định giá thành tiền
  String _formatPrice(double price) {
    return "\$${price.toStringAsFixed(2)}";
  }

  // định các Addon thành 1
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }

  /*
  trợ giúp
  */

  /* tải dữ liệu từ firebase để hiện thị giỏ hàng*/
  // Tải giỏ hàng từ Firestore
  Future<void> fetchCart() async {
    try {
      final snapshot = await FirestoreService().carts.get();

      _cart = snapshot.docs.map((doc) {
        final data = doc.data()
            as Map<String, dynamic>; // Chuyển đổi từ DocumentSnapshot sang Map
        final foodData = data['food'] as Map<String, dynamic>;
        final addonsData = data['addons'] as List<dynamic>;

        // Khởi tạo đối tượng Food từ foodData
        final food = Food(
          name: foodData['name'],
          description: foodData['description'],
          imagePath: foodData['imagePath'],
          imagePaths: [], // Nếu bạn không cần ảnh khác
          price: foodData['price'].toDouble(),
          category: FoodCategory.burgers, // Đặt category phù hợp nếu cần
          availableAddon: [], // Nếu cần lấy dữ liệu addons
        );

        // Khởi tạo đối tượng CartItem từ dữ liệu
        return CartItem(
          food: food,
          selectAddons: addonsData.map((addon) {
            final addonData = addon as Map<String, dynamic>;
            return Addon(
              name: addonData['name'],
              price: addonData['price'].toDouble(),
            );
          }).toList(),
          quantity: data['quantity'],
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching cart: $error");
    }
  }

  // Phương thức khởi tạo
  Future<void> init() async {
    await fetchCart(); // Gọi phương thức tải giỏ hàng
    // Nếu cần, bạn có thể gọi fetchMenu() ở đây để tải menu
  }

  // tìm kiếm đồ ăn
  Future<List<Food>> searchFoods(String query) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('food')
          .get();

      final List<Food> results =
          snapshot.docs
          .map((doc) {
            Food food = Food.fromFirestore(doc);
            return food.name.toLowerCase().contains(query.toLowerCase()) ? food : null;
          })
          .whereType<Food>()
          .toList();

      // Tìm kiếm theo category (nếu cần)
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('food')
          .where('category', isEqualTo: query)
          .get();

      results.addAll(
          categorySnapshot.docs.map((doc) => Food.fromFirestore(doc)).toList());

      return results;
    } catch (e) {
      print("Error searching foods: $e");
      return [];
    }
  }

  // gợi ý tìm kiếm
  Future<void> fetchSuggestions(String text) async {
    try {
      if (text.isEmpty) {
        _suggestions.clear();
      } else {
        // Chuyển cả query và dữ liệu Firebase về dạng chữ thường
        String query = text.toLowerCase();

        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('food').get();

        // So sánh tên đồ ăn trong cơ sở dữ liệu với query đã chuyển thành chữ thường
        _suggestions = snapshot.docs
            .map((doc) {
              Food food = Food.fromFirestore(doc);
              return food.name.toLowerCase().contains(query) ? food : null;
            })
            .whereType<Food>()
            .toList();
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }
}
