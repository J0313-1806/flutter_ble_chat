import 'package:b_le/source/bindings/app_binding.dart';
import 'package:b_le/source/database/local.dart';
import 'package:b_le/source/view/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  // needed to ensure initializing of different modeules necessary for app to function
  WidgetsFlutterBinding.ensureInitialized();

  // initialize hive for local storage
  initHive();

  // initializes firebase app for using its api's
  await Firebase.initializeApp();
  runApp(const MyApp());
}

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
