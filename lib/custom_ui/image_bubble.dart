import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neos_chat/custom_ui/time_widget.dart';
import 'package:neos_chat/models/message_model.dart';
import 'package:neos_chat/services/message_service.dart';

class ImageBubble extends StatelessWidget {
  const ImageBubble({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: IntrinsicWidth(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomRight: isMe ? const Radius.circular(15) : Radius.zero,
                bottomLeft: isMe ? Radius.zero : const Radius.circular(15),
              ),
              color: color,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageView(o: message),
                const SizedBox(height: 4),
                TimeWidget(time: message.fileTime),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageView extends StatefulWidget {
  const ImageView({super.key, required this.o});
  final MessageModel o;

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool initial = widget.o.file!.dataSend != null ? true : false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          initial // widget.o.file!.path == null
              ? Image.memory(widget.o.file!.dataSend!, fit: BoxFit.contain)
              : Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.asset('assets/images/photo.jpg', fit: BoxFit.contain),
                  isLoading
                      ? const Padding(
                        padding: EdgeInsets.only(right: 5, bottom: 6),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          strokeAlign: -5,
                        ),
                      )
                      : IconButton(
                        onPressed: () async {
                          isLoading = true;
                          setState(() {});
                          try {
                            widget.o.file!.dataSend = await MessageService()
                                .downloadFiles(path: widget.o.file!.path!);
                            isLoading = false;
                            setState(() {});
                          } catch (e) {
                            log('error .. ${e.toString()}');
                            isLoading = false;
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.download_sharp, size: 30),
                      ),
                ],
              ),
    );
  }
}
