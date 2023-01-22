import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  /// Initializing firebase authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Initializing Firebase Firestore
  // final FirebaseAuth _firestore = Fire;

  /// Checks if user is signed in or not
  User? get currentUser => _firebaseAuth.currentUser;

  /// Listens if User has signed in or signed out
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Username Text Editing controller
  var usernameController = TextEditingController().obs;

  /// Password Text Editing controller
  var passwordController = TextEditingController().obs;

  /// String of error message
  var errorMessage = "".obs;

  /// Obscuring password
  var obscureText = false.obs;

  /// Login/register loader
  var loginLoader = false.obs;

  /// To login or registering the user
  Future<void> loginOrRegisterWithEmailAndPass() async {
    errorMessage.value = "";
    try {
      loginLoader(true);
      if (usernameController.value.text.isNotEmpty &&
          passwordController.value.text.isNotEmpty) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: usernameController.value.text,
            password: passwordController.value.text);

        if (currentUser != null) {
          loginLoader(false);
          errorMessage.value = "";
          Get.snackbar("Log in Successful", "Login completed",
              backgroundColor: Colors.blue);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "network-request-failed") {
        errorMessage("Please connect to internet");
        loginLoader(false);
        return;
      }
      if (e.code == "wrong-password") {
        loginLoader(false);
        Get.defaultDialog(
          title: "Forget Password?",
          middleText: "Send code to the email for resetting password?",
          onConfirm: () {
            _firebaseAuth.sendPasswordResetEmail(
                email: usernameController.value.text);

            Get.back();
          },
        );
        errorMessage("code has been Send on the given email to reset password");
        return;
      }
      if (e.code == "user-not-found") {
        var user = await _firebaseAuth.createUserWithEmailAndPassword(
            email: usernameController.value.text,
            password: passwordController.value.text);
        errorMessage.value = "Account created!\nClick on button to login";
        log(user.toString());
        loginLoader(false);
        return;
      } else {
        loginLoader(false);
        errorMessage("$e");
        log("Sign in with email and password function error: $e");
      }
    }
  }

  /// Backing up seleted user chat to Firestore
  void backingUpToCloud() {}

  /// To hide the password or not
  void hidePassword() {
    obscureText.toggle();
  }

  @override
  void onClose() {
    usernameController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }
}
