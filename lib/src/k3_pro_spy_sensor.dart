import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'sensor_data.dart';
import 'sensor_command.dart';

class K3ProSpySensor {
  UsbPort? _port;
  UsbDevice? _connectedDevice;
  StreamSubscription? _subscription;
  final StreamController<SensorData> _dataController = StreamController<SensorData>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  
  bool _isConnected = false;
  String _buffer = '';
  
  static const int CP2104_VID = 0x10C4;
  static const int CP2104_PID = 0xEA60;
  static const String TARGET_SENSOR_NAME = 'K3ProSpy';

  Stream<SensorData> get dataStream => _dataController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;
  UsbDevice? get connectedDevice => _connectedDevice;

  Future<List<UsbDevice>> getAvailableDevices() async {
    return await UsbSerial.listDevices();
  }

  Future<List<UsbDevice>> getCP2104Devices() async {
    final allDevices = await UsbSerial.listDevices();
    return allDevices.where((device) {
      return device.vid == CP2104_VID && device.pid == CP2104_PID;
    }).toList();
  }

  Future<bool> autoConnect({int baudRate = 115200}) async {
    try {
      final devices = await getAvailableDevices();
      
      if (devices.isEmpty) {
        //_errorController.add('No USB devices found');
        return false;
      }

      //_errorController.add('Found ${devices.length} USB device(s), scanning...');

      for (var device in devices) {
        //_errorController.add('Trying device: ${device.deviceName}...');
        
        final connected = await connect(device, baudRate: baudRate);
        if (!connected) {
          continue;
        }

        await Future.delayed(const Duration(milliseconds: 500));
        
        final nameData = await getName();
        
        if (nameData?.mType == TARGET_SENSOR_NAME) {
          //_errorController.add('Found K3ProSpy sensor on ${device.deviceName}');
          return true;
        } else {
          //_errorController.add('Device ${device.deviceName} is not K3ProSpy (got: ${nameData?.mType ?? "no response"}), disconnecting...');
          await disconnect();
        }
      }

      //_errorController.add('K3ProSpy sensor not found on any USB device');
      return false;
    } catch (e) {
      //_errorController.add('Auto-connect error: $e');
      return false;
    }
  }

  Future<bool> connect(UsbDevice device, {int baudRate = 115200}) async {
    try {
      _port = await device.create();
      if (_port == null) {
        //_errorController.add('Failed to create USB port');
        return false;
      }

      bool openResult = await _port!.open();
      if (!openResult) {
       // _errorController.add('Failed to open USB port');
        return false;
      }

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        baudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      _subscription = _port!.inputStream?.listen(
        (Uint8List data) {
          _onDataReceived(utf8.decode(data));
        },
        onError: (error) {
         // _errorController.add('USB read error: $error');
        },
      );

      _isConnected = true;
      _connectedDevice = device;
      return true;
    } catch (e) {
      //_errorController.add('Connection error: $e');
      return false;
    }
  }

  void _onDataReceived(String data) {
    _buffer += data;
    
    int newlineIndex;
    while ((newlineIndex = _buffer.indexOf('\n')) != -1) {
      String line = _buffer.substring(0, newlineIndex).trim();
      _buffer = _buffer.substring(newlineIndex + 1);
      
      if (line.isNotEmpty && line.startsWith('{')) {
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final sensorData = SensorData.fromJson(json);
          _dataController.add(sensorData);
        } catch (e) {
          //_errorController.add('JSON parse error: $e');
        }
      }
    }
  }

  Future<void> sendCommand(SensorCommand command) async {
    if (_port == null || !_isConnected) {
      //_errorController.add('Not connected to device');
      return;
    }

    try {
      String commandStr = '${command.command}\n';
      await _port!.write(Uint8List.fromList(utf8.encode(commandStr)));
    } catch (e) {
      //_errorController.add('Send command error: $e');
    }
  }

  Future<SensorData?> getID() async {
    await sendCommand(SensorCommand.getID);
    return await _waitForResponse();
  }

  Future<SensorData?> getName() async {
    await sendCommand(SensorCommand.getName);
    return await _waitForResponse();
  }

  Future<SensorData?> getValue() async {
    await sendCommand(SensorCommand.getValue);
    return await _waitForResponse();
  }

  Future<SensorData?> _waitForResponse({Duration timeout = const Duration(seconds: 2)}) async {
    try {
      return await dataStream.first.timeout(timeout);
    } on TimeoutException {
      //_errorController.add('Response timeout');
      return null;
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _subscription?.cancel();
    _subscription = null;
    await _port?.close();
    _port = null;
    _connectedDevice = null;
    _buffer = '';
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _errorController.close();
  }
}
