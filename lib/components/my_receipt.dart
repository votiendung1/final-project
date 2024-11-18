import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/home_page.dart';
import 'package:provider/provider.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 50),
      child: Center(
        child: SingleChildScrollView(
          // Đảm bảo cuộn nếu hóa đơn quá dài
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Cảm ơn bạn đã đặt hàng!"),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(25),
                child: Consumer<Restaurant>(
                  builder: (context, restaurant, child) => Text(
                    restaurant.displayCartReceipt(),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text("Thời gian giao hàng ước tính: 15 - 30 phút"),
              const SizedBox(height: 50),
              MyButton(
                text: "Trở về trang chủ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
