import 'dart:developer';
import 'package:neos_chat/core/const.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket socket;

  void connectToServer(String token, String apiKey) {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token, 'key': apiKey},
    });
    socket.connect();
    socket.off('connect');
    socket.off('disconnect');
    socket.onConnect((data) => log('server is connected ^_^'));
    socket.onDisconnect((data) => log('server is disconnected >_<'));
    socket.onError((error) => log('Socket client side error: $error'));
  }

  void closeServerConnection() {
    socket.disconnect();
    socket.dispose();
  }
}
