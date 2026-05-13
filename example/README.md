# SMT Sensor Example

Example Flutter application demonstrating USB serial communication with K3_Pro_Spy sensor.

## Features

- 🔍 **Auto-connect**: Automatically finds K3ProSpy sensor among CP2104 devices
- 📡 Send commands (GetID, GetName, GetVal)
- 📈 Display sensor data in real-time
- 🚀 Simple one-tap connection
- 🎯 Clean, minimal interface

## Running the Example

1. Install dependencies:
```bash
cd example
flutter pub get
```

2. Connect your K3_Pro_Spy device via USB

3. Run the app:
```bash
flutter run
```

## Android Setup

The example includes necessary permissions in `AndroidManifest.xml`:
- USB host support
- USB permission
- Device filter for common USB-Serial chips

## Usage

1. **Launch the app**
2. **Tap "Connect"** (green button)
   - The app automatically scans all CP2104 devices (VID: 0x10C4, PID: 0xEA60)
   - Connects to each device and queries its name
   - Keeps connection when it finds "K3ProSpy"
   - Status updates shown at the top
3. **View real-time data** in the Sensor Data card
4. **Use command buttons** to query the sensor:
   - **Get ID** - Retrieve sensor ID (mID)
   - **Get Name** - Retrieve sensor type (mType)
   - **Get Value** - Retrieve current temperature value (mVal)
5. **Tap "Disconnect"** when done

## How Auto-Connect Works

The auto-connect feature:

1. **Scans** for all USB devices with VID: 0x10C4 and PID: 0xEA60 (CP2104 chips)
2. **Connects** to each device one by one
3. **Queries** the device name using the `GetName` command
4. **Verifies** if the response is "K3ProSpy"
5. **Keeps** the connection if match found, otherwise disconnects and tries next device

**Progress messages** are shown as snackbar notifications at the bottom of the screen during the connection process.
