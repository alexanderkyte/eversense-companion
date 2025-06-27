using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Communications as Communications;
using Toybox.Timer as Timer;
using Toybox.Application.Properties as Properties;
using Toybox.Activity as Activity;

class EversenseDataFieldView extends Ui.DataField {

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
    
    // Display format
    var displayFormat = 0; // 0 = value only, 1 = value + trend, 2 = value + trend + time

    function initialize() {
        DataField.initialize();
        loadSettings();
        apiClient = new EversenseAPIClient();
        
        // Start glucose data updates
        startGlucoseUpdates();
    }
    
    function loadSettings() {
        // Load user settings
        lowThreshold = Properties.getValue("lowThreshold");
        if (lowThreshold == null) { lowThreshold = 80; }
        
        highThreshold = Properties.getValue("highThreshold");
        if (highThreshold == null) { highThreshold = 130; }
        
        updateInterval = Properties.getValue("updateInterval");
        if (updateInterval == null) { updateInterval = 90; }
        updateInterval = updateInterval * 1000; // Convert to milliseconds
        
        displayFormat = Properties.getValue("dataFieldFormat");
        if (displayFormat == null) { displayFormat = 1; }
    }
    
    function startGlucoseUpdates() {
        // Initial glucose fetch
        fetchGlucoseData();
        
        // Set up periodic updates
        updateTimer = new Timer.Timer();
        updateTimer.start(method(:fetchGlucoseData), updateInterval, true);
    }
    
    function fetchGlucoseData() {
        if (apiClient != null) {
            apiClient.getGlucoseData(method(:onGlucoseDataReceived));
        }
    }
    
    function onGlucoseDataReceived(glucoseData) {
        if (glucoseData != null) {
            glucoseValue = glucoseData.get("value");
            var trendValue = glucoseData.get("trend");
            glucoseTrend = mapTrendToSymbol(trendValue);
            lastGlucoseUpdate = Sys.getTimer();
            isConnected = true;
        } else {
            isConnected = false;
        }
    }
    
    function mapTrendToSymbol(trend) {
        if (trend == null) {
            return "→";
        }
        
        if (trend > 1.5) {
            return "↗";
        } else if (trend < -1.5) {
            return "↘";
        } else {
            return "→";
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
    
    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // This method is called each time new Activity data is available.
        // We don't need to compute anything from activity data for glucose readings
        // The glucose data is fetched independently via the API
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        var bgColor = getBackgroundColor();
        var fgColor = getGlucoseColor();
        
        // Clear the field
        dc.setColor(bgColor, bgColor);
        dc.clear();
        
        // Set text color
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Determine what to display based on format setting and available space
        var displayText = getDisplayText(width, height);
        
        // Choose font size based on available space
        var font = chooseFontSize(width, height, displayText);
        
        // Calculate text position (center)
        var textDimensions = dc.getTextDimensions(displayText, font);
        var textX = width / 2;
        var textY = (height - textDimensions[1]) / 2;
        
        // Draw the text
        dc.drawText(textX, textY, font, displayText, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw connection indicator if disconnected (small dot)
        if (!isConnected) {
            dc.setColor(highColor, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(width - 5, 5, 2);
        }
    }
    
    function getDisplayText(width, height) {
        if (glucoseValue == null) {
            return "--";
        }
        
        var glucoseText = glucoseValue.toString();
        
        // Format based on display setting and available space
        if (displayFormat == 0 || width < 60) {
            // Value only
            return glucoseText;
        } else if (displayFormat == 1 || width < 100) {
            // Value + trend
            return glucoseText + " " + glucoseTrend;
        } else {
            // Value + trend + age indicator
            var ageText = getDataAge();
            return glucoseText + " " + glucoseTrend + " " + ageText;
        }
    }
    
    function getDataAge() {
        if (lastGlucoseUpdate == null) {
            return "";
        }
        
        var currentTime = Sys.getTimer();
        var ageMs = currentTime - lastGlucoseUpdate;
        var ageMinutes = ageMs / 60000;
        
        if (ageMinutes < 1) {
            return "now";
        } else if (ageMinutes < 10) {
            return ageMinutes.toNumber().toString() + "m";
        } else {
            return "old";
        }
    }
    
    function chooseFontSize(width, height, text) {
        // Choose font based on available space and text length
        if (width < 50 || height < 30) {
            return Gfx.FONT_TINY;
        } else if (width < 80 || height < 50 || text.length() > 6) {
            return Gfx.FONT_SMALL;
        } else if (width < 120 || height < 70) {
            return Gfx.FONT_MEDIUM;
        } else {
            return Gfx.FONT_LARGE;
        }
    }
}