import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_flutter_android/services/mqtt_service.dart';
import 'package:provider/provider.dart';

// // THE SUBSCRIBER WIDGET
class SubscriberPage extends StatefulWidget {
  const SubscriberPage({super.key});
  @override
  _SubscriberPageState createState() => _SubscriberPageState();
}

// // THE STATE MANAGER ==================================================================
class _SubscriberPageState extends State<SubscriberPage> {

  ValueNotifier<String> messageValueNotifier = ValueNotifier<String>('');
  @override
  void dispose() {
    messageValueNotifier.dispose();
    super.dispose();
  }
  // -------------------------------------------

  _SubscriberPageState();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  MqttService mqttServiceSub = MqttService();

  // Status Colors for the Subscriber UI
  Color _getStatusColor() {
    switch (_statusController.text.toUpperCase()) {
      case 'SUBSCRIBED':
        return Colors.green;
      case 'UNSUBSCRIBED':
        return Colors.red;
      default:
        return Colors.orange; // Return black for any other status text
    }
  }

  // // ==============================================================================
  // // INITIALIZATION ---------------------------------------------------------------
  // // ==============================================================================
  @override
  void initState() {
    super.initState();
    mqttServiceSub.connect('client_sub');
  }
  // // ==============================================================================
  // // INITIALIZATION ENDED ---------------------------------------------------------
  // // ==============================================================================
  void _subscribeToTopic(mqttServiceSub) async {
    final topic = _topicController.text.trim();

    print('mqtt service sub : $mqttServiceSub');
    if (topic.isNotEmpty) {
      print('Subscribing to Topic: $topic');
      //_mqttConnection.subscribe(topic, MqttQos.atLeastOnce);
      //_statusController.text = 'SUBSCRIBED';
      print('mqtt qos : $MqttQos.atLeastOnce');

      try {
        // Ensure that the MQTT client is connected before subscribing
        await mqttServiceSub.connect('flutter_client');
      } catch (e) {
        print('Failed to connect to MQTT broker: $e');
        return;
      }

      // After connecting, subscribe to the topic
      mqttServiceSub.subscribe(topic, MqttQos.atLeastOnce);
      setState(() {
        _statusController.text = 'SUBSCRIBED'; // Update status controller text
      });
      print('Subscribed to Topic: $topic');
    } else {
      //_statusController.text = '';
      setState(() {
        _statusController.text = ''; // Update status controller text
      });
      print('Failed to subscribe: Topic is empty.');
    }
  }

// async added
  void _unsubscribeFromTopic(mqttServiceSub) async {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty) {
      // --------------------------------------------------------------------
      print('Unsubscribing from Topic: $topic');

      mqttServiceSub.unsubscribe(topic);

      setState(() {
        _statusController.text = 'UNSUBSCRIBED';
      });

      print('Unsubscribed from Topic: $topic');
      // -----------------------------------------------------------------------
    } else {
      //_statusController.text = '';
      setState(() {
        _statusController.text = ''; // Update status controller text
      });
      print('Failed to unsubscribe.');
    }
  }

  // ------------------------------------------------------------------------
  // List<String> messageList = [];
  // void displayMessage(String message) {
  //   messageList.add(message);
  // }

  String combinedMessages = '';

  void displayMessage(String topic, String message) {
    String formattedMessage = 'Received Message: $message\nOn topic: $topic\n';
    combinedMessages = formattedMessage + combinedMessages;
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
    ValueNotifier<String> data2Notifier =
        Provider.of<MqttService>(context).data;
    String? data2 = data2Notifier.value;
    bool isSnackbarDisplayed = false;
    // ---------------------------------------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Home (Flutter)'),
      ),
      body: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
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
              'Subscriber',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            // ?
            //Divider(), // Add a divider
            // --- TOPIC ------------------------------------------------
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
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _topicController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // --------------------------------------------
                      ),
                    ],
                  ),
                  // -- MESSAGE -------------------------------------------------
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
                            color: const Color.fromRGBO(239, 255, 243, 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          // -----------------------------------------------
                          // child: TextField(
                          //   controller: _messageController,
                          //   textAlign: TextAlign.center,
                          //   maxLines: 10,
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(),
                          //   ),
                          // ),
                          // // --- DISPLAY PUBLISHED MESSAGES ------------------------------------
                          child: ValueListenableBuilder<String>(
                            valueListenable: messageValueNotifier,
                            //valueListenable: myListNotifier,
                            //valueListenable: mqttServiceSub.data,
                            builder: (BuildContext context, String value,
                                Widget? child) {
                              if (data2 != null && data2.isNotEmpty) {
                                print('value (data2) : $data2');
                              }

                              // --------------------------------------------------------------
                              return TextField(
                                //controller: _messageController,
                                controller: TextEditingController(text: data2),
                                textAlign: TextAlign.center,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                //readOnly: true,
                              );
                              // --------------------------------------------------------
                           },
                            // builder
                            // -----------------------------------------------------
                          ),
                          //valueListenable: mqttServiceSub.data,
                          // child 2
                        ),
                        // child 1
                      ),
                    ], // Children
                  ),
                  // ---STATUS-------------------------------------------------
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          'Status',
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
                            color: const Color.fromRGBO(223, 247, 255, 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _statusController,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //--------------------------
                                color: _getStatusColor(),
                                fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // --- SUBSCRIBE BUTTON ----------------------------------------------
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        //onPressed: () {},
                        //onPressed: _subscribeToTopic,
                        //onPressed: () => _subscribeToTopic(mqttServiceSub),
                        onPressed: () {
                          var mqttServiceSub =
                          Provider.of<MqttService>(context, listen: false);
                          _subscribeToTopic(mqttServiceSub);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Subscribe',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // --- UNSUBSCRIBE BUTTON -----------------------------------------------------------
                      const SizedBox(width: 16),
                      ElevatedButton(
                        //onPressed: () {},
                        //onPressed: _unsubscribeFromTopic,
                        //onPressed: () => _unsubscribeFromTopic(mqttServiceSub),
                        onPressed: () {
                          var mqttServiceSub =
                          Provider.of<MqttService>(context, listen: false);
                          _unsubscribeFromTopic(mqttServiceSub);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Unsubscribe',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // ----- NOTIFICATIONS(SNACK BAR) ----------------------------------------------------------------
                  // Snackbar Notifications
                  const SizedBox(height: 8),
                  Builder(
                    builder: (BuildContext context) {
                      String? data2 =
                          Provider.of<MqttService>(context).data.value;
                      // Show Snackbar with data2 value
                      // WidgetsBinding.instance!.addPostFrameCallback((_) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text('New meesage arrived : $data2'),
                      //       duration: Duration(seconds: 3),
                      //     ),
                      //   );
                      // });
                      // -------------------------------------------------------------------------
                      if (data2 != null &&
                          data2.isNotEmpty &&
                          !isSnackbarDisplayed) {
                        // Show Snackbar with data2 value
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Notification : New Message '$data2' arrived."),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        });
                        isSnackbarDisplayed = true;
                      }
                      // Placeholder widget
                      return Container();
                    },
                  ),
                  // -----------------------------------------------------------------------------------------------
                ],
              ),
            ),
            // ------------------------------------------
          ], // children
        ), // Column
        // -------------------------------------------
      ),
      ), // container to single child scroll view
    );
  }
// // ==============================================================================
// // INTERFACE ENDED ==============================================================
// // ==============================================================================
}
