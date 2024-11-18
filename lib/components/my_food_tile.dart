import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/food.dart';

class MyFoodTile extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const MyFoodTile({
    super.key,
    required this.food,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card( // Đóng khung món ăn
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4, // Đổ bóng cho thẻ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh đồ ăn
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                food.imagePath,
                height: 120,
                width: double.infinity, // Chiều rộng tối đa
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            // Chi tiết đồ ăn
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món ăn
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1, // Giới hạn số dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị ... nếu quá dài
                  ),
                  const SizedBox(height: 5),
                  // Giá món ăn
                  Text(
                    '\$${food.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Mô tả món ăn
                  Text(
                    food.description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    maxLines: 1, // Giới hạn số dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị ... nếu quá dài
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tạo một widget mới cho các tile trong hàng
// class MyFoodRow extends StatelessWidget {
//   final List<Food> foods;
//   final void Function(Food food)? onTap;

//   const MyFoodRow({
//     super.key,
//     required this.foods,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: foods.map((food) {
//         return Expanded(
//           child: MyFoodTile(
//             food: food,
//             onTap: () => onTap?.call(food),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
