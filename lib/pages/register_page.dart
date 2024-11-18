// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/components/my_textfield.dart';
import 'package:food_delivery_app/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();

  bool _isPasswordVisible = false; // Biến theo dõi trạng thái hiện mật khẩu
  bool _isPasswordVisible1 = false;

  String? _errorMessage; // Biến theo dõi thông báo lỗi

  // đang ký method
  void register() async {
    // điền xác thực ở đây
    final _authService = AuthService();

    // Kiểm tra độ dài mật khẩu
    if (passController.text.length < 8) {
      setState(() {
        _errorMessage = "Mật khẩu phải có ít nhất 8 ký tự";
      });
      return;
    }

    // Kiểm tra mật khẩu khớp nhau
    if (passController.text != confirmController.text) {
      setState(() {
        _errorMessage = "Mật khẩu không khớp!";
      });
      return;
    }
    // kiểm tra xem mk có khớp không
    if (passController.text == confirmController.text) {
      // tạo người dùng
      try {
        await _authService.signUpWithEmailPassword(
            emailController.text, passController.text);
        // Điều hướng tới HomePage sau khi đăng nhập thành công
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Xử lý lỗi từ Firebase
        if (e.toString() == 'Exception: email-already-in-use') {
          setState(() {
            _errorMessage = "Email đã tồn tại";
          });
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(e.toString()),
                  ));
        }
      }
    }

    // nếu mk ko khớp thì hiện lỗi
    // else {
    //   showDialog(
    //     context: context,
    //     builder: (context) => const AlertDialog(
    //       title: Text("Mật khẩu không khớp!"),
    //     ),
    //   );
    // }
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
                    "Tạo tài khoản của bạn",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 25),

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
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // nhập lại mật khẩu
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
                              controller: confirmController,
                              hintText: "Confirm Password",
                              obcureText:
                                  !_isPasswordVisible1, // Cập nhật trạng thái hiện mật khẩu
                              showPasswordToggle:
                                  true, // Thêm tham số để hiển thị nút hiển thị/ẩn
                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isPasswordVisible1 = !_isPasswordVisible1;
                                });
                              },
                              // Kích hoạt login khi nhấn Enter
                              onSubmitted: (value) {
                                register();
                              }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Hiển thị lỗi nếu có
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),

                  // nút đăng ký
                  MyButton(
                    text: "Đăng Ký",
                    onTap: register,
                  ),
                  const SizedBox(height: 25),

                  // có tk = đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Đã có tài khoản?",
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
                          "Đăng nhập",
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
