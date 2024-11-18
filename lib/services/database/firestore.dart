import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/models/cart_item.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/person.dart';

class FirestoreService {
  // lấy các đơn hàng
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');
  // nhập thông tin người dùng
  final CollectionReference users =
      FirebaseFirestore.instance.collection('personal_information');
  // Lưu hoặc cập nhật thông tin cá nhân
  Future<void> savePersonalInformation(Person person) async {
    await users.doc(person.uid).set(person.toMap());
  }

  // nhập thông tin đồ ăn
  final CollectionReference foodCollection =
      FirebaseFirestore.instance.collection('food');

  // lưu đồ ăn vào giỏ hàng
  final CollectionReference carts =
      FirebaseFirestore.instance.collection('carts');

  // lưu đơn hàng vào database
  Future<void> saveOrderToDatabase(String receipt) async {
    await orders.add({
      'date': DateTime.now(),
      'order': receipt,
    });
  }
  // Lấy chi tiết đơn hàng bằng orderId
  Future<DocumentSnapshot> getOrderById(String orderId) async {
    return await orders.doc(orderId).get();
  }

  // Lấy thông tin cá nhân
  Future<Person> getPersonalInformation(String uid) async {
    DocumentSnapshot doc = await users.doc(uid).get();
    if (doc.exists) {
      return Person.fromDocument(doc);
    } else {
      // Trả về đối tượng Person trống nếu không tìm thấy
      return Person(
        uid: uid,
        name: '',
        email: '',
        phoneNumber: '',
        address: '',
        profileImageUrl: '',
      );
    }
  }

  //lưu đồ ăn lên firebase
  Future<void> saveFood(Food food) async {
    await foodCollection.add({
      'name': food.name,
      'description': food.description,
      'price': food.price,
      'category': food.category.toString().split('.').last,
      'imagePaths': food.imagePaths, // Lưu toàn bộ ảnh
      'imagePath': food.imagePath, // Lưu ảnh đầu tiên
      'addons': food.availableAddon
          .map((addon) => {
                'name': addon.name,
                'price': addon.price,
              })
          .toList(),
    });
  }

  // lưu dữ liệu đồ ăn vào cart lên firebase
  Future<void> saveCartItemToDatabase(CartItem cartItem) async {
    await carts.add({
      'food': {
        'name': cartItem.food.name,
        'description': cartItem.food.description,
        'price': cartItem.food.price,
        'imagePath': cartItem.food.imagePath,
      },
      'addons': cartItem.selectAddons
          .map((addon) => {
                'name': addon.name,
                'price': addon.price,
              })
          .toList(),
      'quantity': cartItem.quantity,
      'dateAdded': DateTime.now(),
    });
  }

  // Cập nhật giỏ hàng khi số lượng thay đổi
  Future<void> updateCartItemInDatabase(CartItem cartItem) async {
    // Tìm mục giỏ hàng có cùng food (theo tên hoặc id)
    final querySnapshot = await carts
        .where('food.name', isEqualTo: cartItem.food.name)
        .where('addons',
            isEqualTo: cartItem.selectAddons
                .map((addon) => {
                      'name': addon.name,
                      'price': addon.price,
                    })
                .toList())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Nếu sản phẩm đã có trong giỏ hàng, cập nhật số lượng
      final docId = querySnapshot.docs.first.id;
      await carts.doc(docId).update({
        'quantity': cartItem.quantity,
        'dateAdded': DateTime.now(),
      });
    } else {
      // Nếu chưa có sản phẩm, thêm mới
      await carts.add({
        'food': {
          'name': cartItem.food.name,
          'description': cartItem.food.description,
          'price': cartItem.food.price,
          'imagePath': cartItem.food.imagePath,
        },
        'addons': cartItem.selectAddons
            .map((addon) => {
                  'name': addon.name,
                  'price': addon.price,
                })
            .toList(),
        'quantity': cartItem.quantity,
        'dateAdded': DateTime.now(),
      });
    }
  }

  // xóa toàn bộ dữ liệu khi tạo biên lai
  Future<void> clearCart() async {
    final snapshot = await carts.get();
    for (var doc in snapshot.docs) {
      await carts.doc(doc.id).delete();
    }
  }
}
