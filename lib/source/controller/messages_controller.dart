import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:b_le/source/controller/auth_controller.dart';
import 'package:b_le/source/database/local.dart';
import 'package:b_le/source/model/message.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Loader to show when file is uploading to cloud
  var uploadingFile = false.obs;

  /// Loader to show when fetching file from the cloud
  var downloadingFile = false.obs;

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

  /// Getting Hive file for Cloud backup
  void backupToCloud(String name) async {
    try {
      uploadingFile(true);
      AuthController authController = Get.find();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      "/data/com.example.b_le/app_flutter/m2012k11ai.hive";
      File file = File(
          "$appDocPath/$name.hive"); //  File file = File("$appDocPath/m2006c3li.hive");
      await authController.uploadFile(file: file, fileName: name);
      // if (task != null && task.state == TaskState.success) {
      //   uploadingFile(false);
      // } else {}
    } catch (e) {
      log("Error caught on backing to cloud: $e");
    } finally {
      uploadingFile(false);
    }
  }

  /// Saving Hive File from Cloud
  void downloadFromCloud(String name) async {
    try {
      downloadingFile(true);
      AuthController authController = Get.find();

      await authController.downloadFile(fileName: name);
    } catch (e) {
      log("Error caught on downloading backup from cloud: $e");
    } finally {
      downloadingFile(false);
    }
  }
}
