import 'package:b_le/source/controller/home_controller.dart';
import 'package:b_le/source/view/screens/device_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
                child: SizedBox(
                  width: Get.width / 1.5,
                  child: TextFormField(
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      label: Text("Enter username"),
                    ),
                  ),
                ),
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
