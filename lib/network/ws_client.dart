import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  final Uri uri;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  WsClient({String url = 'ws://localhost:5000/ws'}) : uri = Uri.parse(url);

  void connect(void Function(dynamic message) onMessage,
      {void Function()? onDone, void Function(Object error)? onError}) {
    _channel = WebSocketChannel.connect(uri);
    _sub = _channel!.stream.listen(onMessage, onError: onError, onDone: onDone);
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  Future<void> close() async {
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }
}
