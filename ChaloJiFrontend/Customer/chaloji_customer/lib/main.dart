import 'package:chaloji_customer/presentation/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
//import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChaloJi Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CustomerHomeScreen(), 
    );
  }
}