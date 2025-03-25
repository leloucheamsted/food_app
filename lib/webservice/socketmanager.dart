import 'package:flutter/material.dart';
import 'package:slike/utils/constant.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketManager {
  static SocketManager? _instance;
  io.Socket? _socket;

  factory SocketManager() {
    _instance ??= SocketManager._internal();
    return _instance!;
  }

  String socketUrl() {
    return Constant.socketUrl;
  }

  SocketManager._internal() {
    _socket = io.io(socketUrl(), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'timeout': 5000,
    });

    socket?.on('connect', (_) {
      debugPrint('Connected to server');
    });

    socket?.onConnectError((data) {
      debugPrint('Connection Error: $data');
    });

    socket?.onError((data) {
      debugPrint('Error: $data');
    });

    socket?.onDisconnect((_) {
      debugPrint('Disconnected from Socket.io server');
    });
  }

  goLive(userId, roomId) async {
    socket?.emit('goLive', {"user_id": userId, "room_id": roomId});
  }

  addView(userId, roomId) async {
    socket?.emit('addView', {"user_id": userId, "room_id": roomId});
  }

  removeListner() async {
    socket?.off("liveChatToClient");
    socket?.off("liveChat");
    socket?.off("addViewCountToClient");
    socket?.off("sendGiftToClient");
  }

  io.Socket? get socket => _socket;
}
