import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obcureText;
  final bool enabled; // Thêm tham số enabled để kiểm soát khả năng chỉnh sửa
  final bool showPasswordToggle; // Thêm tham số để hiển thị nút hiển thị/ẩn
  final VoidCallback?
      onTogglePasswordVisibility; // Callback để thay đổi trạng thái
  final Function(String)?
      onSubmitted; // Thêm tham số onSubmitted để xử lý khi nhấn "Enter"

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obcureText,
    this.enabled = true, // Mặc định cho phép chỉnh sửa
    this.showPasswordToggle = false,
    this.onTogglePasswordVisibility,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obcureText,
        enabled: enabled, // Sử dụng tham số enabled
        decoration: InputDecoration(
          labelText: hintText, // Thêm nhãn để nó di chuyển lên khi có focus
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Điều khiển hành vi của nhãn
          labelStyle: const TextStyle(color: Colors.red),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          suffixIcon: showPasswordToggle // Nếu tham số là true, thêm icon
              ? IconButton(
                  icon: Icon(
                    obcureText ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onTogglePasswordVisibility, // Gọi callback
                )
              : null,
        ),
        onFieldSubmitted: onSubmitted, // Kích hoạt khi nhấn "Enter"
      ),
    );
  }
}
