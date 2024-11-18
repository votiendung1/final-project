import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/pages/home_page.dart';
import 'package:food_delivery_app/pages/setting_page.dart';
import 'package:food_delivery_app/services/auth/auth_gate.dart';
import 'package:food_delivery_app/firebase_options.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/services/auth/login_or_register.dart';
import 'package:food_delivery_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Tạo một instance của Restaurant
  final restaurant = Restaurant();

  // Tải dữ liệu giỏ hàng từ Firebase
  await restaurant.init();

  runApp(
    MultiProvider(
      providers: [
        // chủ đề
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // nhà hàng cung cấp
        ChangeNotifierProvider(create: (context) => Restaurant()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      // initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginOrRegister(),
        '/home': (context) => const HomePage(),
        '/setting': (context) => const SettingPage(),
      },
    );
  }
}
