import 'package:b_le/source/controller/devices_controller.dart';
import 'package:b_le/source/controller/messages_controller.dart';
import 'package:b_le/source/model/message.dart';
import 'package:b_le/source/view/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends StatefulWidget {
  final String deviceId;
  final String deviceUsername;
  final String appUser;

  const Chat({
    required this.deviceId,
    required this.deviceUsername,
    required this.appUser,
    super.key,
  });

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.delayed(const Duration(seconds: 0), () => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    MessagesController messagesController = Get.find();
    messagesController.messages.isNotEmpty
        ? _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final MessagesController messagesController = Get.find();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.deviceUsername,
            style: const TextStyle(color: Colors.blue),
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            Obx(() => IconButton(
                  onPressed: () async {
                    MessagesController messagesController = Get.find();
                    await messagesController
                        .backupToCloud(widget.deviceUsername.toLowerCase());
                  },
                  icon: messagesController.uploadingFile.value
                      ? const CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        )
                      : const Icon(
                          Icons.cloud_upload,
                          color: Colors.blue,
                        ),
                )),
            Obx(() => IconButton(
                  onPressed: () {
                    MessagesController messagesController = Get.find();
                    messagesController
                        .downloadFromCloud(widget.deviceUsername.toLowerCase());
                  },
                  icon: messagesController.downloadingFile.value
                      ? const CircularProgressIndicator(
                          backgroundColor: Colors.blue)
                      : const Icon(
                          Icons.cloud_download,
                          color: Colors.blue,
                        ),
                )),
          ],
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Flexible(
              child: GetX<MessagesController>(
                init: MessagesController(),
                builder: (controller) {
                  // WidgetsBinding.instance
                  //     .addPostFrameCallback((_) => _scrollToBottom());

                  List<Message> messages = controller.messages;

                  return messages.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            // controller.savingChat(
                            //     widget.deviceUsername, index, messages[index]);
                            controller.messageIndex(index);
                            return ChatBubble(
                                message: messages[index],
                                deviceUsername: widget.deviceUsername,
                                appUser: widget.appUser);
                          },
                        )
                      : const Center(
                          child: Text(
                            "Start chatting",
                            style: TextStyle(color: Colors.blue),
                          ),
                        );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: _buildTextComposer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    final messageController = TextEditingController();

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                controller: messageController,
                decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: 'Send a message',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 20,
                  ),
                ),
                style: const TextStyle(fontSize: 20),
                onEditingComplete: () {
                  onSendButtonPress(
                    controller: messageController,
                    context: context,
                  );
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            ClipOval(
              child: Material(
                borderRadius: BorderRadius.circular(50),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      splashColor: Colors.greenAccent[400],
                      highlightColor: Colors.greenAccent[400],
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        onSendButtonPress(
                          controller: messageController,
                          context: context,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSendButtonPress({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final HomeController devicesController = Get.find();
    if (controller.text.isNotEmpty) {
      var connectionState = await devicesController.sendMessage(
        toId: widget.deviceId,
        toUsername: widget.deviceUsername,
        fromUsername: widget.appUser,
        message: controller.text,
        fromId: "",
      );

      if (!connectionState) {
        Get.defaultDialog(
          title: 'Connection Status',
          middleText:
              'The message is not sent.\n${widget.deviceUsername} is offline at the moment.',
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      }

      controller.clear();
    }
  }
}
