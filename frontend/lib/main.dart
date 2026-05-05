import 'package:flutter/material.dart';
import 'Pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStudio',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xff3B82F6),
          secondary: const Color(0xff2563EB),
          surface: const Color(0xffffffff),
        ),
        scaffoldBackgroundColor: const Color(0xffE8F0FE),
        fontFamily: 'Outfit',
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}