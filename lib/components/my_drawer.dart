import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_drawer_tile.dart';
import 'package:food_delivery_app/pages/bill_page.dart';
import 'package:food_delivery_app/pages/food_registration_page.dart';
import 'package:food_delivery_app/pages/person_page.dart';
// import 'package:food_delivery_app/pages/login_page.dart';
import 'package:food_delivery_app/pages/setting_page.dart';
import 'package:food_delivery_app/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          // app logo
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          // tiêu đề trang chủ
          MyDrawerTile(
            text: "TRANG CHỦ",
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),

          // cài đặt màn hình sáng or tối
          MyDrawerTile(
            text: "CÀI ĐẶT",
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ));
            },
          ),

          // Nhập thông tin cá nhân
          MyDrawerTile(
            text: "THÔNG TIN CÁ NHÂN",
            icon: Icons.person,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonPage(),
                  ));
            },
          ),

          // Nhập thông tin thực phẩm
          MyDrawerTile(
            text: "ĐĂNG KÝ THỰC PHẨM",
            icon: Icons.add_photo_alternate_sharp,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodRegistrationPage(),
                  ));
            },
          ),

          // Hóa đơn
          MyDrawerTile(
            text: "HÓA ĐƠN",
            icon: Icons.receipt,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BillPage(),
                  ));
            },
          ),

          const Spacer(),

          // Đăng xuất
          MyDrawerTile(
            text: "L O G O U T",
            icon: Icons.logout,
            onTap: () {
              logout();
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', // Đường dẫn tới LoginPage
                (route) => false, // Xóa tất cả các route khác khỏi ngăn xếp
              );
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const LoginPage(),
              //     ));
            },
          ),
          const SizedBox(
            height: 25.0,
          ),
        ],
      ),
    );
  }
}
