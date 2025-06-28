using Toybox.Communications as Communications;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;
using Toybox.Time as Time;

class EversenseAPIClient {
    
    // API URLs
    const LOGIN_URL = "https://usiamapi.eversensedms.com/connect/token";
    const USER_DETAILS_URL = "https://usapialpha.eversensedms.com/api/care/GetFollowingPatientList";
    
    // Client credentials
    const CLIENT_ID = "eversenseMMAAndroid";
    const CLIENT_SECRET = "6ksPx#]~wQ3U";
    
    // Storage keys
    const ACCESS_TOKEN_KEY = "access_token";
    const TOKEN_EXPIRY_KEY = "token_expiry";
    const USER_ID_KEY = "user_id";
    
    var accessToken;
    var tokenExpiry;
    var username;
    var password;
    var userId;
    
    function initialize() {
        loadStoredData();
        loadSettings();
    }
    
    // Check if running in test mode to prevent network calls during testing
    function isTestMode() {
        var testMode = Properties.getValue("testMode");
        var networkDisabled = Properties.getValue("networkDisabled");
        return (testMode != null && testMode == true) || (networkDisabled != null && networkDisabled == true);
    }
    
    function loadStoredData() {
        accessToken = Storage.getValue(ACCESS_TOKEN_KEY);
        tokenExpiry = Storage.getValue(TOKEN_EXPIRY_KEY);
        userId = Storage.getValue(USER_ID_KEY);
    }
    
    function loadSettings() {
        // Get credentials from app settings
        username = Properties.getValue("username");
        password = Properties.getValue("password");
        
        // Fallback to demo credentials if not configured
        if (username == null || username.equals("")) {
            username = "demo@example.com";  // Replace with actual credentials
        }
        if (password == null || password.equals("")) {
            password = "demopassword";      // Replace with actual credentials
        }
    }
    
    function isTokenValid() {
        if (accessToken == null || tokenExpiry == null) {
            return false;
        }
        
        var currentTime = Time.now().value();
        return currentTime < tokenExpiry;
    }
    
    function authenticate(callback) {
        // Check if in test mode - never make network calls during testing
        if (isTestMode()) {
            Sys.println("Test mode: Skipping authentication network call");
            // Simulate successful authentication for testing
            accessToken = "test_access_token";
            tokenExpiry = Time.now().value() + 3600; // Valid for 1 hour
            Storage.setValue(ACCESS_TOKEN_KEY, accessToken);
            Storage.setValue(TOKEN_EXPIRY_KEY, tokenExpiry);
            if (callback != null) {
                callback.invoke(true);
            }
            return;
        }
        
        var params = {
            "grant_type" => "password",
            "client_id" => CLIENT_ID,
            "client_secret" => CLIENT_SECRET,
            "username" => username,
            "password" => password
        };
        
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Communications.makeWebRequest(LOGIN_URL, params, options, method(:onAuthResponse));
    }
    
    function onAuthResponse(responseCode, data) {
        if (responseCode == 200 && data != null) {
            accessToken = data["access_token"];
            var expiresIn = data["expires_in"];
            
            if (expiresIn != null) {
                tokenExpiry = Time.now().value() + expiresIn - 60; // 60 second buffer
            }
            
            // Store tokens
            Storage.setValue(ACCESS_TOKEN_KEY, accessToken);
            Storage.setValue(TOKEN_EXPIRY_KEY, tokenExpiry);
            
            Sys.println("Authentication successful");
        } else {
            Sys.println("Authentication failed: " + responseCode);
            accessToken = null;
            tokenExpiry = null;
        }
    }
    
    function fetchLatestGlucose(callback) {
        // Check if in test mode - never make network calls during testing
        if (isTestMode()) {
            Sys.println("Test mode: Returning mock glucose data instead of network call");
            // Return mock glucose data based on test properties
            var testGlucose = Properties.getValue("testGlucoseValue");
            var testTrend = Properties.getValue("testGlucoseTrend");
            var testConnected = Properties.getValue("testIsConnected");
            
            if (testGlucose == null) {
                // Default test values if not set
                testGlucose = 110;
                testTrend = "stable";
                testConnected = true;
            }
            
            var mockResult = {
                "value" => testGlucose,
                "trend" => testTrend != null ? testTrend : "stable",
                "connected" => testConnected != null ? testConnected : true
            };
            
            callback.invoke(mockResult);
            return;
        }
        
        if (!isTokenValid()) {
            // Need to authenticate first
            authenticate(null);
            // For now, return null - in production you'd queue the request
            callback.invoke(null);
            return;
        }
        
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Authorization" => "Bearer " + accessToken,
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Communications.makeWebRequest(USER_DETAILS_URL, null, options, 
            method(:onGlucoseResponse).with([callback]));
    }
    
    function onGlucoseResponse(responseCode, data, callback) {
        if (responseCode == 200 && data != null && data.size() > 0) {
            var userData = data[0];
            
            // Extract glucose data
            var currentGlucose = userData["CurrentGlucose"];
            var glucoseTrend = userData["GlucoseTrend"];
            var isConnected = userData["IsTransmitterConnected"];
            
            // Map trend values to readable format
            var trendMap = {
                0 => "stable",     // STALE
                1 => "falling",    // FALLING_FAST
                2 => "falling",    // FALLING
                3 => "stable",     // FLAT
                4 => "rising",     // RISING
                5 => "rising",     // RISING_FAST
                6 => "falling",    // FALLING_RAPID
                7 => "rising"      // RAISING_RAPID
            };
            
            var trendString = trendMap[glucoseTrend];
            if (trendString == null) {
                trendString = "stable";
            }
            
            var result = {
                "value" => currentGlucose,
                "trend" => trendString,
                "connected" => isConnected
            };
            
            // Store user ID for future requests
            if (userId == null) {
                userId = userData["UserID"];
                Storage.setValue(USER_ID_KEY, userId);
            }
            
            callback.invoke(result);
        } else {
            Sys.println("Failed to fetch glucose data: " + responseCode);
            callback.invoke(null);
        }
    }
}