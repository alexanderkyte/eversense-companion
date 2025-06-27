# Eversense Companion Garmin Watchface

A Garmin Connect IQ watchface that displays blood glucose monitoring data from the Eversense CGM system.

## Features

- **24-hour time display** - Shows current time in 24-hour format
- **Blood glucose monitoring** - Displays current glucose value in mg/dL
- **Glucose trend indicators** - Shows arrows indicating if glucose is rising (↗), falling (↘), or stable (→)
- **Heart rate monitoring** - Displays current heart rate from watch sensors
- **Battery level** - Shows current battery percentage
- **Connection status** - Indicates if connected to Eversense data
- **Automatic updates** - Fetches new glucose data every 90 seconds

## Display Layout

```
     12:34
     
   120 mg/dL
       ↗
       
♥ 72 BPM    🔋 85%

   Connected
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

## Installation

1. Install Garmin Connect IQ SDK
2. Open this project in Connect IQ IDE or use command line tools
3. Configure credentials in the API client (see Security section)
4. Build and deploy to your Garmin device

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

### Using Connect IQ IDE

1. Import project into Connect IQ IDE
2. Select target device
3. Build and run simulator or deploy to device

### Using Command Line

```bash
# Compile the project
monkeyc -m manifest.xml -z resources/ -o EversenseWatchface.prg

# Or using jungle file
monkeyc -f monkey.jungle -o EversenseWatchface.prg
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