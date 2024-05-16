import 'package:flutter/material.dart';
import 'package:mqtt_flutter_android/services/mqtt_service.dart';
import 'package:mqtt_flutter_android/views/subscriber.dart';
import 'package:provider/provider.dart';

// // THE PUBLISHER WIDGET
class PublisherPage extends StatefulWidget {
  @override
  _PublisherPageState createState() => _PublisherPageState();
}

// // THE STATE MANAGER ==================================================================
class _PublisherPageState extends State<PublisherPage> {
  // // ==============================================================================
  // // LOGIC ------------------------------------------------------------------------
  // // ==============================================================================
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  MqttService mqttServicePub = MqttService();
  // // ==============================================================================
  // // INITIALIZATION ---------------------------------------------------------------
  // // ==============================================================================
  @override
  void initState() {
    super.initState();
    mqttServicePub.connect('client_pub');
  }
  // // ==============================================================================
  // // INITIALIZATION ENDED ---------------------------------------------------------
  // // ==============================================================================

  void _publishMessage(mqttServicePub) {
    final pubTopic = _topicController.text.trim();
    final pubMessage = _messageController.text.trim();
    print('pub topic2 : $pubTopic');
    print('pub message2 : $pubMessage');

    if (pubTopic.isNotEmpty) {
      mqttServicePub.publishMessage(pubTopic, pubMessage);
    } else {
      print('Failed to publish.');
    }
  }


  // // ==============================================================================
  // // LOGIC ENDED ==================================================================
  // // ==============================================================================

  // // ==============================================================================
  // // INTERFACE ====================================================================
  // // ==============================================================================
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = (2 / 3) * screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Home (Flutter)'),
      ),
      body: SingleChildScrollView(
        child: Container(
        color: Colors.white,
        //color: Colors.grey[200],
        padding: const EdgeInsets.all(16.0),
        //padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MQTT Flutter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publisher',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            // --- TOPIC -----------------------------------------------
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200], // Set background color to gray
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Topic',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: boxWidth,
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Set background color of input box to white
                            borderRadius:
                            BorderRadius.circular(8.0), // Add border radius
                          ),
                          child: TextField(
                            controller: _topicController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // --- MESSAGE -------------------------------------------------------------
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Message',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: boxWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(8.0), // Add border radius
                          ),
                          child: TextField(
                            controller: _messageController,
                            textAlign: TextAlign.left,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // --- PUBLISH BUTTON -------------------------------------------------------------
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        //onPressed: () {},
                        //onPressed: _publishMessage(_mqttConnection),
                        onPressed: () => _publishMessage(mqttServicePub),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Background color
                        ),
                        child: const Text(
                          'Publish',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
// // ==============================================================================
// // INTERFACE ENDED ==============================================================
// // ==============================================================================
}
