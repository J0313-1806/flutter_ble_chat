import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AuthController extends GetxController {
  /// Initializing firebase authentication
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Initializing Firebase Firestore
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializing Firebase Storage
  final _storage = FirebaseStorage.instance;

  /// Checks if user is signed in or not
  User? get currentUser => _firebaseAuth.currentUser;

  /// Checks if user is logged or not
  var userExists = false.obs;

  /// Listens if User has signed in or signed out
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Username Text Editing controller
  var usernameController = TextEditingController().obs;

  /// Password Text Editing controller
  var passwordController = TextEditingController().obs;

  /// String of error message
  var errorMessage = "".obs;

  /// Obscuring password
  var obscureText = true.obs;

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
          userExists(true);
          // currentUser.reauthenticateWithCredential(credential)
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
    } finally {
      update;
    }
  }

  /// For Loggin out from Device
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      Get.snackbar("Signed Out", "You are no longer Signed In",
          backgroundColor: Colors.grey);
      userExists(false);
    } catch (e) {
      log("Sign out error: $e");
    }
  }

  /// For backing up the file on to Firebase Storage
  Future<TaskSnapshot?> uploadFile(
      {required File? file, required String? fileName}) async {
    try {
      if (currentUser != null) {
        final ref = _storage.ref(currentUser!.uid).child(fileName!);
        if (file != null) {
          final task = await ref.putFile(file);

          // task.then((p0) {
          if (task.state == TaskState.success) {
            log("Backup uploaded successfully!");
            return task;
          } else {
            log("Task State: $task");
          }
          // }).catchError((onError) {
          // log("Task Error: $onError");
          // });
        } else {
          Get.snackbar("No File Found!", "Please try agiain",
              backgroundColor: Colors.grey);
          log("File not found");
        }
      } else {
        Get.snackbar("No User Found!", "Please login or register",
            backgroundColor: Colors.grey);
        return null;
      }
    } catch (e) {
      Get.snackbar("Uploading backup error", "$e",
          backgroundColor: Colors.blue);
      log("backing cloud: $e");
    } finally {
      // imageUploading(false);
    }
    return null;
  }

  /// Downloading file from Firebase Storage
  Future<void> downloadFile({required String fileName}) async {
    try {
      if (currentUser != null) {
        final reference =
            _storage.ref().child("${currentUser!.uid}/$fileName"); //.hive

        final appDocDir = await getApplicationDocumentsDirectory();
        final filePath =
            "${appDocDir.path}/$fileName.hive"; //! it will replace the file if another with same name exists
        final file = File(filePath);

        await reference.writeToFile(file).then((task) {
          if (task.state == TaskState.success) {
            Get.snackbar("Backup Downloaded",
                "Please restart the app to get the backed up messages",
                backgroundColor: Colors.blue);
          } else {
            log("Error fetching backup: $task");
          }
        });
      } else {
        Get.snackbar("No User Found!", "Please login or register",
            backgroundColor: Colors.blue);
      }
    } catch (e) {
      Get.snackbar("Downloading backup error", "$e",
          backgroundColor: Colors.blue);
      log("Downloading backup error: $e");
    }
  }

  /// To hide the password or not
  void hidePassword() {
    obscureText.toggle();
  }

  @override
  void onReady() {
    super.onReady();
    currentUser != null ? userExists(true) : userExists(false);
  }

  @override
  void onClose() {
    usernameController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }
}
