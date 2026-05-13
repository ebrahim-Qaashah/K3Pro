# Auto-Connect Feature

## Overview

The `autoConnect()` method automatically finds and connects to a K3ProSpy sensor among all connected CP2104 USB devices.

## How It Works

1. **Scans for CP2104 devices** (VID: 0x10C4, PID: 0xEA60)
2. **Connects to each device** one by one
3. **Queries device name** using `GetName` command
4. **Checks if response** is "K3ProSpy"
5. **Keeps connection** if match found, otherwise disconnects and tries next device
6. **Returns true** if K3ProSpy found, false otherwise

## Usage

### Basic Usage

```dart
import 'package:smt_sensor/smt_sensor.dart';

final sensor = K3ProSpySensor();

// Listen to progress messages
sensor.errorStream.listen((message) {
  print(message);
});

// Auto-connect
bool connected = await sensor.autoConnect();

if (connected) {
  print('Connected to K3ProSpy on: ${sensor.connectedDevice?.deviceName}');
  
  // Use the sensor
  final temp = await sensor.getValue();
  print('Temperature: ${temp?.mVal}°C');
  
  await sensor.disconnect();
}
```

### Custom Baud Rate

```dart
bool connected = await sensor.autoConnect(baudRate: 9600);
```

## Progress Messages

The auto-connect process sends status messages to the `errorStream`:

```
Found 3 CP2104 device(s), scanning...
Trying device: /dev/bus/usb/001/002...
Device /dev/bus/usb/001/002 is not K3ProSpy (got: OtherDevice), disconnecting...
Trying device: /dev/bus/usb/001/003...
Found K3ProSpy sensor on /dev/bus/usb/001/003
```

## Error Handling

```dart
sensor.errorStream.listen((message) {
  if (message.contains('not found')) {
    print('K3ProSpy sensor not detected');
  } else if (message.contains('Found K3ProSpy')) {
    print('Success!');
  }
});

bool connected = await sensor.autoConnect();
```

## Multiple Devices Scenario

If you have multiple CP2104 devices connected:

### Scenario 1: Only One K3ProSpy
```dart
// Auto-connect will find it automatically
await sensor.autoConnect();
```

### Scenario 2: Multiple K3ProSpy Sensors
```dart
// Auto-connect will connect to the FIRST one found
// To connect to a specific sensor, use manual connection:

final cp2104Devices = await sensor.getCP2104Devices();
for (var device in cp2104Devices) {
  await sensor.connect(device);
  final id = await sensor.getID();
  
  if (id?.mID == 'desired_sensor_id') {
    print('Found the right sensor!');
    break;
  }
  
  await sensor.disconnect();
}
```

## Advantages

✅ **Simple**: One function call to connect  
✅ **Reliable**: Verifies device identity before connecting  
✅ **Safe**: Won't connect to wrong device type  
✅ **Informative**: Provides progress updates via errorStream  
✅ **Automatic**: No need to manually select device  

## When to Use Manual Connection

Use manual `connect()` instead of `autoConnect()` when:

- You have multiple K3ProSpy sensors and need to select a specific one
- You want to show device selection UI to the user
- You need to connect to a device that's not K3ProSpy
- You want full control over the connection process

## API Reference

### `autoConnect({int baudRate = 115200})`

**Returns**: `Future<bool>`
- `true` if K3ProSpy sensor found and connected
- `false` if no K3ProSpy sensor found

**Parameters**:
- `baudRate` (optional): Serial baud rate, default 115200

**Side Effects**:
- Sets `_connectedDevice` to the connected device
- Sets `_isConnected` to true if successful
- Sends progress messages to `errorStream`

### `getCP2104Devices()`

**Returns**: `Future<List<UsbDevice>>`
- List of all USB devices with VID=0x10C4 and PID=0xEA60

**Usage**:
```dart
final cp2104Devices = await sensor.getCP2104Devices();
print('Found ${cp2104Devices.length} CP2104 device(s)');
```

### `connectedDevice`

**Type**: `UsbDevice?`  
**Description**: The currently connected USB device, or null if not connected

**Usage**:
```dart
if (sensor.isConnected) {
  print('Connected to: ${sensor.connectedDevice?.deviceName}');
  print('Device ID: ${sensor.connectedDevice?.deviceId}');
}
```

## Constants

```dart
K3ProSpySensor.CP2104_VID  // 0x10C4
K3ProSpySensor.CP2104_PID  // 0xEA60
K3ProSpySensor.TARGET_SENSOR_NAME  // "K3ProSpy"
```

## Example: Auto-Connect with Timeout

```dart
Future<bool> connectWithTimeout(Duration timeout) async {
  final sensor = K3ProSpySensor();
  
  try {
    return await sensor.autoConnect().timeout(
      timeout,
      onTimeout: () {
        print('Auto-connect timed out');
        return false;
      },
    );
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

// Usage
bool connected = await connectWithTimeout(Duration(seconds: 10));
```

## Troubleshooting

### No devices found
```
No CP2104 devices found (VID:0x10C4, PID:0xEA60)
```
**Solution**: Check USB connection, ensure device is plugged in

### Device found but not K3ProSpy
```
Device /dev/bus/usb/001/002 is not K3ProSpy (got: no response)
```
**Solution**: 
- Check if Arduino code is uploaded to ESP32
- Verify baud rate matches (default 115200)
- Ensure `mType` in Arduino is set to "K3ProSpy"

### Multiple devices, none are K3ProSpy
```
K3ProSpy sensor not found on any CP2104 device
```
**Solution**: Check Arduino code, verify `GetName` returns "K3ProSpy"
