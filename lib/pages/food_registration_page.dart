import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_textfield.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/services/database/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:provider/provider.dart'; // Import Food model

class FoodRegistrationPage extends StatefulWidget {
  const FoodRegistrationPage({super.key});

  @override
  State<FoodRegistrationPage> createState() => _FoodRegistrationPageState();
}

class _FoodRegistrationPageState extends State<FoodRegistrationPage> {
  final TextEditingController namefoodController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool _isCategoryDropdownOpen =
      false; // Kiểm soát trạng thái danh sách category

  // Biến để lưu ảnh đã chọn
  File? _selectedImage;
  List<File> _selectedImages = []; // Lưu danh sách ảnh
  final FirestoreService firestoreService = FirestoreService();

  // Danh sách Addon
  List<Addon> _addons = [];
  List<TextEditingController> addonNameControllers = [];
  List<TextEditingController> addonPriceControllers = [];

  // Hàm chọn nhiều ảnh từ thư viện
  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages =
            pickedImages.map((e) => File(e.path)).toList(); // Lưu tất cả ảnh
      });
    }
  }

  // Hàm tải ảnh lên Firebase Storage và lấy URL
  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('food_images/${DateTime.now().toString()}.jpg');
        await ref.putFile(image);
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }

  // Hàm lưu thông tin đồ ăn và ảnh vào Firebase
  Future<void> _saveFoodInfo() async {
    if (_selectedImages.isNotEmpty && priceController.text.isNotEmpty) {
      double? price = double.tryParse(priceController.text);
      if (price != null) {
        List<String> imageUrls = await _uploadImages(_selectedImages);

        if (imageUrls.isNotEmpty) {
          // Tạo đối tượng Food
          Food newFood = Food(
            name: namefoodController.text,
            description: descriptionController.text,
            price: price,
            imagePaths: imageUrls, // Lưu tất cả URL ảnh
            imagePath: imageUrls[0], // Lưu ảnh đầu tiên
            category: _selectedCategory,
            availableAddon: _addons, // Lưu danh sách addon
          );

          // Lưu vào Firestore
          await firestoreService.saveFood(newFood);

          // Thêm vào menu của Restaurant
          Provider.of<Restaurant>(context, listen: false).addFood(newFood);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lưu thông tin đồ ăn thành công'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải ảnh lên')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giá không hợp lệ')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh và nhập giá')),
      );
    }
  }

  FoodCategory _selectedCategory = FoodCategory.burgers; // Category mặc định

  // Hàm thêm addon mới
  void _addAddonField() {
    setState(() {
      addonNameControllers.add(TextEditingController());
      addonPriceControllers.add(TextEditingController());
    });
  }

  // Hàm tạo Addon từ các TextEditingController
  void _generateAddons() {
    _addons = [];
    for (int i = 0; i < addonNameControllers.length; i++) {
      String name = addonNameControllers[i].text;
      double? price = double.tryParse(addonPriceControllers[i].text);
      if (name.isNotEmpty && price != null) {
        _addons.add(Addon(name: name, price: price));
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ cho các TextEditingController
    namefoodController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    for (var controller in addonNameControllers) {
      controller.dispose();
    }
    for (var controller in addonPriceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text("Đăng ký thực phẩm"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Thêm ảnh đồ ăn",
                  style: TextStyle(fontSize: 18),
                ),
                // Ảnh đại diện của đồ ăn (chọn nhiều ảnh)
                GestureDetector(
                  onTap: _pickImages, // Chọn nhiều ảnh
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) // Hiển thị ảnh đầu tiên
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị danh sách ảnh đã chọn
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Stack(
                            children: [
                              Image.file(
                                _selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Nhập tên đồ ăn
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: MyTextfield(
                    controller: namefoodController,
                    hintText: "Tên đồ ăn",
                    obcureText: false,
                  ),
                ),
                const SizedBox(height: 15),

                // Phần chọn Category
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCategoryDropdownOpen =
                            !_isCategoryDropdownOpen; // Đảo trạng thái
                      });
                    },
                    child: AbsorbPointer(
                      child: MyTextfield(
                        controller: TextEditingController(
                            text: _selectedCategory.toString().split('.').last),
                        hintText: "Chọn loại đồ ăn",
                        obcureText: false,
                      ),
                    ),
                  ),
                ),
                if (_isCategoryDropdownOpen)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          FoodCategory.values.map((FoodCategory category) {
                        return ListTile(
                          title: Text(category.toString().split('.').last),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _isCategoryDropdownOpen =
                                  false; // Đóng dropdown sau khi chọn
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 15),

                // Nhập mô tả đồ ăn
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: MyTextfield(
                    controller: descriptionController,
                    hintText: "Mô tả đồ ăn",
                    obcureText: false,
                  ),
                ),
                const SizedBox(height: 15),

                // Nhập giá
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: MyTextfield(
                    controller: priceController,
                    hintText: "Giá",
                    obcureText: false,
                  ),
                ),
                const SizedBox(height: 10),

                // Addon section
                const Text("Thêm các tùy chọn bổ sung:"),
                const SizedBox(height: 15),
                Column(
                  children: List.generate(addonNameControllers.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: MyTextfield(
                            controller: addonNameControllers[index],
                            hintText: "Tên addon",
                            obcureText: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextfield(
                            controller: addonPriceControllers[index],
                            hintText: "Giá addon",
                            obcureText: false,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addAddonField,
                  child: const Text("Thêm tùy chọn bổ sung"),
                ),
                const SizedBox(height: 80),

                // Nút lưu thông tin và nút về trang chủ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Nút lưu thông tin
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _generateAddons(); // Lấy addons từ các TextField
                          _saveFoodInfo();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color:
                                const Color.fromARGB(255, 0, 0, 0), // Màu nền
                            borderRadius: BorderRadius.circular(12), // Bo góc
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Màu bóng đổ
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5), // Tọa độ bóng đổ
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Lưu thông tin",
                                    style: TextStyle(color: Colors.white)),
                                IconButton(
                                  onPressed: _saveFoodInfo,
                                  icon: const Icon(Icons.save,
                                      size: 24, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nút về trang chủ
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color:
                                const Color.fromARGB(255, 0, 0, 0), // Màu nền
                            borderRadius: BorderRadius.circular(12), // Bo góc
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Màu bóng đổ
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5), // Tọa độ bóng đổ
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Trang chủ",
                                    style: TextStyle(color: Colors.white)),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.home,
                                      size: 24, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
