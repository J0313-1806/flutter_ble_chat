import 'dart:convert';
import 'dart:developer';
// import 'dart:typed_data';

import 'package:b_le/source/controller/messages_controller.dart';
import 'package:b_le/source/database/local.dart';
import 'package:b_le/source/model/device.dart';
import 'package:b_le/source/view/widgets/show_bottom_modal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';

class HomeController extends GetxController {
  /// **P2P_CLUSTER** is a peer-to-peer strategy that supports an M-to-N,
  /// or cluster-shaped, connection topology.
  Strategy strategy = Strategy.P2P_CLUSTER;

  /// Here we do the Dependency Injection of various classes
  Nearby nearby = Nearby();
  var deviceInfo = DeviceInfoPlugin();

  /// Nickname of the logged in user
  var username = ''.obs;

  /// List of devices detected
  var devices = <String, Device>{}.obs;

  /// List of connected devices
  var connectedDevices = <String, Device>{}.obs;

  /// Name of the connected device
  var connectedDeviceName = "".obs;

  /// The one who is requesting the info of a device
  var requestorId = '0'.obs;
  ConnectionInfo? advertiserInfo;

  /// The one who is being requested with an info
  var requesteeId = '0'.obs;
  ConnectionInfo? browserInfo;

  /// Shows when request has been send
  var requestingLoader = false.obs;

  /// When advertise Device function is initiated
  RxBool advertiseFuncInitiated = RxBool(false);

  /// When broswer fuction is initiated
  RxBool browserFuncInitiated = RxBool(false);

  @override
  void onReady() async {
    super.onReady();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    username.value = androidDeviceInfo.model;
    advertiseDevice();
    searchNearbyDevices();
  }

  @override
  void onClose() {
    // messagesController.connectedIdList.clear();
    nearby.stopAllEndpoints();
    nearby.stopDiscovery();
    nearby.stopAdvertising();
    super.onClose();
  }

  /// Discover nearby devices
  void searchNearbyDevices() async {
    try {
      MessagesController messagesController = Get.put(MessagesController());
      if (await nearby.checkLocationEnabled() &&
          await nearby.checkBluetoothPermission()) {
        await nearby.startDiscovery(
          username.value,
          strategy,
          onEndpointFound: (id, name, serviceId) {
            log("id: $id\nname: $name\nserviceID: $serviceId");

            LocalX.openChatBox(name);

            // messagesController.gettingChat(name);

            /// Once an endpoint is found, add it
            /// to the end of the devices observable
            devices.putIfAbsent(
                name,
                () => Device(
                    id: id,
                    name: name,
                    serviceId: serviceId,
                    isConnected: false));
          },
          onEndpointLost: (id) {
            // messagesController.onDisconnect(id ?? "");
            // devices.remove(id);
            nearby.disconnectFromEndpoint(id ?? "");
          },
        );
      } else {
        nearby.askBluetoothPermission();
        await nearby.askLocationPermission();
      }
    } catch (e) {
      log('there is an error searching for nearby devices:: $e');
    }
  }

  /// Advertise own device to other devices nearby
  void advertiseDevice() async {
    try {
      await nearby.startAdvertising(
        username.value,
        strategy,
        onConnectionInitiated: (idn, info) {
          advertiseFuncInitiated(true);

          /// Remove first the device from the list in case it was already there
          /// This duplication could occur since we combine advertise and discover
          log("advertiseConnection\nid: $idn\nendpoint name: ${info.endpointName}\nrequestorId: $requestorId");
          devices.putIfAbsent(
              info.endpointName,
              () => Device(
                  id: idn,
                  name: info.endpointName,
                  serviceId: "com.example.b_le",
                  isConnected: false));

          /// We are about to use this info once we add the device to the device list
          advertiserInfo = info;
          requestorId(idn);

          /// show the bottom modal widget
          Get.bottomSheet(
            ShowBottomModal(
                cId: requestorId.value.toString(), id: idn, info: info),
            backgroundColor: Get.theme.appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          );
        },
        onConnectionResult: (id, status) {
          MessagesController messagesController = Get.find();
          advertiseFuncInitiated(false);
          if (status == Status.CONNECTED) {
            messagesController.onConnect(id);

            connectedDevices.putIfAbsent(id, () => devices[id]!);
            log("connected: $connectedDevices");

            /// Add to device list
            devices.update(id, (value) {
              value.isConnected = true;
              return value;
            }
                // (value) => Device(
                //     id: id,
                //     name: advertiserInfo!.endpointName,
                //     serviceId: "com.example.b_le",
                //     isConnected: status == Status.CONNECTED ? true : false),
                );
            // } else if (status == Status.REJECTED) {
            //   /// Add to device list
            //   devices.add(Device(
            //       id: id,
            //       name: requestorDeviceInfo.endpointName,
            //       serviceId: requestorDeviceInfo.endpointName,
            //       isConnected: false));
            // }
          }
        },
        onDisconnected: (endpointId) {
          advertiseFuncInitiated(false);
          // messagesController.onDisconnect(endpointId);

          /// Remove the device from the device list
          devices.remove(endpointId);
        },
        // serviceId: "com.example.b_le",
      );
      log("devices: \n\t$devices");
    } catch (e) {
      advertiseFuncInitiated(false);
      log('there is an error advertising the device:: $e');
    }
  }

