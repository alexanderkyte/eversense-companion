/**
 * API Service for Eversense Companion
 * 
 * This module handles authentication and data fetching from the Eversense API.
 * Integrated with real Eversense API endpoints.
 */

// Development mode detection - checks if running on localhost
const isDevelopmentMode = () => {
    return window.location.hostname === 'localhost' || 
           window.location.hostname === '127.0.0.1' || 
           window.location.hostname === '0.0.0.0';
};

// Real Eversense API configuration
const LOGIN_URL = "https://usiamapi.eversensedms.com/connect/token";
const USER_DETAILS_URL = "https://usapialpha.eversensedms.com/api/care/GetFollowingPatientList";
const GLUCOSE_URL = "https://usapialpha.eversensedms.com/api/care/GetFollowingUserSensorGlucose";

// Authentication and user data storage
let authToken = null;
let tokenExpiry = 0;
let userId = null;
let credentials = null;

// LocalStorage keys for credential persistence
const STORAGE_KEYS = {
    USERNAME: 'eversense_username',
    PASSWORD: 'eversense_password',
    REMEMBER: 'eversense_remember'
};

// Mock data for development mode
const MOCK_DATA = {
    // Mock authentication response
    authResponse: {
        access_token: "mock_access_token_for_development",
        expires_in: 43200
    },
    
    // Mock user details response
    userDetails: [{
        UserID: "mock_user_123",
        CurrentGlucose: 105,
        GlucoseTrend: 3, // FLAT
        IsTransmitterConnected: true
    }],
    
    // Mock glucose readings for last 24 hours
    glucoseData: generateMockGlucoseData()
};

/**
 * Generate realistic mock glucose data for the last 24 hours
 */
function generateMockGlucoseData() {
    const readings = [];
    const now = new Date();
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    // Generate a reading every 5 minutes for 24 hours
    let currentTime = new Date(twentyFourHoursAgo);
    let currentValue = 95 + Math.random() * 40; // Start with value between 95-135
    
    while (currentTime < now) {
        // Simulate realistic glucose variations
        const variation = (Math.random() - 0.5) * 10; // +/- 5 mg/dL variation
        currentValue = Math.max(70, Math.min(200, currentValue + variation));
        
        readings.push({
            EventTypeID: 1,
            Deleted: false,
            EventDate: currentTime.toISOString(),
            Value: Math.round(currentValue)
        });
        
        // Next reading in 5 minutes
        currentTime = new Date(currentTime.getTime() + 5 * 60 * 1000);
    }
    
    return readings;
}

/**
 * Authentication function for real Eversense API (with development mode support)
 */
async function authenticate(username, password, rememberMe = false) {
    try {
        console.log('Authentication request started...');
        
        // In development mode, use mock authentication
        if (isDevelopmentMode()) {
            console.log('🚀 Development mode detected - using mock authentication');
            
            // Simulate network delay
            await new Promise(resolve => setTimeout(resolve, 500));
            
            // Store credentials for token refresh
            credentials = { username, password };
            
            // Use mock token data
            const tokenData = MOCK_DATA.authResponse;
            authToken = tokenData.access_token;
            tokenExpiry = Date.now() + (tokenData.expires_in || 43200) * 1000 - 60000; // Subtract 1 minute for safety
            
            // Save credentials to localStorage if remember is enabled
            if (rememberMe) {
                saveCredentials(username, password);
            } else {
                clearSavedCredentials();
            }
            
            console.log('✅ Mock authentication successful, token expires in', tokenData.expires_in || 43200, 'seconds');
            
            return authToken;
        }
        
        // Production mode - use real Eversense API
        console.log(`Making authentication request to: ${LOGIN_URL}`);
        
        // Store credentials for token refresh
        credentials = { username, password };
        
        const data = new URLSearchParams({
            grant_type: "password",
            client_id: "eversenseMMAAndroid",
            client_secret: "6ksPx#]~wQ3U",
            username: username,
            password: password,
        });
        
        const response = await fetch(LOGIN_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: data
        });
        
        if (!response.ok) {
            throw new Error(`Authentication failed: ${response.status} ${response.statusText}`);
        }
        
        const tokenData = await response.json();
        authToken = tokenData.access_token;
        tokenExpiry = Date.now() + (tokenData.expires_in || 43200) * 1000 - 60000; // Subtract 1 minute for safety
        
        // Save credentials to localStorage if remember is enabled
        if (rememberMe) {
            saveCredentials(username, password);
        } else {
            clearSavedCredentials();
        }
        
        console.log('Authentication successful, token expires in', tokenData.expires_in || 43200, 'seconds');
        
        return authToken;
    } catch (error) {
        console.error('Authentication failed:', error);
        throw new Error(`Failed to authenticate: ${error.message}`);
    }
}

