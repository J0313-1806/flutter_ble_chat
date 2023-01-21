import 'package:b_le/source/model/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final String deviceUsername;
  final String appUser;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.deviceUsername,
      required this.appUser});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double defaultWidth = width * 2 / 3;

    return Align(
      alignment: message.sent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color:
              message.sent ? Theme.of(context).primaryColor : Colors.blue[50],
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(10, 10),
              color: Colors.black12,
            ),
          ],
        ),
        constraints: BoxConstraints(maxWidth: defaultWidth),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              message.sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.sent ? appUser : deviceUsername,
              style: TextStyle(
                fontSize: 16,
                color: message.sent
                    ? Colors.grey[300]
                    : Colors.grey.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message.message,
              style: TextStyle(
                fontSize: 20,
                color: message.sent
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                // : Colors.black54,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message.dateTime.toLocal().toString().substring(10, 19),
              style: TextStyle(
                fontSize: 16,
                color: message.sent
                    ? Colors.grey[300]
                    : Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
