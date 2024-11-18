import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String uid;
  String name;
  String email;
  String phoneNumber;
  String address;
  String profileImageUrl;

  Person({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profileImageUrl,
  });

  // Chuyển đổi từ đối tượng sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Tạo đối tượng từ Map lấy từ Firestore
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  // Tạo đối tượng từ DocumentSnapshot của Firestore
  factory Person.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Person.fromMap(data);
  }
}
