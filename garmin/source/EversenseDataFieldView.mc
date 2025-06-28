using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Application.Properties as Properties;
using Toybox.Activity as Activity;

class EversenseDataFieldView extends Ui.DataField {

    var baseView;
    var displayFormat = 0; // 0 = value only, 1 = value + trend, 2 = value + trend + time

    function initialize() {
        DataField.initialize();
        baseView = new EversenseBaseView();
        baseView.initialize();
        loadDataFieldSettings();
    }
    
    function loadDataFieldSettings() {
        displayFormat = Properties.getValue("dataFieldFormat");
        if (displayFormat == null) { displayFormat = 1; }
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
        var fgColor = baseView.getGlucoseColor();
        
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
        if (!baseView.isConnected) {
            dc.setColor(baseView.lowColor, Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(width - 5, 5, 2);
        }
    }
    
    function getDisplayText(width, height) {
        if (baseView.glucoseValue == null) {
            return "--";
        }
        
        var glucoseText = baseView.glucoseValue.toString();
        
        // Format based on display setting and available space
        if (displayFormat == 0 || width < 60) {
            // Value only
            return glucoseText;
        } else if (displayFormat == 1 || width < 100) {
            // Value + trend
            return glucoseText + " " + baseView.getTrendSymbol();
        } else {
            // Value + trend + age indicator
            var ageText = getDataAge();
            return glucoseText + " " + baseView.getTrendSymbol() + " " + ageText;
        }
    }
    
    function getDataAge() {
        if (baseView.lastGlucoseUpdate == null) {
            return "";
        }
        
        var currentTime = Sys.getTimer();
        var ageMs = currentTime - baseView.lastGlucoseUpdate;
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