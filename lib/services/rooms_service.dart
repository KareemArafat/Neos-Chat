import 'dart:async';
import 'dart:developer';
import 'package:neos_chat/core/api.dart';
import 'package:neos_chat/core/const.dart';
import 'package:neos_chat/core/shard.dart';
import 'package:neos_chat/models/room_model.dart';
import 'package:neos_chat/services/socket_service.dart';

class RoomsService {
  Future<List<RoomModel>?> getRooms() async {
    String userId = await ShardModel().getUserId();
    try {
      final dataList = await Api().get(url: "$baseUrl/rooms?userId=$userId");
      List<RoomModel>? roomsList = [];
      for (int i = 0; i < dataList['rooms'].length; i++) {
        roomsList.add(RoomModel.fromJson(dataList['rooms'][i]));
      }
      return roomsList;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<bool> createRoom({
    required String type,
    required List<String> members,
    String? roomName,
  }) async {
    final completer = Completer<bool>();
    SocketService().socket.emitWithAck(
      'createRoom',
      {'type': type, 'roomName': roomName, 'members': members},
      ack: (response) {
        if (response != null && response['status'] == 'success') {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  void joinRoom(String roomId) {
    SocketService().socket.emit('joinRoom', {'roomId': roomId});
  }

  void typingResult({
    required void Function(String userId, bool typing) typingFn,
  }) {
    SocketService().socket.on('isTyping', (data) {
      typingFn(data['userId'], data['isTyping']);
    });
  }

  void typingCheck(String roomId, bool isTyping) {
    SocketService().socket.emit('isTyping', {
      'roomId': roomId,
      'isTyping': isTyping,
    });
  }

  void onlineResult({
    required void Function(String userId, bool online) onlineFn,
  }) {
    SocketService().socket.on('isOnline', (data) {
      onlineFn(data['userId'], data['isOnline']);
    });
  }

  void onlineCheck(RoomModel room) async {
    String receiverId;
    String senderId = await ShardModel().getSenderId();
    if (room.usersIds!.length == 2) {
      for (var id in room.ids!) {
        if (id != senderId) {
          receiverId = id;
          Timer.periodic(const Duration(seconds: 10), (timer) async {
            SocketService().socket.emit('isOnline', {'userId': receiverId});
          });
        }
      }
    }
  }

  void recordingResult({
    required void Function(String userId, bool recording) recordFn,
  }) {
    SocketService().socket.on('isRecording', (data) {
      recordFn(data['userId'], data['isRecording']);
    });
  }

  void recordCheck(String roomId, bool isRecording) {
    SocketService().socket.emit('isRecording', {
      'roomId': roomId,
      'isRecording': isRecording,
    });
  }
}
