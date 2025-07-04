# Testing and Screenshot Generation Guide

This guide explains how to test the Eversense Companion Garmin apps safely without making any network calls, and generate screenshots for documentation and verification purposes.

## Overview

The testing framework provides:
- **Network-free testing** - All tests run without making external network calls
- **Frontend behavior validation** - Tests glucose display, color coding, trend indicators  
- **Mock data injection** - Realistic test scenarios using simulated glucose data
- **Automated screenshot generation** - Captures app appearance across different scenarios
- **Layout testing** - Validates adaptive layouts for round vs rectangular screens
- **CI/CD integration** - Automated testing and screenshot generation in GitHub Actions

## Network Safety

**🔒 No Network Traffic During Testing**

The testing framework implements multiple layers of protection to ensure no network calls are made during testing:

1. **Test Mode Detection** - API client automatically detects test mode and blocks network calls
2. **Mock Data Injection** - Test utilities provide realistic glucose data without network access
3. **Forced Test Mode** - Test scripts explicitly enable test mode at startup
4. **Network Disabled Flag** - Additional safety flag prevents accidental network access
5. **Verification Tools** - Scripts validate that no network calls are attempted

### Verify Network Safety
```bash
cd garmin
make verify-no-network  # Verifies all network calls are properly blocked
```

## Quick Start

### Run All Tests (Network-Free)
```bash
cd garmin
make test-all DEVICE=vivoactive4
```

### Verify No Network Access
```bash
cd garmin
make verify-no-network
```

### Generate Screenshots
```bash
cd garmin  
make screenshots DEVICE=vivoactive4
```

### Generate Screenshots for All Devices
```bash
cd garmin
make screenshots-all
```

## Test Scripts

### test.sh - Comprehensive Test Suite

The main test script validates app functionality without making network calls:

```bash
# Test with default device (vivoactive4)
./test.sh

# Test with specific device
./test.sh fenix6

# Test with custom SDK path
SDK_PATH=/opt/garmin ./test.sh vivoactive4
```

**Network Safety Features:**
- Automatically enables test mode at startup
- Validates no network access throughout testing
- Uses only mock data for all test scenarios
- Generates detailed reports confirming network-free operation

**What it tests:**
- App build validation
- Source file structure verification
- Simulator loading and functionality
- Adaptive layout for different screen types
- Test scenario cycling

**Output:**
- `test-output/` - Test reports and logs
- `test-screenshots/` - Screenshot captures
- Detailed test report in Markdown format

### screenshot.sh - Screenshot Generation

Dedicated script for capturing high-quality screenshots:

```bash
# Generate screenshots for default device
./screenshot.sh

# Generate for specific device
./screenshot.sh fenix6

# Help and device list
./screenshot.sh --help
```

**Screenshot scenarios:**
- Normal glucose display (110 mg/dL, green)
- High glucose alert (180 mg/dL, red)
- Low glucose warning (65 mg/dL, orange)
- Disconnected state (no data)
- Round vs rectangular layout comparison

**Output:**
- `screenshots/` - PNG images or documentation files
- `screenshots/gallery.md` - Screenshot gallery with descriptions

## Test Mode Integration

### EversenseTestUtils.mc

The test utilities class provides:
- Predefined test scenarios for different glucose conditions
- Frontend behavior validation methods
- Test data injection for simulator testing
- Interactive test scenario cycling

**Test scenarios available:**
```javascript
EversenseTestUtils.setupNormalGlucoseScenario();    // 110 mg/dL, stable
EversenseTestUtils.setupHighGlucoseScenario();      // 180 mg/dL, rising
EversenseTestUtils.setupLowGlucoseScenario();       // 65 mg/dL, falling
EversenseTestUtils.setupDisconnectedScenario();     // No connection
EversenseTestUtils.setupLowBatteryScenario();       // Low battery warning
```

### Interactive Testing

In test mode, the watchface responds to user interactions:
- **Screen tap** - Cycles through test scenarios
- **Menu button** - Cycles through test scenarios
- **Console output** - Shows current test scenario

