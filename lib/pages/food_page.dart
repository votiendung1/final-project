import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/cart_page.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final Map<Addon, bool> selectAddons = {};

  FoodPage({
    super.key,
    required this.food,
  }) {
    // khởi tạo các addon thành false
    for (Addon addon in food.availableAddon) {
      selectAddons[addon] = false;
    }
  }

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  int cartItemCount = 0; // Biến để theo dõi số lượng sản phẩm trong giỏ hàng
  // bool isAnimating = false; // Trạng thái animation

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // thêm vào giỏ hàng
  void addToCart(Food food, Map<Addon, bool> selectAddons) {
    // đóng trang hiện tại quay lại menu
    // Navigator.pop(context);

    // định dạng các addon đã chọn
    List<Addon> currentlySelectedAddons = [];
    for (Addon addon in widget.food.availableAddon) {
      if (widget.selectAddons[addon] == true) {
        currentlySelectedAddons.add(addon);
      }
    }
    // thêm vào giỏ hàng
    context.read<Restaurant>().addToCart(food, currentlySelectedAddons);

    // Cập nhật số lượng sản phẩm trong giỏ hàng
    setState(() {
      cartItemCount++;
    });

    // Chạy hiệu ứng animation
    _animationController?.forward().then((_) {
      _animationController?.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scaffold UI
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Đảm bảo ảnh vừa đúng màn hình
                AspectRatio(
                  aspectRatio: 16 / 12, // Tỉ lệ khung hình 16:9
                  // ảnh đồ ăn
                  child: Image.network(
                    widget.food.imagePath,
                    fit: BoxFit
                        .cover, // Ảnh lấp đầy toàn bộ vùng nhưng vẫn giữ tỉ lệ
                    width: double.infinity, // Đảm bảo ảnh chiếm hết chiều rộng
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons
                          .error); // Hiển thị icon lỗi nếu không load được ảnh
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // tên đồ ăn
                      Text(
                        widget.food.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      // giá đồ ăn
                      Text(
                        '\$${widget.food.price}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // mô tả đồ ăn
                      Text(
                        widget.food.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.shadow,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Divider(
                        color: Theme.of(context).colorScheme.secondary,
                      ),

                      const SizedBox(height: 10),

                      // thêm đồ ăn
                      Text(
                        "Add-ons",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.food.availableAddon.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: widget.food.availableAddon.length,
                                itemBuilder: (context, index) {
                                  // lấy thêm riêng lẻ
                                  Addon addon =
                                      widget.food.availableAddon[index];

                                  // Trả về hộp kiểm UI
                                  return CheckboxListTile(
                                    title: Text(addon.name),
                                    subtitle: Text(
                                      '\$${addon.price}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    value: widget.selectAddons[addon],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        widget.selectAddons[addon] = value!;
                                      });
                                    },
                                  );
                                },
                              )
                            : const Text("Không có đồ ăn thêm"),
                      ),
                    ],
                  ),
                ),

                // button -> thêm vào giỏ hàng
                // MyButton(
                //   onTap: () => addToCart(widget.food, widget.selectAddons),
                //   text: "Thêm vào giỏ hàng",
                // ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          bottomNavigationBar: _buttonAddCart(context),
        ),

        // trở lại button
        SafeArea(
          child: Positioned(
            top: 10, // Điều chỉnh vị trí để nằm trên ảnh
            left: 10,
            child: Opacity(
              opacity: 0.6,
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Positioned(
            top: 10,
            right: 10,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.03).animate(
                    CurvedAnimation(
                      parent: _animationController!,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 320),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () async {
                        await _animationController?.forward();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                        _animationController?.reverse();
                      },
                    ),
                  ),
                ),
                if (cartItemCount > 0)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 20,
                      maxHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonAddCart(BuildContext context) {
    return Container(
      height: 83,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // button -> thêm vào giỏ hàng
          MyButton(
            onTap: () => addToCart(widget.food, widget.selectAddons),
            text: "Thêm vào giỏ hàng",
          ),
        ],
      ),
    );
  }
}
