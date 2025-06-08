import 'package:flutter/material.dart';

class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    this.controller,
    this.changed,
    this.submitted,
    this.emojiFn,
    this.attachmentsFn,
    this.cameraFn,
    required this.backgroundColor,
    required this.itemsColor,
  });
  final TextEditingController? controller;
  final Function(String)? changed;
  final Function(String)? submitted;
  final void Function()? emojiFn;
  final void Function()? attachmentsFn;
  final void Function()? cameraFn;
  final Color backgroundColor;
  final Color itemsColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          onChanged: changed,
          controller: controller,
          onSubmitted: submitted,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            hintText: 'Type message...',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 56,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: itemsColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: itemsColor, width: 2),
            ),
          ),
        ),
        Positioned(
          left: 6,
          child: IconButton(
            onPressed: emojiFn,
            icon: Icon(Icons.emoji_emotions, color: itemsColor),
          ),
        ),
        Positioned(
          right: 8,
          child: IconButton(
            onPressed: attachmentsFn,
            icon: Icon(Icons.attach_file, color: itemsColor),
          ),
        ),
      ],
    );
  }
}
