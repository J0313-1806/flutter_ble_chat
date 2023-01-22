import 'dart:convert';
import 'dart:developer';
import 'package:b_le/source/controller/auth_controller.dart';
import 'package:b_le/source/database/local.dart';
import 'package:b_le/source/model/message.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';

class MessagesController extends GetxController {
  // final HomeController _devicesController = Get.find();

  var messages = <Message>[].obs;
  var username = ''.obs;
  var connectedIdList = <String>[].obs;

  /// return true if the device id is included in the list of connected devices
  bool isDeviceConnected(String id) =>
      connectedIdList.contains(id) ? true : false;

  /// add the device id to the list of connected devices
  void onConnect(String id) => connectedIdList.add(id);

  /// remove the device id from the list of connected devices
  void onDisconnect(String id) =>
      connectedIdList.removeWhere((element) => element == id);

  /// getting the index of message in list to store in local
  var messageIndex = -1.obs;

  void onSendMessage(
      {required String toId,
      required String toUsername,
      required String fromId,
      required String fromUsername,
      required String message}) {
    /// Add the message object received to the messages list
    messages.add(Message(
      sent: true,
      toId: toId,
      fromId: "",
      toUsername: toUsername,
      fromUsername: fromUsername,
      message: message,
      dateTime: DateTime.now(),
    ));

    savingChat(
        toUsername,
        messageIndex,
        Message(
          sent: true,
          toId: toId,
          fromId: "",
          toUsername: toUsername,
          fromUsername: fromUsername,
          message: message,
          dateTime: DateTime.now(),
        ));

    /// This will force a widget rebuild
    update();
  }

  void onReceiveMessage(
      {required String fromId,
      required Payload payload,
      required ConnectionInfo fromInfo}) async {
    /// Once receive a payload in the form of Bytes,
    if (payload.type == PayloadType.BYTES) {
      /// we will convert the bytes into String
      var unitList = (payload.bytes);
      var code = unitList!.toList();
      String messageString = utf8.decode(code);

      /// Add the message object to the messages list
      messages.add(
        Message(
          toId: "",
          sent: false,
          fromId: fromId,
          fromUsername: fromInfo.endpointName,
          toUsername: username.value,
          message: messageString,
          dateTime: DateTime.now(),
        ),
      );
      savingChat(
        fromInfo.endpointName,
        messageIndex,
        Message(
          toId: "",
          sent: false,
          fromId: fromId,
          fromUsername: fromInfo.endpointName,
          toUsername: username.value,
          message: messageString,
          dateTime: DateTime.now(),
        ),
      );
    }

    /// This will force a widget rebuild
    update();
  }

  /// Saving the messages in local storage
  void savingChat(String deviceName, int msgIndex, Message messages) {
    LocalX.storeChat(deviceName, msgIndex, messages);
  }

  /// Getting the messages from local storage
  void gettingChat(String deviceName) async {
    List<Message> msg = LocalX.getChat(deviceName) as List<Message>;

    messages.addAll(msg);

    log("chats ${messages.last}");
  }

  void backupToCloud() {
    AuthController authController = Get.find();
    // var backupMessages = messageToJson(messages);
    // log("backupMessages: $backupMessages");
    authController.backingUpToCloud();
  }
}
