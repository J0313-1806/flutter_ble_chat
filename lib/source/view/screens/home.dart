import 'dart:developer';
import 'dart:io';

import 'package:b_le/source/controller/auth_controller.dart';
import 'package:b_le/source/view/screens/device_page.dart';
import 'package:b_le/source/view/widgets/loging_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextButton(
              onPressed: () async {
                Directory appDocDir = await getApplicationDocumentsDirectory();
                String appDocPath = appDocDir.path;
                "/data/com.example.b_le/app_flutter/m2012k11ai.hive";
                File file = File("$appDocPath/m2006c3li.hive");

                await _authController.uploadFile(
                    file: file, fileName: "m2006c3li");
                // var read = await file.length();
                log("hive: $appDocPath");
              },
              child: const Text(
                "upload",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                Directory appDocDir = await getApplicationDocumentsDirectory();
                String appDocPath = appDocDir.path;
                "/data/com.example.b_le/app_flutter/m2012k11ai.hive";
                File file = File("$appDocPath/m2006c3li.hive");

                await _authController.downloadFile(fileName: "m2006c3li");
                var read = await file.length();
                log("hive: $read");
              },
              child: const Text(
                "download",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _authController.signOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              const Align(alignment: Alignment.center, child: LoginForm()),
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
