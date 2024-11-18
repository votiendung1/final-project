import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/services/database/firestore.dart';

class BillReceiptPage extends StatefulWidget {
  final String orderId;

  const BillReceiptPage({super.key, required this.orderId});

  @override
  _BillReceiptPageState createState() => _BillReceiptPageState();
}

class _BillReceiptPageState extends State<BillReceiptPage> {
  final FirestoreService _db = FirestoreService();
  Map<String, dynamic>? _orderDetails;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final doc = await _db.orders.doc(widget.orderId).get();
      setState(() {
        _orderDetails = doc.data() as Map<String, dynamic>;
      });
    } catch (e) {
      print("Error fetching order details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Đơn hàng chi tiết")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Lấy thông tin ngày tháng và biên nhận từ Firestore
    var orderDate = (_orderDetails?['date'] as Timestamp).toDate().toLocal().toString();
    var receipt = _orderDetails?['order'] ?? "Không có biên nhận";

    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng chi tiết")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ngày: $orderDate", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Biên nhận: \n$receipt", style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
