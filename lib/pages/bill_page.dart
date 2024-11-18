import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/services/database/firestore.dart';
import 'package:food_delivery_app/pages/bill_receipt_page.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final FirestoreService _db = FirestoreService();
  List<QueryDocumentSnapshot> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    // Lấy tất cả các đơn hàng từ Firestore
    try {
      // Lấy các đơn hàng đã sắp xếp theo trường "date"
      final snapshot = await _db.orders
          .orderBy('date', descending: true) // Sắp xếp theo ngày, descending: true để sắp xếp giảm dần (mới nhất lên trên)
          .get();
      setState(() {
        _orders = snapshot.docs;
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách đơn hàng")),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          // Lấy dữ liệu ngày tháng từ đơn hàng
          var orderDate = (_orders[index].data()
              as Map<String, dynamic>)['date'] as Timestamp;
          var formattedDate = orderDate
              .toDate()
              .toLocal()
              .toString()
              .split(' ')[0]; // Lấy ngày tháng

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                backgroundColor: Colors.blueAccent, // Màu nền của button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bo góc button
                ),
                elevation: 5, // Tạo hiệu ứng nổi
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Chuyển đến trang `bill_receipt_page.dart` và truyền dữ liệu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillReceiptPage(
                        orderId: _orders[index].id), // Truyền orderId
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                      )), // Hiển thị ngày tháng
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ), // Icon mũi tên
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
