using Toybox.Application.Properties as Properties;
using Toybox.System as Sys;
using Toybox.Test as Test;

// Test utilities for Eversense Companion apps
// This provides test data injection and validation for frontend behavior
class EversenseTestUtils {
    
    // Test glucose values for different scenarios
    static const TEST_GLUCOSE_NORMAL = 110;
    static const TEST_GLUCOSE_HIGH = 180;
    static const TEST_GLUCOSE_LOW = 65;
    static const TEST_GLUCOSE_CRITICAL_HIGH = 250;
    static const TEST_GLUCOSE_CRITICAL_LOW = 40;
    
    // Test trend values
    static const TEST_TREND_RISING = "rising";
    static const TEST_TREND_FALLING = "falling";
    static const TEST_TREND_STABLE = "stable";
    
    // Test scenarios
    static function setupNormalGlucoseScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_NORMAL);
        Properties.setValue("testGlucoseTrend", TEST_TREND_STABLE);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 85);
        Properties.setValue("testHeartRate", 72);
    }
    
    static function setupHighGlucoseScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_HIGH);
        Properties.setValue("testGlucoseTrend", TEST_TREND_RISING);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 65);
        Properties.setValue("testHeartRate", 88);
    }
    
    static function setupLowGlucoseScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_LOW);
        Properties.setValue("testGlucoseTrend", TEST_TREND_FALLING);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 45);
        Properties.setValue("testHeartRate", 95);
    }
    
    static function setupCriticalHighScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_CRITICAL_HIGH);
        Properties.setValue("testGlucoseTrend", TEST_TREND_RISING);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 25);
        Properties.setValue("testHeartRate", 105);
    }
    
    static function setupCriticalLowScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_CRITICAL_LOW);
        Properties.setValue("testGlucoseTrend", TEST_TREND_FALLING);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 15);
        Properties.setValue("testHeartRate", 110);
    }
    
    static function setupDisconnectedScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", null);
        Properties.setValue("testGlucoseTrend", null);
        Properties.setValue("testIsConnected", false);
        Properties.setValue("testBatteryLevel", 75);
        Properties.setValue("testHeartRate", 68);
    }
    
    static function setupLowBatteryScenario() {
        Properties.setValue("testMode", true);
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_NORMAL);
        Properties.setValue("testGlucoseTrend", TEST_TREND_STABLE);
        Properties.setValue("testIsConnected", true);
        Properties.setValue("testBatteryLevel", 8);
        Properties.setValue("testHeartRate", 72);
    }
    
    // Test layout scenarios for different screen types
    static function setupRoundScreenTest() {
        Properties.setValue("testMode", true);
        Properties.setValue("testScreenType", "round");
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_NORMAL);
        Properties.setValue("testGlucoseTrend", TEST_TREND_STABLE);
        Properties.setValue("testIsConnected", true);
    }
    
    static function setupRectangularScreenTest() {
        Properties.setValue("testMode", true);
        Properties.setValue("testScreenType", "rectangular");
        Properties.setValue("testGlucoseValue", TEST_GLUCOSE_NORMAL);
        Properties.setValue("testGlucoseTrend", TEST_TREND_STABLE);
        Properties.setValue("testIsConnected", true);
    }
    
    // Validation methods for frontend behavior
    static function validateGlucoseColorCoding(glucoseValue, color) {
        if (glucoseValue == null) {
            return color == 0x888888; // Gray for no data
        } else if (glucoseValue < 80) {
            return color == 0xFFAA00; // Orange for low
        } else if (glucoseValue > 130) {
            return color == 0xFF0000; // Red for high
        } else {
            return color == 0x00AA00; // Green for normal
        }
    }
    
    static function validateTrendSymbol(trend, symbol) {
        if (trend == null || trend.equals("stable")) {
            return symbol.equals("→");
        } else if (trend.equals("rising")) {
            return symbol.equals("↗");
        } else if (trend.equals("falling")) {
            return symbol.equals("↘");
        }
        return false;
    }
    
    static function validateBatteryWarning(batteryLevel, isWarning) {
        if (batteryLevel <= 20) {
            return isWarning == true;
        } else {
            return isWarning == false;
        }
    }
    
    // Test runner for automated validation
    static function runFrontendTests() {
        var testResults = [];
        
        // Test glucose color coding
        testResults.add(validateGlucoseColorCoding(110, 0x00AA00)); // Normal
        testResults.add(validateGlucoseColorCoding(180, 0xFF0000)); // High
        testResults.add(validateGlucoseColorCoding(65, 0xFFAA00));  // Low
        testResults.add(validateGlucoseColorCoding(null, 0x888888)); // No data
        
        // Test trend symbols
        testResults.add(validateTrendSymbol("stable", "→"));
        testResults.add(validateTrendSymbol("rising", "↗"));
        testResults.add(validateTrendSymbol("falling", "↘"));
        testResults.add(validateTrendSymbol(null, "→"));
        
        // Test battery warning
        testResults.add(validateBatteryWarning(15, true));   // Low battery
        testResults.add(validateBatteryWarning(50, false));  // Normal battery
        
        // Count passed tests
        var passedTests = 0;
        for (var i = 0; i < testResults.size(); i++) {
            if (testResults[i]) {
                passedTests++;
            }
        }
        
        Sys.println("Frontend tests completed: " + passedTests + "/" + testResults.size() + " passed");
        return passedTests == testResults.size();
    }
    
    // Clear test mode
    static function clearTestMode() {
        Properties.setValue("testMode", false);
        Properties.setValue("testGlucoseValue", null);
        Properties.setValue("testGlucoseTrend", null);
        Properties.setValue("testIsConnected", null);
        Properties.setValue("testBatteryLevel", null);
        Properties.setValue("testHeartRate", null);
        Properties.setValue("testScreenType", null);
    }
    
    // Get test mode status
    static function isTestMode() {
        var testMode = Properties.getValue("testMode");
        return testMode != null && testMode == true;
    }
    
    // Cycle through test scenarios (useful for simulator testing)
    static function cycleTestScenarios() {
        var scenarios = [
            "normal",
            "high", 
            "low",
            "critical_high",
            "critical_low",
            "disconnected",
            "low_battery"
        ];
        
        var currentScenario = Properties.getValue("currentTestScenario");
        if (currentScenario == null) {
            currentScenario = 0;
        }
        
        currentScenario = (currentScenario + 1) % scenarios.size();
        Properties.setValue("currentTestScenario", currentScenario);
        
        switch (scenarios[currentScenario]) {
            case "normal":
                setupNormalGlucoseScenario();
                break;
            case "high":
                setupHighGlucoseScenario();
                break;
            case "low":
                setupLowGlucoseScenario();
                break;
            case "critical_high":
                setupCriticalHighScenario();
                break;
            case "critical_low":
                setupCriticalLowScenario();
                break;
            case "disconnected":
                setupDisconnectedScenario();
                break;
            case "low_battery":
                setupLowBatteryScenario();
                break;
        }
        
        Sys.println("Switched to test scenario: " + scenarios[currentScenario]);
        return scenarios[currentScenario];
    }
}