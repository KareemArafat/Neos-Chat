import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neos_chat/custom_ui/time_widget.dart';
import 'package:neos_chat/models/message_model.dart';

class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.color,
  });
  final MessageModel message;
  final bool isMe;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.only(
              top: 5,
              bottom: 5,
              left: 14,
              right: 14,
            ),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30),
                topRight: const Radius.circular(30),
                bottomRight: isMe ? const Radius.circular(30) : Radius.zero,
                bottomLeft: isMe ? Radius.zero : const Radius.circular(30),
              ),
              color: color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    message.text ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                TimeWidget(time: formatTime(message.time)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null) {
      return DateFormat('hh:mm a').format(DateTime.now());
    } else if (time.length > 10) {
      final dateTime = DateTime.tryParse(time);
      return dateTime != null ? DateFormat('hh:mm a').format(dateTime) : time;
    } else {
      return time;
    }
  }
}
