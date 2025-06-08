import 'dart:typed_data';

class MessageModel {
  String? senderId;
  String? roomId;
  String? messageId;
  String? time;
  String? text;
  MediaFile? file;
  String? fileTime;
  List<String>? reacts;

  MessageModel({
    this.senderId,
    this.roomId,
    this.messageId,
    this.time,
    this.text,
    this.file,
    this.fileTime,
    this.reacts,
  });

  factory MessageModel.fromJson(jsonData) {
    return MessageModel(
      senderId: jsonData['senderId'],
      roomId: jsonData['roomId'],
      messageId: jsonData['_id'],
      time: jsonData['createdAt'],
      text: jsonData['text'],
      file: jsonData['file'] != null
          ? MediaFile.fromJson(jsonData['file'])
          : null,
      fileTime: jsonData['time'],
      reacts: jsonData['reacts'] != null
          ? List<String>.from(jsonData['reacts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'roomId': roomId,
        '_id': messageId,
        'createdAt': time,
        'text': text,
        'file': file?.toJson(),
        'time': fileTime,
        'reacts': reacts,
      };
}

class MediaFile {
  Uint8List? dataSend;
  String? path;
  String? name;
  String? type;

  MediaFile({
    this.dataSend,
    this.path,
    this.name,
    this.type,
  });

  factory MediaFile.fromJson(jsonData) {
    return MediaFile(
      dataSend: jsonData['data'],
      path: jsonData['path'],
      name: jsonData['name'],
      type: jsonData['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data': dataSend,
        'path': path,
        'name': name,
        'type': type,
      };
}