To enable test mode:
1. Build the app: `make build-watchface DEVICE=vivoactive4`
2. Enable test mode in app properties: `testMode=true`
3. Run in simulator: `make sim-watchface DEVICE=vivoactive4`
4. Tap screen or press menu to cycle scenarios

## Makefile Targets

### Testing Targets
```bash
make test                 # Run tests for both apps
make test-all            # Run comprehensive test suite  
make test-watchface      # Test watchface only
make test-datafield      # Test datafield only
```

### Screenshot Targets
```bash
make screenshots         # Generate screenshots for current device
make screenshots-all     # Generate screenshots for all devices
```

### Legacy Simulator Targets
```bash
make sim-watchface       # Run watchface in simulator
make sim-datafield       # Run datafield in simulator
```

### Clean Up
```bash
make clean              # Remove all build and test artifacts
```

## CI/CD Integration

## Test Mode Implementation

### How Network Blocking Works

The apps implement comprehensive test mode detection to prevent any network traffic during testing:

#### 1. API Client Protection
```monkey-c
// EversenseAPIClient.mc
function authenticate(callback) {
    // Check if in test mode - never make network calls during testing
    if (isTestMode()) {
        Sys.println("Test mode: Skipping authentication network call");
        // Simulate successful authentication for testing
        accessToken = "test_access_token";
        tokenExpiry = Time.now().value() + 3600;
        return;
    }
    // Normal network call only in production...
}

function fetchLatestGlucose(callback) {
    if (isTestMode()) {
        Sys.println("Test mode: Returning mock glucose data instead of network call");
        // Return mock data based on test properties
        var mockResult = {
            "value" => testGlucose,
            "trend" => testTrend,
            "connected" => testConnected
        };
        callback.invoke(mockResult);
        return;
    }
    // Normal network call only in production...
}
```

#### 2. Base View Safety Checks
```monkey-c
// EversenseBaseView.mc
function updateGlucoseData() {
    // Multiple layers of protection
    if (EversenseTestUtils.isTestMode()) {
        loadTestData();
        return;
    }
    
    if (EversenseTestUtils.isNetworkDisabled()) {
        Sys.println("Network disabled: Using default test data");
        loadTestData();
        return;
    }
    
    // Only reach here in production mode
    if (apiClient != null) {
        apiClient.fetchLatestGlucose(method(:onGlucoseUpdate));
    }
}
```

#### 3. Test Utilities Control
```monkey-c
// EversenseTestUtils.mc
static function forceEnableTestMode() {
    Properties.setValue("testMode", true);
    Properties.setValue("networkDisabled", true);
    Sys.println("FORCE TEST MODE: All network access disabled");
}

static function isNetworkDisabled() {
    var testMode = Properties.getValue("testMode");
    var networkDisabled = Properties.getValue("networkDisabled");
    return (testMode == true) || (networkDisabled == true);
}
```

### Test Data Scenarios

All test scenarios use mock data without network calls:

- **Normal Glucose** (110 mg/dL, stable trend)
- **High Glucose** (180 mg/dL, rising trend)  
- **Low Glucose** (65 mg/dL, falling trend)
- **Critical High** (250 mg/dL, rising fast)
- **Critical Low** (40 mg/dL, falling fast)
- **Disconnected State** (no data, offline)
- **Low Battery** (normal glucose, 8% battery)

### Validation Tools

#### verify-no-network.sh
```bash
./verify-no-network.sh
```
Validates:
- ✓ Test mode implementation in source code
- ✓ Network call protection patterns  
- ✓ Test script safety measures
- ✓ All network calls properly blocked

## CI/CD Integration

### GitHub Actions

The release workflow automatically runs network-free tests:
1. Builds all Garmin apps using Docker
2. **Enables test mode and validates no network access**
3. Runs comprehensive test suite with mock data
4. Generates screenshots using test scenarios
5. Packages test reports confirming network-free operation
6. Includes artifacts in GitHub releases

