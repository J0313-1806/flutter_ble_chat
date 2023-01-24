import 'package:b_le/source/controller/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';

/// Called upon Connection request (on both devices)
/// Both need to accept connection to start sending/receiving
class ShowBottomModal extends StatelessWidget {
  ShowBottomModal(
      {super.key, required this.cId, required this.id, required this.info});
  String cId;
  String id;
  ConnectionInfo info;
  final HomeController _devicesController = Get.find();
  @override
  Widget build(BuildContext context) {
    // String cId, String id, ConnectionInfo info
    return Container(
      color: Colors.white70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          const Text('Request to connect.'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _devicesController.rejectConnection(
                  id: info.endpointName,
                ),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () =>
                    _devicesController.acceptConnection(id: id, info: info),
                child: const Text("Yes"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
