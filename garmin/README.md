# Eversense Companion Garmin Apps

Garmin Connect IQ applications that display blood glucose monitoring data from the Eversense CGM system.

## Applications

This project includes two Garmin Connect IQ applications:

### 1. Eversense Companion Watchface
A complete watchface that displays:
- **24-hour time display** - Shows current time in 24-hour format
- **Blood glucose monitoring** - Displays current glucose value in mg/dL
- **Glucose trend indicators** - Shows arrows indicating if glucose is rising (↗), falling (↘), or stable (→)
- **Heart rate monitoring** - Displays current heart rate from watch sensors
- **Battery level** - Shows current battery percentage
- **Connection status** - Indicates if connected to Eversense data
- **Automatic updates** - Fetches new glucose data every 90 seconds

### 2. Eversense Glucose Data Field
A data field for activity screens that shows:
- **Blood glucose value** in mg/dL with color coding
- **Glucose trend indicators** (↗ ↘ →)
- **Data age** indicator when space allows
- **Configurable display format** (value only, value + trend, or value + trend + age)
- **Adaptive sizing** based on available screen space

## Display Examples

### Watchface Layout
```
     12:34
     
   120 mg/dL
       ↗
       
♥ 72 BPM    🔋 85%

   Connected
```

### Data Field Examples
```
Small:    120
Medium:   120 ↗
Large:    120 ↗ 2m
```

## Color Coding

- **Green** (Good): Glucose 80-130 mg/dL
- **Red** (High): Glucose > 130 mg/dL  
- **Orange** (Low): Glucose < 80 mg/dL

## Technical Implementation

### REST API Integration

The watchface connects to the Eversense API using the same endpoints as the main application:

- **Authentication**: `https://usiamapi.eversensedms.com/connect/token`
- **User Data**: `https://usapialpha.eversensedms.com/api/care/GetFollowingPatientList`

### Data Updates

- Initial authentication on app start
- Glucose data fetched every 90 seconds
- Automatic token refresh when expired
- Data cached locally for offline display

### Libraries Used

- **Toybox.Communications** - For HTTP requests
- **Toybox.Application.Storage** - For credential and token storage
- **Toybox.Timer** - For periodic updates
- **Toybox.ActivityMonitor** - For heart rate data
- **Toybox.System** - For battery information

## Installation & Usage

### Watchface Installation
1. Install Garmin Connect IQ SDK
2. Build the watchface: `make build-watchface`
3. Install on your device or test in simulator
4. Configure Eversense credentials in watchface settings
5. Select as your active watchface

### Data Field Installation
1. Build the data field: `make build-datafield`
2. Install on your device
3. Configure Eversense credentials in data field settings
4. Add to any activity screen:
   - Start an activity (run, bike, etc.)
   - Go to data screens settings
   - Add "Eversense Glucose" data field
   - Position it where you want glucose data displayed

### Settings Configuration

Both apps have separate settings panels accessible through Garmin Connect:

**Watchface Settings:**
- Eversense account credentials
- Update interval (60-300 seconds)
- Glucose thresholds for color coding
- Display options (show seconds)

**Data Field Settings:**
- Eversense account credentials  
- Update interval (60-300 seconds)
- Glucose thresholds for color coding
- Display format (value only, value + trend, value + trend + age)

## Configuration

### Credentials Setup

⚠️ **Important**: Update the API credentials in `EversenseAPIClient.mc`:

```monkey-c
// Replace these with actual credentials
username = "your-email@example.com";
password = "your-password";
```

### Supported Devices

- Vivoactive 4/4S
- Venu/Venu 2/Venu 2S  
- Fenix 6/6S/6X
- Forerunner 245
- Other Connect IQ 3.2+ compatible devices

## Build Instructions

### Using Docker (Recommended)

The easiest way to build for all supported devices:

```bash
# Build using Docker (no SDK installation required)
make docker-build

# Clean build for distribution
make docker-package
```

This will create `dist/` folder with .prg files for all supported devices.

### Using Connect IQ IDE

1. Import project into Connect IQ IDE
2. Select target device
3. Build and run simulator or deploy to device

### Using Command Line

```bash
# Build both apps for default device (vivoactive4)
make build

# Build specific app only
make build-watchface
make build-datafield

# Build for specific device
make build DEVICE=fenix6

# Build for all supported devices
make build-all

# Test in simulator
make sim-watchface
make sim-datafield
```

### Using Connect IQ SDK directly

```bash
# Build watchface
monkeyc -m manifest.xml -z resources/ -o EversenseWatchface.prg -d vivoactive4 --package-app eversense-watchface

# Build datafield  
monkeyc -m manifest.xml -z resources/ -o EversenseDataField.prg -d vivoactive4 --package-app eversense-datafield
```

## Security Considerations

- Credentials are stored in device secure storage
- HTTPS used for all API communications
- Tokens automatically refreshed to minimize exposure
- No sensitive data logged or transmitted unnecessarily

## Troubleshooting

### Common Issues

1. **"No Data" showing**: Check internet connection and credentials
2. **Authentication failed**: Verify username/password are correct
3. **Old glucose data**: Check if 90-second updates are working
4. **Heart rate not showing**: Ensure watch has HR sensor and permission

### Docker Build Issues

1. **Docker not available**: Install Docker Desktop or Docker Engine
2. **Permission denied**: Ensure user is in docker group or use sudo
3. **Build failures**: Check Docker daemon is running and internet connection
4. **Large image size**: This is normal due to Java SDK and Garmin SDK requirements

### Debug Information

Enable debug output in Connect IQ simulator to see:
- API request/response details
- Authentication status
- Data parsing results

## Development Notes

### API Response Format

The watchface expects glucose data in this format:
```json
{
  "CurrentGlucose": 120,
  "GlucoseTrend": 3,
  "IsTransmitterConnected": true,
  "UserID": "user-id-string"
}
```

### Trend Mapping

| API Value | Meaning | Display |
|-----------|---------|---------|
| 0 | STALE | → |
| 1 | FALLING_FAST | ↘ |
| 2 | FALLING | ↘ |
| 3 | FLAT | → |
| 4 | RISING | ↗ |
| 5 | RISING_FAST | ↗ |
| 6 | FALLING_RAPID | ↘ |
| 7 | RAISING_RAPID | ↗ |

## License

MIT License - same as parent project

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on Garmin simulator and device
5. Submit a pull request

## Support

For issues and questions:
- Check the troubleshooting section above
- Review Connect IQ documentation
- File issues in the main repository