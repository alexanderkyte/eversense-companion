/**
 * API Service for Eversense Companion
 * 
 * This module handles authentication and data fetching from the Eversense API.
 * Integrated with real Eversense API endpoints.
 */

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

/**
 * Authentication function for real Eversense API
 */
async function authenticate(username, password, rememberMe = false) {
    try {
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
 * Fetch user details and current glucose state
 */
async function fetchUserDetails() {
    await ensureTokenValid();
    
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
 * Fetch historical glucose data
 */
async function fetchInitialGlucoseData() {
    try {
        await ensureTokenValid();
        
        if (!userId) {
            const { userId: fetchedUserId } = await fetchUserDetails();
            userId = fetchedUserId;
        }
        
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
 * Fetch the latest glucose reading and user state
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

// Export the API functions
window.EversenseAPI = {
    authenticate,
    fetchInitialGlucoseData,
    fetchLatestGlucoseReading,
    fetchUserDetails,
    isAuthenticated,
    clearAuthentication,
    getSavedCredentials,
    clearSavedCredentials
};