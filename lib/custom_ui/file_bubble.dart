import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neos_chat/custom_ui/time_widget.dart';
import 'package:neos_chat/models/message_model.dart';
import 'package:neos_chat/services/message_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FileBubble extends StatelessWidget {
  const FileBubble({
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomRight: isMe ? const Radius.circular(15) : Radius.zero,
                bottomLeft: isMe ? Radius.zero : const Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                FileView(o: message),
                const SizedBox(height: 4),
                const TimeWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FileView extends StatefulWidget {
  const FileView({super.key, required this.o});
  final MessageModel o;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool initial = widget.o.file!.dataSend != null ? true : false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Image.asset(
            'assets/images/file.jpg',
            height: 150,
            width: 140,
            fit: BoxFit.fill,
          ),
          initial
              ? GestureDetector(
                onTap: () async {
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/${widget.o.file!.name}');
                  await file.writeAsBytes(
                    widget.o.file!.dataSend! as List<int>,
                  );
                  await OpenFilex.open(file.path);
                },
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              : isLoading
              ? const Padding(
                padding: EdgeInsets.only(right: 5, bottom: 6),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  strokeAlign: -5,
                  color: Colors.deepPurpleAccent,
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
                  }
                },
                icon: const Icon(Icons.download_sharp, size: 30),
              ),
        ],
      ),
    );
  }
}
