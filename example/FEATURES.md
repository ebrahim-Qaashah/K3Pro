# Example App Features

## Device Information Display

The example app now includes comprehensive device information features to help identify and manage multiple USB sensors.

### 1. Enhanced Dropdown Selection
The device dropdown now shows:
- **Product Name** (bold)
- **Device Port** and **Device ID** (in smaller gray text)

This makes it easy to distinguish between multiple connected devices at a glance.

### 2. Device Info Button (ℹ️)
When a device is selected, tap the info icon to see:
- Product Name
- Manufacturer Name
- Device Path (e.g., `/dev/bus/usb/001/002`)
- Device ID (system-assigned unique ID)
- Vendor ID (VID) - shown in both hex and decimal
- Product ID (PID) - shown in both hex and decimal
- Serial Number (if available)
- Helpful note about serial number limitations

### 3. All Devices View
Tap the **"All Devices"** button to see:
- Complete list of all connected USB devices
- Expandable cards for each device
- Full device details in each card
- Refresh button to rescan devices
- Device count in dialog title

## Use Cases

### Scenario 1: Single Device
1. Connect ESP32 sensor
2. Select from dropdown
3. View info if needed
4. Connect and use

### Scenario 2: Multiple Identical Devices
When you have 2+ ESP32 sensors with CP2104:

1. **Scan Devices**: Tap refresh to find all devices
2. **View All Devices**: Tap "All Devices" button to see complete list
3. **Check Identifiers**:
   - Look at Device Path (ttyUSB0, ttyUSB1, etc.)
   - Check Serial Number (may be same for cheap modules)
   - Note Device ID (unique per session)
4. **Connect Each Device**: 
   - Select device from dropdown
   - Connect
   - Query sensor ID with "Get ID" button
   - Note the mID value (e.g., "01A0661000")
5. **Label Devices**: Use the mID to identify which physical sensor is which

### Scenario 3: Troubleshooting Connection
1. Tap "All Devices" to verify device is detected
2. Check VID:PID matches CP2104 (0x10C4:0xEA60)
3. Verify Device Path is accessible
4. Check logs for connection errors

## Technical Details

### Device Properties Displayed

| Property | Type | Uniqueness | Persistence |
|----------|------|------------|-------------|
| Device ID | Integer | Unique per session | Changes on reconnect |
| Device Path | String | Unique while connected | May change |
| Serial Number | String | Depends on hardware | Permanent (if programmed) |
| VID:PID | Integer pair | Same for all CP2104 | Fixed |
| Product Name | String | Same for same chip type | Fixed |

### CP2104 Typical Values
- **VID**: 0x10C4 (4292 decimal)
- **PID**: 0xEA60 (60000 decimal)
- **Product Name**: "CP2104 USB to UART Bridge Controller"
- **Manufacturer**: "Silicon Labs"

## Screenshots Guide

### Main Screen
- Dropdown shows device name and port/ID
- Info icon (ℹ️) appears when device selected
- Refresh icon to rescan devices

### Device Info Dialog
- Clean table layout with labels and values
- Hex and decimal values for VID/PID
- Helpful note at bottom

### All Devices Dialog
- Expandable cards for each device
- Tap to expand and see full details
- Refresh and Close buttons at bottom
- Device count in title

## Tips

✅ **Do**:
- Use "All Devices" to compare multiple sensors
- Query mID after connection for persistent identification
- Note the Device Path for quick reconnection
- Check Serial Number first (if available)

❌ **Don't**:
- Rely solely on Device ID (changes on reconnect)
- Assume Serial Numbers are unique (many cheap modules don't have them)
- Expect VID:PID to distinguish between same chip types
