import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// // ======================================================================================
// // MQTT CONNECTION SERVICE ==============================================================
// // ======================================================================================
class MqttService with ChangeNotifier {
  late MqttServerClient client;
  // CONFIG
  //final SERVER_URL = 'ws://192.168.0.108:9001';
  //final SERVER_HOST = 'ws://192.168.0.108';
  final SERVER_HOST = 'broker.emqx.io';
  //final SERVER_URL = 'ws://10.0.2.16';
  //final SERVER_URL = 'ws://127.0.0.1';
  final CLIENT_IDENTIFIER = 'flutter_client';
  //final PORT_NUMBER = 9001;
  // TCP PORT
  final PORT_NUMBER = 1883;
  // WEB SOCKET PORT : 8083

  // DECLARATIONS FOR CLIENT UPDATE
  final ValueNotifier<String> data = ValueNotifier<String>("");
  final ValueNotifier<String> messageValueNotifier = ValueNotifier<String>('');

  final builder = MqttClientPayloadBuilder();

  // CONNECT
  Future<Object> connect(String clientIdentifier) async {
    client =
        MqttServerClient.withPort(SERVER_HOST, clientIdentifier, PORT_NUMBER);
    // client =
    //     MqttServerClient(SERVER_HOST, clientIdentifier);
    //client.port = PORT_NUMBER;
    // ------------------------------------------------------------
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.keepAlivePeriod = 60;
    client.setProtocolV311();
    client.autoReconnect = true;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
    final connMessage = MqttConnectMessage()
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    print('MQTT_LOGS::MQTT Client connecting....');
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT_LOGS::MQTT Client connected');
    } else {
      print(
          'MQTT_LOGS::ERROR MQTT Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return -1;
    }
    print('MQTT_LOGS::Subscribing to the test/sample topic');
    const topic = 'test/sample';
    client.subscribe(topic, MqttQos.atLeastOnce);
    print('MQTT_LOGS:: test subscription done');
    clientUpdate(client);

    return client;
  }

  // CLIENT UPDATE
  void clientUpdate(MqttServerClient client) {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      data.value = pt;
      print(
          'MQTT_LOGS:: New data arrived: topic is <${c[0].topic}>, payload is $pt');
      print('');

      // Provider.of<MqttClient>(context as BuildContext, listen: false)
      //     .messageValueNotifier
      //     .value = pt;

      notifyListeners();

      // -----------------------------------------------------------
      // // Show Snackbar notification
      // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      //   SnackBar(
      //     content: Text('New Data Arrived: Topic: ${c[0].topic}, Payload: $pt'),
      //     duration: Duration(seconds: 3), // Duration for Snackbar to be visible
      //   ),
      // );

      // ---------------------------------------------------------------
    });
  }

  // // CALLBACKS ----------------------------------------------------------------------
  void onConnected() {
    print('MQTT_LOGS:: Connected');
  }

  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void pong() {
    print('MQTT_LOGS:: Ping response client callback invoked');
  }

  void onAutoReconnect() {
    print('MQTT_LOGS:: Initiating client auto reconnection sequence.');
  }

  void onAutoReconnected() {
    print(
        'MQTT_LOGS:: Client auto reconnection sequence completed successfully.');
  }

  Subscription? subscribe(String topic, MqttQos qosLevel) {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      throw Exception('MQTT_LOGS:: MQTT client is not connected.');
    }
    Subscription subscription =
    client.subscribe(topic, qosLevel) as Subscription;
    // Listen for updates on the subscription
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      data.value = pt;
    });
    return subscription;
  }

  IMqttConnectionHandler? connectionHandler;
  Map<int, MqttPublishMessage> publishedMessages = <int, MqttPublishMessage>{};

  bool handlePublishAcknowledgement(MqttMessage? msg) {
    final ackMsg = msg as MqttPublishAckMessage;
    // If we're expecting an ack for the message, remove it from the list of pubs awaiting ack.
    final messageIdentifier = ackMsg.variableHeader.messageIdentifier;
    MqttLogger.log(
        'PublishingManager::handlePublishAcknowledgement for message id $messageIdentifier');
    if (publishedMessages.keys.contains(messageIdentifier)) {
      //notifyPublish(publishedMessages[messageIdentifier!]);
      publishedMessages.remove(messageIdentifier);
    }
    return true;
  }

  handleMessage(String messages) {
    if (messages != null && messages.isNotEmpty) {
      print('Received message (!) : $messages');
    }
    return messages;
  }

  void unsubscribe(String topic, {expectAcknowledge = false}) {
    client.unsubscribe(topic, expectAcknowledge: expectAcknowledge);
  }

// ---------------------------------------------------------------------------
  void publishMessage(String pubTopic, String message) {
    //const pubTopic = 'test/sample';
    print('pub topic1 : $pubTopic');
    print('pub message1 : $message');
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

// // --------------------------------------------------------------------------------------
}
// // CLASS Mqtt Service ENDED ===============================================================