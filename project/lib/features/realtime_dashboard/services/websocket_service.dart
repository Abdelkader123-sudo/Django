import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:project/core/strings/connection.dart';

import '../models/measurement.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Object? _connectError;
  final Logger _logger = Logger();

  WebSocketService() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(socketUrl));
    } catch (error, stackTrace) {
      _connectError = error;
      _logger.e('WebSocket connection failed', error: error, stackTrace: stackTrace);
    }
  }

  Stream<Measurement> get measurements {
    if (_channel == null) {
      return Stream<Measurement>.error(
        _connectError ?? const FormatException('WebSocket unavailable'),
      );
    }

    return _channel!.stream.map((event) {
      _logger.i('Received raw event: $event');

      final json = jsonDecode(event);
      return Measurement.fromJson(json);
    }).asBroadcastStream();
  }

  Future<void> dispose() async {
    await _channel?.sink.close();
  }
}
