// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/components/my_textfield.dart';
import 'package:food_delivery_app/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  bool _isPasswordVisible = false; // Biến theo dõi trạng thái hiện mật khẩu

  String? _errorMessage; // Biến theo dõi thông báo lỗi

  // phương thức đăng nhập
  void login() async {
    // xác thực
    final _authService = AuthService();

    // đăng nhập
    try {
      await _authService.signInWithEmailPassword(
          emailController.text, passController.text);
      // Điều hướng tới HomePage sau khi đăng nhập thành công
      Navigator.pushReplacementNamed(context, '/home');
    }
    // hiện thị lỗi
    catch (e) {
      setState(() {
        // Cập nhật biến thông báo lỗi
        _errorMessage = "Bạn đã nhập sai email hoặc password";
      });
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: Text(
      //       e.toString(),
      //     ),
      //   ),
      // );
    }
  }

  // quên mk
  void forgotPw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Người dùng quên mật khẩu!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'lib/images/background/background.jpg'), // Thay đổi đường dẫn thành tên tệp của bạn
            fit: BoxFit.cover, // Đảm bảo hình ảnh phủ kín toàn bộ background
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Icon(
                    Icons.lock_open_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  const SizedBox(height: 25),

                  // tin nhắn
                  const Text(
                    "Welcome To Food Delivery App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // email
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: MyTextfield(
                      controller: emailController,
                      hintText: "Email",
                      obcureText: false,
                      // Kích hoạt login khi nhấn Enter
                      onSubmitted: (value) {
                        login();
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // mật khẩu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextfield(
                            controller: passController,
                            hintText: "Password",
                            obcureText:
                                !_isPasswordVisible, // Cập nhật trạng thái hiện mật khẩu
                            showPasswordToggle:
                                true, // Thêm tham số để hiển thị nút hiển thị/ẩn
                            onTogglePasswordVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            // Kích hoạt login khi nhấn Enter
                            onSubmitted: (value) {
                              login();
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Thông báo lỗi
                  if (_errorMessage != null) // Chỉ hiển thị khi có lỗi
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red, // Màu đỏ cho thông báo lỗi
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 30),

                  // nút đăng nhập
                  MyButton(
                    text: "Đăng nhập",
                    onTap: login,
                  ),
                  const SizedBox(height: 25),

                  // ko tk = đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chưa có tài khoản?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 5, 252),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
