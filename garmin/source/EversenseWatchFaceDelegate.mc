using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class EversenseWatchFaceDelegate extends Ui.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onPowerBudgetExceeded(powerInfo) {
        Sys.println("Average execution time: " + powerInfo.executionTimeAverage);
        Sys.println("Allowed execution time: " + powerInfo.executionTimeLimit);
    }

}