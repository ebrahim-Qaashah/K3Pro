import 'package:flutter/material.dart';
import 'package:smt_sensor/smt_sensor.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K3 Pro Spy Sensor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SensorPage(),
    );
  }
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final K3ProSpySensor K3Thermometer = K3ProSpySensor();
  String _sensorID = '';
  String _sensorType = '';
  double? _sensorValue;
  String _status = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setupListeners();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  void _setupListeners() {
    K3Thermometer.dataStream.listen((data) {
      setState(() {
        if (data.mID != null) _sensorID = data.mID!;
        if (data.mType != null) _sensorType = data.mType!;
        if (data.mVal != null) _sensorValue = data.mVal;
      });
    });

    K3Thermometer.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });
  }

  Future<void> _autoConnect() async {
    setState(() {
      _status = 'Connecting...';
    });

    final connected = await K3Thermometer.autoConnect();
    setState(() {
      _status = connected ? 'Connected' : 'Connection failed';
    });
  }

  Future<void> _disconnect() async {
    await K3Thermometer.disconnect();
    setState(() {
      _status = 'Disconnected';
      _sensorID = '';
      _sensorType = '';
      _sensorValue = null;
    });
  }

  Future<void> _sendCommand(SensorCommand command) async {
    if (!K3Thermometer.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to device')),
      );
      return;
    }

    await K3Thermometer.sendCommand(command);
  }

  @override
  void dispose() {
    K3Thermometer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('K3 Pro Spy Sensor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: K3Thermometer.isConnected ? null : _autoConnect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Connect'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: K3Thermometer.isConnected ? _disconnect : null,
                          icon: const Icon(Icons.close),
                          label: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('ID: ${_sensorID.isEmpty ? 'N/A' : _sensorID}'),
                    Text('Type: ${_sensorType.isEmpty ? 'N/A' : _sensorType}'),
                    Text(
                      'Value: ${_sensorValue == null ? 'N/A' : _sensorValue!.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _sendCommand(SensorCommand.getID),
                  child: const Text('Get ID'),
                ),
                ElevatedButton(
                  onPressed: () => _sendCommand(SensorCommand.getName),
                  child: const Text('Get Name'),
                ),
                ElevatedButton(
                  onPressed: () => _sendCommand(SensorCommand.getValue),
                  child: const Text('Get Value'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
