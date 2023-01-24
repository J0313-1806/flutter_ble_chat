import 'package:b_le/source/controller/auth_controller.dart';
import 'package:b_le/source/database/local.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(LocalX());
    Get.put(AuthController());
  }
}
