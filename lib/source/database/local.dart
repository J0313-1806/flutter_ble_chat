import 'package:b_le/source/model/message.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

void initHive() async {
  /// initializes hive
  await Hive.initFlutter();

  /// registers the custom model class for hive
  Hive.registerAdapter(MessageAdapter());
}

void disposeHive() async {
  /// closes the hive's all storage boxes, before closing the app
  await Hive.close();
}

class LocalX extends GetxController {
  static void openChatBox(String deviceName) async {
    /// opens the box for saving chats
    await Hive.openBox<Message>(deviceName);
  }

  /// gets the hhive box
  static Box<dynamic> chatBox(String deviceName) =>
      Hive.box<Message>(deviceName);

  /// stores the chat of ther specified deivce in local storage
  static storeChat(String deviceName, int messageIndex, Message message) {
    chatBox(deviceName).put(messageIndex, message);
  }

  /// gets the stored chats of the specified device
  static List<dynamic> getChat(String deviceName) =>
      chatBox(deviceName).values.toList();

  /// Fetching box for cloud backup
  static Box<Message> getBoxForBackup(String name) {
    return Hive.box(name);
  }

  @override
  void onClose() {
    disposeHive();
    super.onClose();
  }
}
