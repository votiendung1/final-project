// item đồ ăn
import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String name; // tên đồ ăn
  final String description; // mô tả đồ ăn
  final String imagePath; // ảnh đồ ăn(có thể chèn nhiều ảnh nhưng chỉ lấy ảnh đầu để hiện thị ở home_page)
  final List<String> imagePaths; // Lưu danh sách ảnh
  final double price; // giá
  final FoodCategory category; // loại đồ ăn
  List<Addon> availableAddon; // mục thêm đồ ăn(ví dụ như thịt, rau, ...)

  Food({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.imagePaths, 
    required this.price,
    required this.category,
    required this.availableAddon,
  });

  // Override == để so sánh các thuộc tính của Food
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Food) return false;
    return name == other.name &&
           description == other.description &&
           imagePath == other.imagePath &&
           price == other.price &&
           category == other.category;
  }

  // Override hashCode để tính toán mã băm cho Food
  @override
  int get hashCode => Object.hash(name, description, imagePath, price, category);

  // Tạo Food từ Firestore
  factory Food.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Chuyển đổi list imagePaths và list addon từ Firestore với kiểm tra null
    List<String> imagePathsFromFirestore = List<String>.from(data['imagePaths'] ?? []);
    List<Addon> addonsFromFirestore = (data['addons'] as List<dynamic>? ?? [])
        .map((addonData) => Addon.fromMap(addonData as Map<String, dynamic>))
        .toList();

    // Ánh xạ chuỗi category từ Firestore thành enum FoodCategory
    FoodCategory categoryFromFirestore;
    switch (data['category']) {
      case 'burgers':
        categoryFromFirestore = FoodCategory.burgers;
        break;
      case 'salads':
        categoryFromFirestore = FoodCategory.salads;
        break;
      case 'sides':
        categoryFromFirestore = FoodCategory.sides;
        break;
      case 'desserts':
        categoryFromFirestore = FoodCategory.desserts;
        break;
      case 'drinks':
        categoryFromFirestore = FoodCategory.drinks;
        break;
      default:
        categoryFromFirestore = FoodCategory.burgers; // Giá trị mặc định
    }

    return Food(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      imagePaths: imagePathsFromFirestore,
      price: (data['price']?.toDouble() ?? 0.0),
      category: categoryFromFirestore,
      availableAddon: addonsFromFirestore,
    );
  }
}

// phân loại đồ ăn
enum FoodCategory {
  burgers,
  salads,
  sides,
  desserts,
  drinks,
}

// loại bổ sung đồ ăn có thể đặt thêm
class Addon {
  String name;
  double price; // giá
  Addon({
    required this.name,
    required this.price,
  });

  // Override == để so sánh Addon
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Addon) return false;
    return name == other.name && price == other.price;
  }

  // Override hashCode cho Addon
  @override
  int get hashCode => Object.hash(name, price);

  // Tạo Addon từ Firestore Map
  factory Addon.fromMap(Map<String, dynamic> data) {
    return Addon(
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
    );
  }
}