/**
 * Ensure the authentication token is valid, refresh if needed
 */
async function ensureTokenValid() {
    if (!authToken || Date.now() > tokenExpiry) {
        console.log('Token expired or missing, re-login needed');
        
        if (!credentials) {
            // Try to load saved credentials
            const savedCredentials = getSavedCredentials();
            if (savedCredentials) {
                credentials = { username: savedCredentials.username, password: savedCredentials.password };
            } else {
                throw new Error('No stored credentials for token refresh');
            }
        }
        
        await authenticate(credentials.username, credentials.password, true); // Auto-save if refreshing
    }
}

/**
 * Fetch user details and current glucose state (with development mode support)
 */
async function fetchUserDetails() {
    await ensureTokenValid();
    
    // In development mode, use mock data
    if (isDevelopmentMode()) {
        console.log('🚀 Development mode - using mock user details');
        
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 300));
        
        const userData = MOCK_DATA.userDetails;
        userId = userData[0]?.UserID;
        
        console.log('Mock UserID fetched:', userId);
        
        // Map trend values
        const trends = {
            0: "STALE",
            1: "FALLING_FAST", 
            2: "FALLING",
            3: "FLAT",
            4: "RISING",
            5: "RISING_FAST",
            6: "FALLING_RAPID",
            7: "RAISING_RAPID"
        };
        
        const state = {
            currentGlucose: userData[0]?.CurrentGlucose,
            glucoseTrend: trends[userData[0]?.GlucoseTrend] || "UNKNOWN",
            isTransmitterConnected: userData[0]?.IsTransmitterConnected
        };
        
        return { userId, state };
    }
    
    // Production mode - use real API
    const headers = {
        "Authorization": `Bearer ${authToken}`,
        "Content-Type": "application/json"
    };
    
    try {
        console.log(`Fetching user details from: ${USER_DETAILS_URL}`);
        const response = await fetch(USER_DETAILS_URL, {
            method: 'GET',
            headers: headers
        });
        
        if (!response.ok) {
            throw new Error(`Failed to fetch user details: ${response.status} ${response.statusText}`);
        }
        
        const userData = await response.json();
        userId = userData[0]?.UserID;
        
        console.log('UserID fetched:', userId);
        
        // Map trend values
        const trends = {
            0: "STALE",
            1: "FALLING_FAST", 
            2: "FALLING",
            3: "FLAT",
            4: "RISING",
            5: "RISING_FAST",
            6: "FALLING_RAPID",
            7: "RAISING_RAPID"
        };
        
        const state = {
            currentGlucose: userData[0]?.CurrentGlucose,
            glucoseTrend: trends[userData[0]?.GlucoseTrend] || "UNKNOWN",
            isTransmitterConnected: userData[0]?.IsTransmitterConnected
        };
        
        return { userId, state };
    } catch (error) {
        console.error('Failed to fetch user details:', error);
        throw error;
    }
}

/**
 * Fetch historical glucose data (with development mode support)
 */
