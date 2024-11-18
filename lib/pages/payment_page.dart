import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/pages/delivery_progress_page.dart';
import 'package:food_delivery_app/services/database/firestore.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  // người dùng muốn trả tiền
  void userTappedPay() async {
    if (formKey.currentState!.validate()) {
      // hiện thị nếu hợp lệ
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("xác nhận thanh toán"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Số Thẻ: $cardNumber"),
                Text("Ngày Hết Hạn: $expiryDate"),
                Text("Tên Chủ Thẻ: $cardHolderName"),
                Text("Mã CVV: $cvvCode"),
              ],
            ),
          ),
          actions: [
            // button ko
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Không"),
            ),

            // button có
            TextButton(
              onPressed: () async {
                // Xóa toàn bộ giỏ hàng trong Firebase
                await FirestoreService().clearCart();

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryProgressPage(),
                  ),
                );
              },
              child: const Text("Có"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Kiểm tra"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Thẻ tín dụng
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (p0) {},
              ),

              // Thẻ tín dụng form (giới hạn không gian linh hoạt)
              Expanded(
                child: SingleChildScrollView(
                  child: CreditCardForm(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    onCreditCardModelChange: (data) {
                      setState(() {
                        cardNumber = data.cardNumber;
                        expiryDate = data.expiryDate;
                        cardHolderName = data.cardHolderName;
                        cvvCode = data.cvvCode;
                      });
                    },
                    formKey: formKey,
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          );
        },
      ),
      bottomNavigationBar: _buttonAddPayment(context),
    );
  }

  Widget _buttonAddPayment(BuildContext context) {
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
            onTap: userTappedPay,
            text: "Mua ngay",
          ),
        ],
      ),
    );
  }
}
