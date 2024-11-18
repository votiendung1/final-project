import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_current_location.dart';
import 'package:food_delivery_app/components/my_description_box.dart';
import 'package:food_delivery_app/components/my_drawer.dart';
import 'package:food_delivery_app/components/my_food_tile.dart';
import 'package:food_delivery_app/components/my_sliver_app_bar.dart';
import 'package:food_delivery_app/components/my_tab_bar.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/food_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // tab controrller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);

    // Gọi fetchMenu để tải dữ liệu từ Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Restaurant>(context, listen: false).fetchMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // sắp sếp và trả về danh sách các thực phẩm thuộc danh mục cụ thể
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  // trả về danh sách thực phẩm trong danh mục nhất định
  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số lượng món ăn mỗi hàng
          childAspectRatio: 0.85, // Tỉ lệ chiều cao / chiều rộng của từng món ăn
          mainAxisSpacing: 10, // Khoảng cách giữa các hàng
          crossAxisSpacing: 10, // Khoảng cách giữa các cột
        ),
        itemCount: categoryMenu.length,
        itemBuilder: (context, index) {
          return MyFoodTile(
            food: categoryMenu[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodPage(
                    food: categoryMenu[index],
                  ),
                ),
              );
            },
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScolled) => [
          MySliverAppBar(
            title: MyTabBar(tabController: _tabController),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  indent: 25,
                  endIndent: 25,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                // vị trí hiện tại
                MyCurrentLocation(),

                // mô tả
                const MyDescriptionBox(),
              ],
            ),
          ),
        ],
        // hiện thị menu ra
        body: Consumer<Restaurant>(
          builder: (context, restaurant, child) {
            if (restaurant.menu.isEmpty) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // Hiển thị loading khi chưa có dữ liệu
            }
            return TabBarView(
              controller: _tabController,
              children: getFoodInThisCategory(restaurant.menu),
            );
          },
          // builder: (context, retaurant, child) => TabBarView(
          //   controller: _tabController,
          //   children: getFoodInThisCategory(retaurant.menu),
          // ),
        ),
      ),
    );
  }
}
