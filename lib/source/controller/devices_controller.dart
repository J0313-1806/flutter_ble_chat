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
  var connectedDevices = <String, bool>{}.obs;

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

  /// Scanning nearby devices
  var scanningDevices = false.obs;

  /// To check if bluetooth permission has given
  var isBluetoothPermissionGiven = false.obs;

  /// To check if location is on
  var isLocationOn = false.obs;

  /// To check if location permission has given
  var isLocationPermissionGiven = false.obs;

  /// Connection Initiated loader
  var connectingLoader = false.obs;

  @override
  void onReady() async {
    super.onReady();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    username.value = androidDeviceInfo.model;
    isBluetoothPermissionGiven.value = await nearby.checkBluetoothPermission();
    isLocationPermissionGiven.value = await nearby.checkLocationPermission();
    isLocationOn.value = await nearby.checkLocationEnabled();
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

  /// To ask and check for bluetooth permission
  void getBluetoothPermission() async {
    nearby.askBluetoothPermission();

    if (isBluetoothPermissionGiven.value) {
      Get.defaultDialog(
        title: "Bluetooth permission acquired!",
        middleText: "Please turn on your bluetooth,\nif its off",
        onConfirm: () async {
          Get.back();
        },
      );
    } else {
      Get.defaultDialog(
        title: "Bluetooth permission required!",
        middleText: "Please give Bluetooth permission",
        onConfirm: () {
          nearby.askBluetoothPermission();

          Get.back();
          const GetSnackBar(
            title: "Bluetooth is permission given",
          );
        },
      );
    }
  }

  /// To ask and check location permission
  void getLocationPermission() async {
    if (isLocationPermissionGiven.value) {
      Get.defaultDialog(
        title: "Location permission acquired!",
        middleText: "Please turn on your location,\nif its off",
        onConfirm: () async {
          Get.back();
        },
      );
    } else {
      Get.defaultDialog(
        title: "Location permission required!",
        middleText: "Please give Location permission",
        onConfirm: () async {
          isLocationPermissionGiven.value =
              await nearby.askLocationPermission();

          Get.back();
          const GetSnackBar(
            title: "Location permission given",
          );
        },
      );
    }
  }

  /// Discover nearby devices
  void searchNearbyDevices() async {
    try {
      if (isBluetoothPermissionGiven.value && isLocationPermissionGiven.value) {
        scanningDevices.value = true;
        await nearby.startDiscovery(
          username.value,
          strategy,
          onEndpointFound: (id, name, serviceId) {
            scanningDevices.value = false;
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
            scanningDevices.value = false;
            devices.remove(id);
            nearby.disconnectFromEndpoint(id ?? "");
          },
        );
      } else {
        scanningDevices.value = false;
        getBluetoothPermission();
        getLocationPermission();
      }
    } catch (e) {
      scanningDevices.value = false;
      log('there is an error searching for nearby devices:: $e');
    }
  }

  /// Advertise own device to other devices nearby
  void advertiseDevice() async {
    try {
      MessagesController messagesController = Get.put(MessagesController());
      await nearby.startAdvertising(
        username.value,
        strategy,
        onConnectionInitiated: (idn, info) {
          connectingLoader.value = true;

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

          messagesController.gettingChat(info.endpointName);
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
          connectingLoader.value = false;
          MessagesController messagesController = Get.find();
          // advertiseFuncInitiated(false);
          if (status == Status.CONNECTED) {
            messagesController.onConnect(id);

            connectedDevices.putIfAbsent(id, () => true);
            log("connected: $connectedDevices");

            /// Add to device list
            devices.update(id, (value) {
              value.isConnected = true;
              return value;
            });
          }
        },
        onDisconnected: (endpointId) {
          connectingLoader.value = false;

          /// Remove the device from the device list
          connectedDevices.remove(endpointId);
        },
        // serviceId: "com.example.b_le",
      );
      log("devices: \n\t$devices");
    } catch (e) {
      connectingLoader.value = false;
      // advertiseFuncInitiated(false);
      log('there is an error advertising the device:: $e');
    }
  }

  /// Request to connect to other devices
  void requestDevice({
    required String nickname,
    required String deviceId,
  }) async {
    try {
      MessagesController messagesController = Get.find();
      connectingLoader.value = true;
      await nearby.requestConnection(
        nickname,
        deviceId,
        onConnectionInitiated: (id, info) {
          log("requestConnection\nndpointName: ${info.endpointName}\nauthToken: ${info.authenticationToken}\ndeviceID: $deviceId\nid: $id");

          messagesController.gettingChat(info.endpointName);

          /// We are about to use this info once we add the device to the device list
          browserInfo = info;
          requesteeId(id);

          /// show the bottom modal widget
          Get.bottomSheet(ShowBottomModal(cId: id, id: deviceId, info: info));
        },
        onConnectionResult: (endpointId, status) {
          connectingLoader.value = false;
          connectedDevices.putIfAbsent(deviceId, () => true);
          log("connected: $connectedDevices");
          // browserFuncInitiated(false);
          log("$endpointId : $status");
        },
        onDisconnected: (value) {
          connectingLoader.value = false;
          connectedDevices.remove(deviceId);
          log("on disconnect: $value");
        },
      );
    } catch (e) {
      connectingLoader.value = false;
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
      await nearby.disconnectFromEndpoint(id);
      devices.update(id, (value) {
        value.isConnected = false;
        return value = value;
      });
      connectedDevices.remove(id);
    } catch (e) {
      Get.defaultDialog(
          title: "Could'nt disconnect roperly",
          middleText:
              "Either already connected or the endpoint is invalid\nTry restarting the app if its the latter",
          onConfirm: () => Get.back());
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
  void acceptConnection(
      {required String id, required ConnectionInfo info}) async {
    try {
      MessagesController messagesController = Get.find();
      log("accepting deviceID: $id");

      await nearby.acceptConnection(
        id,
        onPayLoadRecieved: (endId, payload) {
          log("connected: \npayload: $payload\nendID: $endId");

          Future.delayed(const Duration(milliseconds: 0), () {
            messagesController.onReceiveMessage(
              fromId: endId,
              fromInfo: info,
              payload: payload,
            );
          });
        },
      ).then((value) {
        if (value) {
          log("recieved message succesfully");
          Get.back();
        }
      }).catchError((onError) {
        Get.back();
        Get.defaultDialog(
            title: "Couldn't accept",
            middleText: "Try connecting again",
            onConfirm: () => Get.back());
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

      if (connectedDevices.containsKey(toId)) {
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
      } else {
        return false;
      }
    } catch (e) {
      log('there is an error sending message to another device:: $e');
      return false;
    }
  }
}
