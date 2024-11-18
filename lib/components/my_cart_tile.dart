import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_quantity_selector.dart';
import 'package:food_delivery_app/models/cart_item.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:provider/provider.dart';

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;

  const MyCartTile({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ảnh đồ ăn
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cartItem.food.imagePath,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // tên và giá
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // tên đồ ăn
                      SizedBox(
                        width:
                            135, // Đặt độ rộng cố định để kiểm soát khi xuống dòng
                        child: Text(
                          cartItem.food.name,
                          maxLines: 2, // Giới hạn số dòng (ví dụ: 2 dòng)
                          overflow: TextOverflow
                              .ellipsis, // Thêm dấu "..." nếu vượt quá dòng
                          style: const TextStyle(
                            fontSize:
                                14, // Bạn có thể điều chỉnh font-size tùy theo giao diện
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // giá đồ ăn
                      SizedBox(
                        width:
                            130, // Đặt độ rộng cố định tương tự cho giá đồ ăn
                        child: Text(
                          '\$${cartItem.food.price}',
                          maxLines:
                              1, // Giới hạn số dòng (ví dụ: 1 dòng cho giá)
                          overflow: TextOverflow
                              .ellipsis, // Thêm dấu "..." nếu vượt quá dòng
                          style: TextStyle(
                            fontSize: 14, // Điều chỉnh font-size cho giá
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // tăng or giảm số lượng
                  MyQuantitySelector(
                    quantity: cartItem.quantity,
                    food: cartItem.food,
                    onDecrement: () {
                      cartItem.quantity -= 1;
                      restaurant
                          .updateCart(cartItem); // Cập nhật số lượng trong giỏ
                      restaurant.updateCartItemInDatabase(
                          cartItem); // Cập nhật Firestore
                    },
                    onIncrement: () {
                      cartItem.quantity += 1;
                      restaurant
                          .updateCart(cartItem); // Cập nhật số lượng trong giỏ
                      restaurant.updateCartItemInDatabase(
                          cartItem); // Cập nhật Firestore
                    },
                  ),
                ],
              ),
            ),

            // addon
            SizedBox(
              height: cartItem.selectAddons.isEmpty ? 0 : 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                children: cartItem.selectAddons
                    .map(
                      (addon) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Row(
                            children: [
                              // tên addon
                              Text(addon.name),

                              // giá  addon
                              Text('(\$${addon.price})'),
                            ],
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onSelected: (value) {},
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
