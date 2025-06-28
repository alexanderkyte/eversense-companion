using Toybox.Application as App;
using Toybox.WatchUi as Ui;

// Shared base app class for both WatchFace and DataField apps
class EversenseBaseApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
}

class EversenseWatchFaceApp extends EversenseBaseApp {
    // Return the initial view of your application here
    function getInitialView() {
        return [ new EversenseWatchFaceView(), new EversenseWatchFaceDelegate() ];
    }
}

class EversenseDataFieldApp extends EversenseBaseApp {
    // Return the initial view of your application here
    function getInitialView() {
        return [ new EversenseDataFieldView() ];
    }
}