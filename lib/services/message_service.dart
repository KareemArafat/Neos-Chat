import 'dart:async';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:neos_chat/core/api.dart';
import 'package:neos_chat/core/const.dart';
import 'package:neos_chat/core/shard.dart';
import 'package:neos_chat/models/message_model.dart';
import 'package:neos_chat/services/socket_service.dart';

class MessageService {
  Future<MessageModel> sendMessage({
    required String mess,
    required String roomId,
  }) async {
    MessageModel message = MessageModel(roomId: roomId, text: mess);
    final completer = Completer<void>();
    SocketService().socket.emitWithAck(
      'sendMessage',
      message.toJson(),
      ack: (data) {
        message.messageId = data['messageId'];
        message.senderId = data['senderId'];
        completer.complete();
      },
    );
    await completer.future;
    return message;
  }

  Future<MessageModel> sendFiles({
    required String roomId,
    required Uint8List bytesFile,
    required String name,
    required String type,
  }) async {
    final message = MessageModel(
      roomId: roomId,
      fileTime: DateFormat('hh:mm a').format(DateTime.now()),
      file: MediaFile(
        dataSend: bytesFile,
        type: type, //    'image'  'video'  'sound'  'record'  'file',
        name: name,
      ),
    );
    final completer = Completer<void>();
    SocketService().socket.emitWithAck(
      'uploadFiles',
      message.toJson(),
      ack: (data) {
        message.messageId = data['messageId'];
        message.senderId = data['senderId'];
        completer.complete();
      },
    );
    await completer.future;
    return message;
  }

  Future<Uint8List?> downloadFiles({required String path}) async {
    String token = await ShardModel().getToken();
    final response = await Api().getFile(
      url: "$baseUrl/download?path=$path&&token=$token",
    );
    return response;
  }

  void receiveMessages({
    required void Function(MessageModel message) onMessageReceived,
  }) async {
    String senderId = await ShardModel().getSenderId();
    SocketService().socket.on('message', (data) {
      if (senderId != data['senderId']) {
        onMessageReceived(MessageModel.fromJson(data));
      }
    });
  }

  void sendReact({required String messageId, required String react}) {
    SocketService().socket.emit('sendReact', {
      'messageId': messageId,
      'react': react,
    });
  }

  void receiveReact({
    required void Function(String messageId, String react) onReactReceived,
  }) {
    SocketService().socket.on('receiveReact', (data) {
      onReactReceived(data['messageId'], data['type']);
    });
  }

  Future<String> aiMessage({required String message}) async {
    final responseData = await Api().post(
      url: "http://localhost:3000/chat",
      body: {'message': message},
    );
    return responseData;
  }
}
