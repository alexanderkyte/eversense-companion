using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.SensorHistory as SensorHistory;
using Toybox.Application.Properties as Properties;

class EversenseWatchFaceView extends Ui.WatchFace {

    var backgroundColor = 0x000000;
    var showSeconds = false;
    var baseView;

    function initialize() {
        WatchFace.initialize();
        baseView = new EversenseBaseView();
        baseView.initialize();
        loadWatchFaceSettings();
    }
    
    function loadWatchFaceSettings() {
        showSeconds = Properties.getValue("showSeconds");
        if (showSeconds == null) { showSeconds = false; }
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        // Draw time (24-hour format)
        drawTime(dc, centerX, centerY - 60);
        
        // Draw glucose data  
        drawGlucose(dc, centerX, centerY);
        
        // Draw heart rate
        drawHeartRate(dc, centerX - 60, centerY + 60);
        
        // Draw battery
        drawBattery(dc, centerX + 60, centerY + 60);
        
        // Draw connection status
        drawConnectionStatus(dc, centerX, height - 30);
    }
    
    function drawTime(dc, x, y) {
        var clockTime = Sys.getClockTime();
        var timeString;
        
        if (showSeconds) {
            timeString = Lang.format("$1$:$2$:$3$", [
                clockTime.hour.format("%02d"), 
                clockTime.min.format("%02d"),
                clockTime.sec.format("%02d")
            ]);
        } else {
            timeString = Lang.format("$1$:$2$", [
                clockTime.hour.format("%02d"), 
                clockTime.min.format("%02d")
            ]);
        }
        
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_NUMBER_HOT, timeString, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function drawGlucose(dc, x, y) {
        if (baseView.glucoseValue != null) {
            var glucoseString = baseView.glucoseValue.format("%d") + " mg/dL";
            var color = baseView.getGlucoseColor();
            
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, Gfx.FONT_MEDIUM, glucoseString, Gfx.TEXT_JUSTIFY_CENTER);
            
            // Draw trend arrow
            var trendSymbol = baseView.getTrendSymbol();
            dc.drawText(x, y + 25, Gfx.FONT_SMALL, trendSymbol, Gfx.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(baseView.textColor, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, Gfx.FONT_MEDIUM, "-- mg/dL", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function drawHeartRate(dc, x, y) {
        var heartRate = getHeartRate();
        var hrString = heartRate != null ? heartRate.format("%d") + " BPM" : "-- BPM";
        
        dc.setColor(baseView.textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_TINY, "♥ " + hrString, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function drawBattery(dc, x, y) {
        var battery = Sys.getSystemStats().battery;
        var batteryString = battery.format("%.0f") + "%";
        
        var color = battery > 20 ? baseView.textColor : baseView.lowColor;
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_TINY, "🔋 " + batteryString, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function drawConnectionStatus(dc, x, y) {
        var statusText = baseView.isConnected ? "Connected" : "No Data";
        var color = baseView.isConnected ? baseView.goodColor : baseView.lowColor;
        
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_XTINY, statusText, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function getHeartRate() {
        var heartRateIterator = ActivityMonitor.getHeartRateHistory(null, false);
        var heartRateSample = heartRateIterator.next();
        
        if (heartRateSample != null && heartRateSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            return heartRateSample.heartRate;
        }
        return null;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        baseView.onHide();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
}