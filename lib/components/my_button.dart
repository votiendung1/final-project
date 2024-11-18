import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
       child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 196, 200, 255), // Màu nền
          borderRadius: BorderRadius.circular(12), // Bo góc
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Màu bóng đổ
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5), // Tọa độ bóng đổ
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 55, 55),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
