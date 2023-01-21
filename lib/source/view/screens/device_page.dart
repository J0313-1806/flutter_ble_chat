import 'package:b_le/source/controller/devices_controller.dart';
import 'package:b_le/source/controller/messages_controller.dart';
import 'package:b_le/source/view/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  // static final MessagesController _messagesController = Get.find();

  @override
  Widget build(BuildContext context) {
    final HomeController devicesController = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            devicesController.devices.clear();

            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.blue,
        ),
        title: const Text(
          "Devices nearby",
          style: TextStyle(color: Colors.blue),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(
        () {
          return devicesController.devices.isNotEmpty
              ? ListView.builder(
                  itemCount: devicesController.devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    var device =
                        devicesController.devices.values.elementAt(index);
                    return ExpansionTile(
                      title: Text(device.name),
                      leading: Text(device.id),
                      subtitle: Text(device.serviceId),
                      trailing: Icon(
                        device.isConnected
                            ? Icons.chat_rounded
                            : Icons.link_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () => devicesController.requestDevice(
                                  nickname: devicesController.username.value,
                                  deviceId: device.id),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.blue),
                                ),
                              ),
                              child: const Text("Connect"),
                            ),
                            TextButton(
                              onPressed: () => devicesController
                                  .disconnectDevice(id: device.id),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              child: const Text("Disconnect"),
                            ),
                            TextButton(
                              onPressed: () => Get.to(
                                () => Chat(
                                  appUser: devicesController.username.value,
                                  deviceId: device.id,
                                  deviceUsername: device.name,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.green),
                                ),
                              ),
                              child: const Icon(Icons.chat_rounded),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  // Widget buildConnectedDevices() {
  //   return Container(
  //     width: Get.width / 1.8,
  //     color: Colors.white,
  //     child: _messages_devicesController.connectedIdList.isEmpty
  //         ? const Center(
  //             child: Text("null"),
  //           )
  //         : ListView.builder(
  //             itemCount: _messages_devicesController.connectedIdList.length,
  //             itemBuilder: (context, index) {
  //               return ListTile(
  //                 title: Text(
  //                   _messagesController.connectedIdList[index],
  //                 ),
  //               );
  //             },
  //           ),
  //   );
  // }
}
