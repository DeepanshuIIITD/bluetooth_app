import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  String knownMacAddress = "20:34:fb:53:99:c5"; // Replace with your known MAC address
  List<ScanResult> discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen for scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        BluetoothDevice device = result.device;
        String deviceMacAddress = device.id.toString();
        if (deviceMacAddress == knownMacAddress && !discoveredDevices.contains(result)) {
          // Found a device with the known MAC address
          setState(() {
            discoveredDevices.add(result);
          });
        }
      }
    });

    // Stop scanning after a delay (you can adjust this)
    await Future.delayed(Duration(seconds: 10));
    flutterBlue.stopScan();

    // Cancel the subscription
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Scanning for Bluetooth devices...',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(discoveredDevices[index].device.name ?? 'Unknown Device'),
                  subtitle: Text('RSSI: ${discoveredDevices[index].rssi}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
