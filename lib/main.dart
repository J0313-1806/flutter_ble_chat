import 'package:b_le/source/bindings/app_binding.dart';
import 'package:b_le/source/view/screens/device_page.dart';
import 'package:b_le/source/view/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.native,
      initialBinding: AppBindings(),
      theme: ThemeData(
        backgroundColor: Colors.white,
        primaryColor: const Color(0xFF6c65f8),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black54),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
