# Development Guide - Eversense Companion Garmin Watchface

This guide provides detailed information for developers working on the Eversense Companion Garmin watchface.

## Project Structure

```
garmin/
├── source/                          # Monkey C source files
│   ├── EversenseWatchFaceApp.mc     # Main application entry point
│   ├── EversenseWatchFaceView.mc    # Watchface view and display logic
│   ├── EversenseWatchFaceDelegate.mc # Event handling delegate
│   └── EversenseAPIClient.mc        # REST API client for Eversense
├── resources/                       # Resource files
│   ├── drawables/
│   │   ├── drawables.xml           # Drawable resource definitions
│   │   └── launcher_icon.png       # App icon (placeholder)
│   └── strings/
│       └── strings.xml             # String resources
├── manifest.xml                     # App manifest and configuration
├── settings.json                    # User settings definition
├── monkey.jungle                    # Build configuration
├── Makefile                        # Build automation
├── build.sh                        # Build script
├── validate.sh                     # Validation script
├── .gitignore                      # Git ignore rules
├── README.md                       # User documentation
└── DEVELOPMENT.md                  # This file
```

## Key Components

### 1. EversenseWatchFaceApp.mc
- Main application class extending `App.AppBase`
- Handles app lifecycle (start, stop)
- Returns initial view and delegate

### 2. EversenseWatchFaceView.mc
- Main watchface view extending `Ui.WatchFace`
- Handles display rendering and updates
- Manages glucose data display and trends
- Integrates heart rate and battery info
- Manages periodic updates

### 3. EversenseAPIClient.mc
- REST API client for Eversense services
- Handles authentication and token management
- Fetches glucose data from API
- Manages data parsing and error handling

### 4. EversenseWatchFaceDelegate.mc
- Event handling delegate
- Manages power budget and performance

## API Integration

### Authentication Flow

1. Load credentials from settings or storage
2. Make POST request to login endpoint
3. Parse and store access token
4. Use token for subsequent API calls
5. Refresh token when expired

### Data Flow

1. Timer triggers glucose data fetch every 90 seconds
2. API client makes authenticated request
3. Response parsed for glucose value and trend
4. UI updated with new data
5. Display refreshed

### Endpoints Used

- **Login**: `https://usiamapi.eversensedms.com/connect/token`
- **User Data**: `https://usapialpha.eversensedms.com/api/care/GetFollowingPatientList`

## Display Layout

The watchface uses a simple centered layout:

```
┌─────────────────┐
│      12:34      │ ← Time (24-hour format)
│                 │
│   120 mg/dL     │ ← Glucose value (color-coded)
│       ↗         │ ← Trend indicator
│                 │
│ ♥ 72    🔋 85%  │ ← Heart rate & battery
│                 │
│   Connected     │ ← Connection status
└─────────────────┘
```

## Color Coding

- **Green (0x00AA00)**: Normal glucose (80-130 mg/dL)
- **Red (0xFF0000)**: High glucose (>130 mg/dL)
- **Orange (0xFFAA00)**: Low glucose (<80 mg/dL)
- **White (0xFFFFFF)**: Text and other elements

## Settings Configuration

The watchface supports user-configurable settings:

- **Username/Password**: Eversense account credentials
- **Update Interval**: How often to fetch data (60-300 seconds)
- **Glucose Thresholds**: Low/high boundary values
- **Display Options**: Show seconds in time

## Development Setup

### Prerequisites

1. **Garmin Connect IQ SDK** - Download from Garmin Developer Portal
2. **Connect IQ IDE** or **Visual Studio Code** with Connect IQ extension
3. **Java 8+** - Required by SDK
4. **Garmin device or simulator** - For testing

### Installation

```bash
# 1. Download and install Connect IQ SDK
# 2. Set environment variables
export CIQ_SDK_PATH=/path/to/connectiq-sdk
export PATH=$PATH:$CIQ_SDK_PATH/bin

# 3. Clone and navigate to project
cd garmin/

# 4. Validate project structure
./validate.sh

# 5. Build for specific device
make build DEVICE=vivoactive4

# 6. Or build for all devices
make build-all
```

### Testing

```bash
# Run in simulator
make sim DEVICE=vivoactive4

# Or use Connect IQ IDE
# 1. Import project
# 2. Select device
# 3. Build and run
```

## Code Style Guidelines

### Naming Conventions
- Classes: `PascalCase` (e.g., `EversenseAPIClient`)
- Methods: `camelCase` (e.g., `fetchGlucoseData`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `LOGIN_URL`)
- Variables: `camelCase` (e.g., `glucoseValue`)

### Comments
- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Document public methods and complex logic

### Error Handling
- Always check for null responses
- Log errors with `Sys.println()`
- Provide fallback displays for missing data

## Performance Considerations

### Memory Management
- Minimize object creation in `onUpdate()`
- Reuse variables where possible
- Clean up timers in `onHide()`

### Battery Optimization
- Limit API calls frequency
- Use efficient drawing operations
- Avoid unnecessary calculations

### Network Usage
- Cache API responses when possible
- Implement retry logic with backoff
- Handle offline scenarios gracefully

## Debugging

### Common Issues

1. **Authentication Failures**
   - Check credentials in settings
   - Verify API endpoints are accessible
   - Check token expiry handling

2. **Display Problems**
   - Verify drawing coordinates
   - Check color values and fonts
   - Test on different screen sizes

3. **Network Issues**
   - Check internet connectivity
   - Verify HTTPS certificate handling
   - Test with different data responses

### Debug Output

Enable debug logging in Connect IQ simulator:
```monkey-c
Sys.println("Debug: " + data);
```

## Testing Strategy

### Unit Testing
- Test API response parsing
- Verify color coding logic
- Test settings loading

### Integration Testing
- Test full authentication flow
- Verify periodic updates
- Test error scenarios

### Device Testing
- Test on multiple device types
- Verify battery performance
- Test in different network conditions

## Contributing

### Pull Request Guidelines
1. Follow existing code style
2. Add tests for new functionality
3. Update documentation
4. Test on multiple devices

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] Error handling is comprehensive
- [ ] Performance impact is minimal
- [ ] Documentation is updated
- [ ] Testing is adequate

## Deployment

### Building for Release
```bash
# Build optimized version
make build-all

# Package for distribution
make package
```

### Store Submission
1. Test on all supported devices
2. Verify all permissions are necessary
3. Complete store metadata
4. Submit through Connect IQ Store

## Troubleshooting

### Build Issues
- Ensure SDK path is correct
- Check manifest syntax
- Verify resource file formats

### Runtime Issues
- Check device compatibility
- Verify permissions are granted
- Test network connectivity

### Performance Issues
- Profile memory usage
- Optimize drawing operations
- Reduce API call frequency

## Future Enhancements

### Planned Features
- Offline data caching
- Historical glucose trends
- Customizable display themes
- Alert notifications

### API Improvements
- Implement retry mechanisms
- Add data validation
- Optimize request batching

### UI Enhancements
- Add more display layouts
- Implement touch interactions
- Support more screen sizes

## Resources

- [Garmin Connect IQ Developer Guide](https://developer.garmin.com/connect-iq/)
- [Monkey C API Documentation](https://developer.garmin.com/connect-iq/api-docs/)
- [Connect IQ Programming Guide](https://developer.garmin.com/connect-iq/programmers-guide/)
- [Eversense API Documentation](https://developer.eversensedms.com/) (if available)

## Support

For development questions:
1. Check this documentation first
2. Review Garmin developer forums
3. File issues in the main repository
4. Contact the development team