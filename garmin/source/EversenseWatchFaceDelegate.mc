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
    
    // Enable test mode interaction - menu or screen tap cycles through test scenarios
    function onTap(clickEvent) {
        if (EversenseTestUtils.isTestMode()) {
            var scenario = EversenseTestUtils.cycleTestScenarios();
            Sys.println("Cycled to test scenario: " + scenario);
            Ui.requestUpdate();
            return true;
        }
        return false;
    }
    
    // Menu key can also trigger test scenario cycling
    function onMenu() {
        if (EversenseTestUtils.isTestMode()) {
            var scenario = EversenseTestUtils.cycleTestScenarios();
            Sys.println("Cycled to test scenario: " + scenario);
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

}