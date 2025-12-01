// MUST be in a separate file or at top-level (not inside a class)

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;

// Global variables for managing connection state
bool _isRunning = true;
WebSocket? _socket;
Timer? _reconnectTimer;

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  print('Background service started');

  // Get arguments from service
  final String? clientId = service.arguments?["client_id"];
  final String? baseUrl = service.arguments?["base_url"];

  if (clientId == null || baseUrl == null) {
    print('Missing required arguments: client_id or base_url');
    service.stopSelf();
    return;
  }

  Future<void> connectWebSocket() async {
    try {
      print('Attempting to connect WebSocket...');

      // Close existing connection if any
      await _socket?.close();

      _socket = await WebSocket.connect(
        '$baseUrl/stream/ws/$clientId',
        headers: {
          'User-Agent': 'FlutterBackgroundService/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      print('WebSocket connected successfully');

      // Configure socket
      _socket?.pingInterval = const Duration(seconds: 30);

      // Listen to WebSocket messages
      _socket?.listen(
        (raw) {
          try {
            final data = jsonDecode(raw);
            print('WebSocket message received');
            service.invoke('ws_message', data);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
            print('Raw message: $raw');
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          scheduleReconnection(service, clientId, baseUrl);
        },
        onError: (err) {
          print('WebSocket error: $err');
          scheduleReconnection(service, clientId, baseUrl);
        },
        cancelOnError: true,
      );
    } catch (err) {
      print('WebSocket connection failed: $err');
      scheduleReconnection(service, clientId, baseUrl);
    }
  }

  void scheduleReconnection(
      ServiceInstance service, String clientId, String baseUrl) {
    _socket = null;

    if (!_isRunning) {
      print('Service stopping, not reconnecting');
      return;
    }

    // Cancel existing timer
    _reconnectTimer?.cancel();

    // Schedule reconnection with exponential backoff
    final delay = Duration(seconds: _calculateReconnectDelay());
    print('Scheduling reconnection in ${delay.inSeconds} seconds');

    _reconnectTimer = Timer(delay, () {
      if (_isRunning) {
        connectWebSocket();
      }
    });
  }

  int _reconnectAttempts = 0;

  int _calculateReconnectDelay() {
    _reconnectAttempts++;

    // Exponential backoff with max 60 seconds
    final delay = pow(1.5, _reconnectAttempts).toInt();

    // Reset attempts after successful connection
    if (delay >= 60) {
      return 60;
    }
    return delay;
  }

  // Start initial connection
  await connectWebSocket();

  // Listen for binding commands from UI
  service.on('bind').listen((event) async {
    print('Received bind command: ${event.toString()}');

    final routingKey = event?["routing_key"];
    final queueName = event?["queue_name"];
    final userId = event?["user_id"];

    if (routingKey == null || queueName == null || userId == null) {
      service.invoke('bind_result', {'error': 'Missing required parameters'});
      return;
    }

    final body = jsonEncode({
      'routing_key': routingKey,
      'queue_name': queueName,
    });

    final url = '$baseUrl/user/$userId/bind';

    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('Bind response status: ${res.statusCode}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final responseData = jsonDecode(res.body);
        service.invoke('bind_result', responseData);
      } else {
        service.invoke('bind_result', {
          'error': 'HTTP ${res.statusCode}',
          'message': res.body,
        });
      }
    } on TimeoutException {
      service.invoke('bind_result', {'error': 'Request timeout'});
    } on SocketException catch (e) {
      service.invoke('bind_result', {'error': 'Network error: ${e.message}'});
    } catch (e) {
      service.invoke('bind_result', {'error': e.toString()});
    }
  });

  // Listen for unbinding commands from UI
  service.on('unbind').listen((event) async {
    print('Received unbind command: ${event.toString()}');

    final routingKey = event?["routing_key"];
    final queueName = event?["queue_name"];
    final userId = event?["user_id"];

    if (routingKey == null || queueName == null || userId == null) {
      service.invoke('unbind_result', {'error': 'Missing required parameters'});
      return;
    }

    final url = '$baseUrl/user/$userId/unbind';

    try {
      final res = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'routing_key': routingKey,
              'queue_name': queueName,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Unbind response status: ${res.statusCode}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final responseData = jsonDecode(res.body);
        service.invoke('unbind_result', responseData);
      } else {
        service.invoke('unbind_result', {
          'error': 'HTTP ${res.statusCode}',
          'message': res.body,
        });
      }
    } on TimeoutException {
      service.invoke('unbind_result', {'error': 'Request timeout'});
    } on SocketException catch (e) {
      service.invoke('unbind_result', {'error': 'Network error: ${e.message}'});
    } catch (e) {
      service.invoke('unbind_result', {'error': e.toString()});
    }
  });

  // Listen for stop command
  service.on('stop').listen((event) {
    print('Received stop command');
    _isRunning = false;
    _reconnectTimer?.cancel();
    _socket?.close();
    service.stopSelf();
  });

  // Listen for ping command (for testing connection)
  service.on('ping').listen((event) async {
    print('Received ping command');
    service.invoke('pong', {'timestamp': DateTime.now().toIso8601String()});
  });

  // Send startup notification
  service.invoke('service_started', {
    'timestamp': DateTime.now().toIso8601String(),
    'client_id': clientId,
  });

  // Keep service running
  while (_isRunning) {
    await Future.delayed(const Duration(seconds: 1));
  }

  print('Background service stopping');
}

// Helper function to start the service from your main app
Future<void> startBackgroundService({
  required String clientId,
  required String baseUrl,
}) async {
  final service = FlutterBackgroundService();

  // Configure service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: 'your_channel_id',
      initialNotificationTitle: 'Background Service',
      initialNotificationContent: 'Running',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onStartIos,
    ),
  );

  // Start service with arguments
  await service.startService(
      // clientId,
      // baseUrl,
      );
// iOS background handler
  @pragma('vm:entry-point')
  Future<void> onStartIos(ServiceInstance service) async {
    // iOS-specific initialization if needed
    onStart(service);
  }
}
