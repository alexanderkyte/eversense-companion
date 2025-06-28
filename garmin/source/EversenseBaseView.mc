using Toybox.Application.Properties as Properties;
using Toybox.Communications as Communications;
using Toybox.Timer as Timer;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

// Shared base class for common functionality between WatchFace and DataField
class EversenseBaseView {
    
    // Colors
    var goodColor = 0x00AA00;
    var highColor = 0xFF0000;
    var lowColor = 0xFFAA00;
    var textColor = 0xFFFFFF;
    
    // Glucose data
    var glucoseValue = null;
    var glucoseTrend = "stable";
    var lastGlucoseUpdate = null;
    var isConnected = false;
    
    // Settings
    var lowThreshold = 80;
    var highThreshold = 130;
    var updateInterval = 90000; // 90 seconds in milliseconds
    
    // API client
    var apiClient;
    var updateTimer;
    
    function initialize() {
        loadSettings();
        apiClient = new EversenseAPIClient();
        startGlucoseUpdates();
    }
    
    function loadSettings() {
        lowThreshold = Properties.getValue("lowThreshold");
        if (lowThreshold == null) { lowThreshold = 80; }
        
        highThreshold = Properties.getValue("highThreshold");
        if (highThreshold == null) { highThreshold = 130; }
        
        updateInterval = Properties.getValue("updateInterval");
        if (updateInterval == null) { updateInterval = 90000; }
    }
    
    function startGlucoseUpdates() {
        // Check if in test mode
        if (EversenseTestUtils.isTestMode()) {
            loadTestData();
            return;
        }
        
        // Immediate update
        updateGlucoseData();
        
        // Schedule periodic updates
        updateTimer = new Timer.Timer();
        updateTimer.start(method(:updateGlucoseData), updateInterval, true);
    }
    
    function updateGlucoseData() {
        // Check if in test mode
        if (EversenseTestUtils.isTestMode()) {
            loadTestData();
            return;
        }
        
        // Double-check network safety
        if (EversenseTestUtils.isNetworkDisabled()) {
            Sys.println("Network disabled: Using default test data instead of API call");
            loadTestData();
            return;
        }
        
        if (apiClient != null) {
            apiClient.fetchLatestGlucose(method(:onGlucoseUpdate));
        }
    }
    
    function loadTestData() {
        // Load test data from properties
        glucoseValue = Properties.getValue("testGlucoseValue");
        glucoseTrend = Properties.getValue("testGlucoseTrend");
        isConnected = Properties.getValue("testIsConnected");
        if (isConnected == null) { isConnected = false; }
        
        lastGlucoseUpdate = Sys.getTimer();
        Ui.requestUpdate();
    }
    
    function onGlucoseUpdate(data) {
        if (data != null) {
            glucoseValue = data["value"];
            glucoseTrend = data["trend"];
            isConnected = data["connected"];
            lastGlucoseUpdate = Sys.getTimer();
            Ui.requestUpdate();
        }
    }
    
    function getGlucoseColor() {
        if (glucoseValue == null) {
            return textColor;
        }
        
        if (glucoseValue < lowThreshold) {
            return lowColor;
        } else if (glucoseValue > highThreshold) {
            return highColor;
        } else {
            return goodColor;
        }
    }
    
    function getTrendSymbol() {
        var trendSymbols = {
            "rising" => "↗",
            "falling" => "↘",
            "stable" => "→"
        };
        
        var symbol = trendSymbols[glucoseTrend];
        return (symbol != null) ? symbol : "→";
    }
    
    function onStop() {
        if (updateTimer != null) {
            updateTimer.stop();
        }
    }
    
    function onHide() {
        onStop();
    }
}