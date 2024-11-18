import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Thư viện để xử lý file ảnh
import 'package:food_delivery_app/components/my_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;
  File? _selectedImage; // Biến lưu trữ ảnh đã chọn
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

// Hàm tải thông tin người dùng từ Firestore
  Future<void> _loadUserInfo() async {
    if (currentUser != null) {
      final userDoc = await _firestore
          .collection('personal_information')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        if (data['avatar_url'] != null) {
          File imageFile = await _downloadImage(data['avatar_url']);
          setState(() {
            _selectedImage = imageFile;
          });
        }
      }
    }
  }

  // Hàm tải ảnh từ URL
  Future<File> _downloadImage(String url) async {
    final response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${documentDirectory.path}/avatar.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.data);
    return file;
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Hàm tải ảnh lên Firebase Storage và lấy URL
  Future<String> _uploadImage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars/${currentUser!.uid}.jpg'); // Đặt tên file cho ảnh
      await ref.putFile(image);
      return await ref.getDownloadURL(); // Trả về URL của ảnh
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Trả về chuỗi rỗng nếu có lỗi
    }
  }

  // Hàm lưu thông tin vào Firestore
  Future<void> _saveInfo() async {
    if (currentUser != null) {
      String imageUrl = '';
      if (_selectedImage != null) {
        imageUrl =
            await _uploadImage(_selectedImage!); // Tải ảnh lên và lấy URL
      }
      await _firestore
          .collection('personal_information')
          .doc(currentUser!.uid)
          .set({
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'email': currentUser!.email,
        'avatar_url':
            imageUrl, // Có thể lưu URL ảnh nếu cần tải ảnh lên Firebase Storage
      });
      // Cập nhật địa chỉ giao hàng trong Restaurant
      context.read<Restaurant>().updateDeliveryAddress(addressController.text);
      // Hiển thị thông báo thành công
      _showSuccessDialog();
    }
  }

  // Hàm hiển thị thông báo thành công
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Đã lưu thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue), // Màu xanh dương cho nút OK
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ảnh đại diện
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Email (chỉ đọc)
                Text(
                  currentUser?.email ?? "Chưa có email",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Nhập tên
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
                    controller: nameController,
                    hintText: "Họ Tên",
                    obcureText: false,
                    onSubmitted: (value) {
                      // Xử lý logic khi nhấn "Enter"
                      _saveInfo();
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Nhập số điện thoại
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
                    controller: phoneController,
                    hintText: "Số điện thoại",
                    obcureText: false,
                    onSubmitted: (value) {
                      // Xử lý logic khi nhấn "Enter"
                      _saveInfo();
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Nhập địa chỉ
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
                    controller: addressController,
                    hintText: "Địa chỉ",
                    obcureText: false,
                    onSubmitted: (value) {
                      // Xử lý logic khi nhấn "Enter"
                      _saveInfo();
                    },
                  ),
                ),
                const SizedBox(height: 80),

                // Nút lưu thông tin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _saveInfo,
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
                              children: [
                                const Text("Lưu thông tin",
                                    style: TextStyle(color: Colors.white)),
                                IconButton(
                                  onPressed: _saveInfo,
                                  icon: const Icon(Icons.edit),
                                  color: Theme.of(context).colorScheme.primary,
                                  iconSize: 25,
                                  tooltip: 'Sửa và lưu thông tin',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Nút về trang chủ
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                                255, 252, 252, 252), // Màu nền
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
                              children: [
                                const Text(
                                  "Về trang chủ",
                                  style: TextStyle(color: Colors.red),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  },
                                  icon: const Icon(Icons.home),
                                  color: Theme.of(context).colorScheme.primary,
                                  iconSize: 25,
                                  tooltip: 'Về trang chủ',
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
