import 'package:b_le/source/controller/auth_controller.dart';
import 'package:b_le/source/view/screens/device_page.dart';
import 'package:b_le/source/view/widgets/loging_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: _authController.signOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.blue,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(child: LoginForm()),
            const SizedBox(
              height: 20,
            ),
            Center(
              // alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const DevicePage());
                },
                child: const Text("Search nearby devices"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
