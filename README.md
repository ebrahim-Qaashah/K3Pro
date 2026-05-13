# SMT Sensor

Flutter package for USB serial communication with K3_Pro_Spy temperature sensor.

## Features

- **Auto-connect**: Automatically finds K3ProSpy sensor among CP2104 devices
- USB serial communication with ESP32-based K3_Pro_Spy sensor
- Send commands: GetID, GetName, GetVal
- Receive JSON responses
- Stream-based data handling
- Error handling and connection management
- Filter devices by VID/PID (CP2104: 0x10C4/0xEA60)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  smt_sensor:
    path: ../SMTsensor
```

## Usage

### Auto-Connect (Recommended)

The easiest way to connect to a K3ProSpy sensor:

```dart
import 'package:smt_sensor/smt_sensor.dart';

// Create sensor instance
final sensor = K3ProSpySensor();

// Listen to data stream
sensor.dataStream.listen((data) {
  print('Received: $data');
  if (data.mID != null) print('ID: ${data.mID}');
  if (data.mType != null) print('Type: ${data.mType}');
  if (data.mVal != null) print('Value: ${data.mVal}');
});

// Listen to errors and progress
sensor.errorStream.listen((message) {
  print('Status: $message');
});

// Auto-connect: Scans all CP2104 devices and finds K3ProSpy
bool connected = await sensor.autoConnect();

if (connected) {
  print('Connected to: ${sensor.connectedDevice?.deviceName}');
  
  // Use the sensor
  final valueData = await sensor.getValue();
  print('Temperature: ${valueData?.mVal}°C');
  
  // Disconnect when done
  await sensor.disconnect();
}

// Clean up
sensor.dispose();
```

### Manual Connect

Connect to a specific device:

```dart
// Get available devices
final devices = await sensor.getAvailableDevices();

// Or get only CP2104 devices
final cp2104Devices = await sensor.getCP2104Devices();

if (devices.isNotEmpty) {
  // Connect to specific device
  bool connected = await sensor.connect(devices.first);
  
  if (connected) {
    // Send commands
    await sensor.sendCommand(SensorCommand.getID);
    await sensor.sendCommand(SensorCommand.getName);
    await sensor.sendCommand(SensorCommand.getValue);
    
    // Or use convenience methods
    final idData = await sensor.getID();
    final nameData = await sensor.getName();
    final valueData = await sensor.getValue();
    
    // Disconnect when done
    await sensor.disconnect();
  }
}
```

## Android Permissions

Add to `AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.usb.host" />
<uses-permission android:name="android.permission.USB_PERMISSION" />
```

## Commands

- **GetID**: Returns sensor ID as `{"mID": "01A0661000"}`
- **GetName**: Returns sensor type as `{"mType": "K3ProSpy"}`
- **GetVal**: Returns current value as `{"mVal": 123.4}`

## License

MIT
