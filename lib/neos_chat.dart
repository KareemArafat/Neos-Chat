library neos_chat;

import 'package:neos_chat/core/shard.dart';
import 'package:neos_chat/services/auth_service.dart';
import 'package:neos_chat/services/message_service.dart';
import 'package:neos_chat/services/rooms_service.dart';
import 'package:neos_chat/services/socket_service.dart';

export 'custom_ui/chat_text_field.dart';
export 'custom_ui/file_bubble.dart';
export 'custom_ui/image_bubble.dart';
export 'custom_ui/recording_button.dart';
export 'custom_ui/sound_bubble.dart';
export 'custom_ui/text_bubble.dart';
export 'custom_ui/video_bubble.dart';

class NeosChat {
  static final NeosChat _instance = NeosChat._internal();
  NeosChat._internal();
  factory NeosChat() => _instance;

  Future<void> initialize({
    required String userName,
    required String userId,
    required String appToken,
    required String apiKey,
  }) async {
    await AuthService().initializeAuth(
      userName: userName,
      userId: userId,
      appToken: appToken,
      apiKey: apiKey,
    );
  }

  Future<void> connectToServer() async {
    String token = await ShardModel().getToken();
    String apiKey = await ShardModel().getApiKey();
    SocketService().connectToServer(token, apiKey);
  }

  void closeServerConnection() {
    SocketService().closeServerConnection();
  }

  final MessageService _messageService = MessageService();
  MessageService get messages => _messageService;

  final RoomsService _roomsService = RoomsService();
  RoomsService get rooms => _roomsService;
}
