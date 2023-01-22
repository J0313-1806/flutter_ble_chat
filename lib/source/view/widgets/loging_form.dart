import 'package:b_le/source/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    return Obx(
      () => SizedBox(
        width: Get.width / 1.5,
        child: Column(
          children: <Widget>[
            authController.errorMessage.value.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Text(
                      authController.errorMessage.value,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  )
                : const Center(),
            const SizedBox(
              height: 10,
            ),
            const Text("To Use Cloud storage, Login/register first"),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: authController.usernameController.value,
              decoration: const InputDecoration(
                label: Text("Enter Email"),
                suffixIcon: Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: authController.passwordController.value,
              obscureText: authController.obscureText.value,
              decoration: InputDecoration(
                label: const Text("Enter Password"),
                suffixIcon: IconButton(
                  onPressed: authController.hidePassword,
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: authController.loginOrRegisterWithEmailAndPass,
              child: authController.loginLoader.value
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(),
                    )
                  : const Text(
                      "Login / Register",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