  /// Request to connect to other devices
  void requestDevice({
    required String nickname,
    required String deviceId,
  }) async {
    // final overlay = LoadingOverlay.of(requestContext);

    // overlay.show();
    try {
      await nearby.requestConnection(
        nickname,
        deviceId,
        onConnectionInitiated: (id, info) {
          browserFuncInitiated(true);
          // overlay.hide();
          log("requestConnection\nndpointName: ${info.endpointName}\nauthToken: ${info.authenticationToken}\ndeviceID: $deviceId\nid: $id");

          /// We are about to use this info once we add the device to the device list
          browserInfo = info;
          requesteeId(id);

          /// show the bottom modal widget
          Get.bottomSheet(ShowBottomModal(cId: id, id: deviceId, info: info));
        },
        onConnectionResult: (endpointId, status) {
          connectedDevices.putIfAbsent(deviceId, () => devices[deviceId]!);
          log("connected: $connectedDevices");
          browserFuncInitiated(false);
          log("$endpointId : $status");
        },
        onDisconnected: (value) {
          browserFuncInitiated(false);
          // messagesController.onDisconnect(deviceId);
          log("on disconnect: $value");
        },
      );
    } catch (e) {
      browserFuncInitiated(false);
      log('there is an error requesting to connect to a device:: $e');
      if (e.toString() ==
          "PlatformException(Failure, 8003: STATUS_ALREADY_CONNECTED_TO_ENDPOINT, null, null)") {
        disconnectDevice(id: deviceId);
      }
    }
  }

  /// Disconnect from another device
  void disconnectDevice({required String id}) async {
    try {
      // messagesController.onDisconnect(id);
      log("diconnecting deviceID: $id");
      // await nearby.disconnectFromEndpoint(id);
      devices.update(id, (value) {
        value.isConnected = false;
        return value = value;
      });
    } catch (e) {
      log('there is an error disconnecting the device:: $e');
    }
  }

  /// Reject request to connect to another device
  void rejectConnection({required String id}) async {
    try {
      // messagesController.onDisconnect(id);
      await nearby.rejectConnection(id);
    } catch (e) {
      log('there is an error in rejection:: $e');
    }
  }

  /// Accept request to connect to another device
  void acceptConnection({required String id}) async {
    try {
      MessagesController messagesController = Get.find();
      log("accepting deviceID: $id");
      // messagesController.onConnect(id);
      await nearby.acceptConnection(
        id,
        onPayLoadRecieved: (endId, payload) {
          log("connected: \npayload: $payload\nendID: $endId");
          advertiserInfo;
          browserInfo;
          Future.delayed(const Duration(milliseconds: 0), () {
            messagesController.onReceiveMessage(
              fromId: endId,
              fromInfo: advertiserInfo ?? browserInfo!,
              payload: payload,
            );
          });
        },
      ).then((value) {
        if (value) {
          log("recieved message succesfully");
          // Get.back();
        }
      }).catchError((onError) {
        log("accept connection: $onError");
        return;
      });
    } catch (e) {
      log('there is an error accepting connection from another device:: $e');
    }
  }

  /// Send message to another device
  Future<bool> sendMessage(
      {required String toId,
      required String toUsername,
      required String fromId,
      required String fromUsername,
      required String message}) async {
    try {
      MessagesController messagesController = Get.find();
      // if (connectedDevices.containsKey(toId)) {
      await nearby.sendBytesPayload(
          toId, Uint8List.fromList(utf8.encode(message)));
      //     .then((value) {
      //   log("then got executed");
      // }).catchError((onError) {
      //   log('there is an error sending message to another device:: $onError');
      // });
      Future.delayed(
          const Duration(seconds: 0),
          () => messagesController.onSendMessage(
              toId: toId,
              toUsername: toUsername,
              fromId: fromId,
              fromUsername: fromUsername,
              message: message));
      log("message send successfully");
      return true;
      // } else {
      //   return false;
      // }
    } catch (e) {
      log('there is an error sending message to another device:: $e');
      return false;
    }
  }
}
