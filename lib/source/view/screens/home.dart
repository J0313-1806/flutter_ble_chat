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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.center,
                child: _authController.currentUser != null
                    ? const Text(
                        "Logged In!",
                        style: TextStyle(color: Colors.blue),
                      )
                    : const LoginForm(),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const DevicePage());
                  },
                  child: const Text("Search nearby devices"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