**Release artifacts:**
- `eversense-garmin-apps.zip` - App binaries (.prg files)
- `eversense-garmin-screenshots.zip` - Screenshots and gallery
- `eversense-garmin-test-reports.zip` - Test reports and network validation

### Docker Testing

Docker environment includes network-free testing:
- Connect IQ SDK with simulator
- Test mode enforcement
- Mock data generation  
- Screenshot capture tools (xvfb, scrot, imagemagick)
- Network access validation
- Test documentation generation

```bash
# Build and test in Docker (network-free)
make docker-build

# The Docker process automatically:
# 1. Forces test mode to disable network access
# 2. Builds apps for all devices
# 3. Runs validation tests with mock data
# 4. Validates no network traffic occurred
# 5. Generates test documentation
# 6. Creates package with artifacts
```

## Screenshot Methods

The screenshot system uses multiple fallback methods:

### Method 1: Connect IQ Simulator API
- Uses `monkeydo --screenshot` if supported
- Direct integration with simulator

### Method 2: System Screenshot Tools
- Linux: scrot, imagemagick import
- macOS: screencapture
- Captures simulator window

### Method 3: Documentation Generation
- Creates detailed text descriptions
- Includes scenario information
- Fallback when visual capture fails

### Method 4: Gallery Generation
- Markdown gallery with descriptions
- Links to screenshot files
- Visual documentation for users

## Frontend Behavior Tests

### Color Coding Validation
```javascript
// Tests glucose color mapping
validateGlucoseColorCoding(110, GREEN);   // Normal
validateGlucoseColorCoding(180, RED);     // High  
validateGlucoseColorCoding(65, ORANGE);   // Low
validateGlucoseColorCoding(null, GRAY);   // No data
```

### Trend Symbol Validation
```javascript
// Tests trend indicator mapping
validateTrendSymbol("stable", "→");   
validateTrendSymbol("rising", "↗");   
validateTrendSymbol("falling", "↘");  
```

### Battery Warning Validation
```javascript
// Tests low battery warning
validateBatteryWarning(15, true);   // Low battery = warning
validateBatteryWarning(50, false);  // Normal battery = no warning
```

## Supported Devices

**Round screens:**
- fenix6, fenix6s, fenix6x
- venu, venu2, venu2s  
- forerunner245

**Rectangular screens:**
- vivoactive4, vivoactive4s

The test framework automatically detects screen type and validates appropriate layout adaptations.

## Troubleshooting

### Screenshot Capture Issues

**Problem:** Screenshots not captured in CI environment
**Solution:** Uses documentation generation as fallback

**Problem:** Simulator not starting
**Solution:** Check SDK_PATH environment variable, verify simulator permissions

**Problem:** Test mode not working
**Solution:** Verify testMode property is set, check console output for scenario changes

### Build Issues

**Problem:** monkeyc not found
**Solution:** Install Connect IQ SDK, add bin directory to PATH

**Problem:** Test scripts not executable
**Solution:** Run `chmod +x test.sh screenshot.sh`

### Layout Testing

**Problem:** Adaptive layout not working correctly
**Solution:** Test with both round (fenix6) and rectangular (vivoactive4) devices

## Development Workflow

1. **Make changes** to source code
2. **Run tests** to validate functionality: `make test-all`
3. **Generate screenshots** to verify visual appearance: `make screenshots`
4. **Review test reports** in `test-output/`
5. **Check screenshots** in `screenshots/`
6. **Commit changes** (test artifacts are gitignored)
7. **Push to GitHub** - CI runs full test suite

## Best Practices

- Run tests locally before pushing
- Generate screenshots for visual verification
- Test on both round and rectangular devices
- Use test mode for interactive scenario testing
- Review CI test results in release artifacts
- Include screenshot documentation in releases

This testing framework ensures the Eversense Companion apps work correctly across all supported Garmin devices and provides visual verification of the user interface.