async function fetchInitialGlucoseData() {
    try {
        await ensureTokenValid();
        
        if (!userId) {
            const { userId: fetchedUserId } = await fetchUserDetails();
            userId = fetchedUserId;
        }
        
        // In development mode, use mock data
        if (isDevelopmentMode()) {
            console.log('🚀 Development mode - using mock historical glucose data');
            
            // Simulate network delay
            await new Promise(resolve => setTimeout(resolve, 500));
            
            const data = MOCK_DATA.glucoseData;
            const glucoseReadings = [];
            
            for (const event of data) {
                if (event.EventTypeID === 1 && event.Deleted === false && event.EventDate) {
                    const eventDate = new Date(event.EventDate);
                    glucoseReadings.push({
                        timestamp: eventDate.toISOString(),
                        value: Math.round(event.Value),
                        trend: 'stable' // Default trend, can be enhanced later
                    });
                }
            }
            
            // Sort by timestamp
            glucoseReadings.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
            
            console.log('Mock historical glucose data fetched:', glucoseReadings.length, 'readings');
            return glucoseReadings;
        }
        
        // Production mode - use real API
        console.log(`Fetching historical glucose data from: ${GLUCOSE_URL}`);
        
        // Get last 24 hours of data
        const now = new Date();
        const fromDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        
        const requestData = {
            UserID: userId,
            startDate: fromDate.toISOString(),
            endDate: now.toISOString(),
        };
        
        const response = await fetch(GLUCOSE_URL, {
            method: 'POST', // Based on Python script, this appears to be a POST with JSON data
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestData)
        });
        
        if (!response.ok) {
            throw new Error(`Failed to fetch glucose data: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.json();
        const glucoseReadings = [];
        
        for (const event of data) {
            if (event.EventTypeID === 1 && event.Deleted === false && event.EventDate) {
                const eventDate = new Date(event.EventDate);
                glucoseReadings.push({
                    timestamp: eventDate.toISOString(),
                    value: Math.round(event.Value),
                    trend: 'stable' // Default trend, can be enhanced later
                });
            }
        }
        
        // Sort by timestamp
        glucoseReadings.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        
        console.log('Historical glucose data fetched:', glucoseReadings.length, 'readings');
        return glucoseReadings;
        
    } catch (error) {
        console.error('Failed to fetch initial glucose data:', error);
        throw error;
    }
}

/**
 * Fetch the latest glucose reading and user state (with development mode support)
 */
async function fetchLatestGlucoseReading() {
    try {
        await ensureTokenValid();
        
        if (!userId) {
            const { userId: fetchedUserId } = await fetchUserDetails();
            userId = fetchedUserId;
        }
        
        console.log('Fetching latest glucose reading and user state');
        
        // Get current user state which includes current glucose
        const { state } = await fetchUserDetails();
        
        if (state.currentGlucose) {
            const trendMap = {
                'FALLING_FAST': 'falling',
                'FALLING': 'falling', 
                'FALLING_RAPID': 'falling',
                'RISING_FAST': 'rising',
                'RISING': 'rising',
                'RAISING_RAPID': 'rising',
                'FLAT': 'stable',
                'STALE': 'stable'
            };
            
            const latestReading = {
                timestamp: new Date().toISOString(),
                value: Math.round(state.currentGlucose),
                trend: trendMap[state.glucoseTrend] || 'stable',
                isTransmitterConnected: state.isTransmitterConnected
            };
            
            console.log('Latest glucose reading fetched:', latestReading);
            return latestReading;
        }
        
        return null;
    } catch (error) {
        console.error('Failed to fetch latest glucose reading:', error);
        throw error;
    }
}

/**
 * Save credentials to localStorage
 */
function saveCredentials(username, password) {
    try {
        localStorage.setItem(STORAGE_KEYS.USERNAME, username);
        localStorage.setItem(STORAGE_KEYS.PASSWORD, password);
        localStorage.setItem(STORAGE_KEYS.REMEMBER, 'true');
        console.log('Credentials saved to localStorage');
    } catch (error) {
        console.warn('Failed to save credentials to localStorage:', error);
    }
}

/**
 * Load saved credentials from localStorage
 */
function getSavedCredentials() {
    try {
        const rememberMe = localStorage.getItem(STORAGE_KEYS.REMEMBER) === 'true';
        if (rememberMe) {
            const username = localStorage.getItem(STORAGE_KEYS.USERNAME);
            const password = localStorage.getItem(STORAGE_KEYS.PASSWORD);
            if (username && password) {
                return { username, password, rememberMe: true };
            }
        }
    } catch (error) {
        console.warn('Failed to load credentials from localStorage:', error);
    }
    return null;
}

/**
 * Clear saved credentials from localStorage
 */
function clearSavedCredentials() {
    try {
        localStorage.removeItem(STORAGE_KEYS.USERNAME);
        localStorage.removeItem(STORAGE_KEYS.PASSWORD);
        localStorage.removeItem(STORAGE_KEYS.REMEMBER);
        console.log('Saved credentials cleared from localStorage');
    } catch (error) {
        console.warn('Failed to clear credentials from localStorage:', error);
    }
}

/**
 * Check if the current token is still valid
 */
function isAuthenticated() {
    return authToken !== null && Date.now() < tokenExpiry;
}

/**
 * Clear authentication token and stored credentials (logout)
 */
function clearAuthentication() {
    authToken = null;
    tokenExpiry = 0;
    userId = null;
    credentials = null;
    console.log('Authentication cleared');
}

/**
 * Show development mode indicator if in development mode
 */
function showDevelopmentModeIndicator() {
    if (isDevelopmentMode()) {
        const indicator = document.getElementById('dev-mode-indicator');
        if (indicator) {
            indicator.style.display = 'block';
        }
        console.log('🚀 Development mode active - CORS issues bypassed with mock data');
    }
}

// Export the API functions
window.EversenseAPI = {
    authenticate,
    fetchInitialGlucoseData,
    fetchLatestGlucoseReading,
    fetchUserDetails,
    isAuthenticated,
    clearAuthentication,
    getSavedCredentials,
    clearSavedCredentials,
    showDevelopmentModeIndicator,
    isDevelopmentMode
};