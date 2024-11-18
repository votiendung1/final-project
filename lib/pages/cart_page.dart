// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/components/my_cart_tile.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/payment_page.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Tải giỏ hàng từ Firestore khi widget được khởi tạo
    Provider.of<Restaurant>(context, listen: false).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = Provider.of<Restaurant>(context);

    // giỏ hàng
    final userCart = restaurant.cart;

    // scaffold UI
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text("Cart"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // button xóa giỏ hàng
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Bạn có muốn xóa khỏi cửa hàng?"),
                  actions: [
                    // button không
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Không"),
                    ),
                    // button có
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        restaurant.clearCart();
                      },
                      child: const Text("Có"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // danh sách giỏ hàng
          Expanded(
            child: Column(
              children: [
                userCart.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text("Giỏ hàng đang trống..."),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: userCart.length,
                          itemBuilder: (context, index) {
                            // lấy từng mặt hàng trong giỏ hàng
                            final cartItem = userCart[index];

                            // trả về giao diện giỏ hàng
                            return MyCartTile(cartItem: cartItem);
                          },
                        ),
                      ),
              ],
            ),
          ),
          // button mua
          MyButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentPage(),
              ),
            ),
            text: "Thanh toán",
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
