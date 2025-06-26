/**
 * API Service for Eversense Companion
 * 
 * This module handles authentication and data fetching from the Eversense API.
 * Currently uses mock data and endpoints for demonstration purposes.
 * 
 * To connect to a real API:
 * 1. Replace MOCK_BASE_URL with the actual API endpoint
 * 2. Update the authentication flow to use real OAuth2 or API key authentication
 * 3. Modify the data structures to match the real API response format
 * 4. Add proper error handling for network issues and API errors
 * 5. Implement token refresh logic for expired tokens
 */

// Mock API configuration
const MOCK_BASE_URL = 'https://example.com/api/v1';
const MOCK_AUTH_URL = 'https://example.com/auth/token';

// Authentication token storage
let authToken = null;

/**
 * Mock authentication function
 * In a real implementation, this would:
 * - Make a POST request to the authentication endpoint
 * - Send credentials (username/password, API key, or OAuth2 flow)
 * - Store the returned bearer token securely
 * - Handle token expiration and refresh
 */
async function authenticate() {
    try {
        // Mock authentication request
        console.log(`[MOCK] Making authentication request to: ${MOCK_AUTH_URL}`);
        
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 500));
        
        // Mock response - in real implementation, this would be:
        // const response = await fetch(MOCK_AUTH_URL, {
        //     method: 'POST',
        //     headers: {
        //         'Content-Type': 'application/json',
        //     },
        //     body: JSON.stringify({
        //         username: 'user@example.com',
        //         password: 'password',
        //         // or client_id, client_secret for OAuth2
        //     })
        // });
        // const data = await response.json();
        // authToken = data.access_token;
        
        authToken = 'mock_bearer_token_' + Date.now();
        console.log('[MOCK] Authentication successful, token:', authToken);
        
        return authToken;
    } catch (error) {
        console.error('Authentication failed:', error);
        throw new Error('Failed to authenticate with the API');
    }
}

/**
 * Generate mock glucose data for testing
 * In a real implementation, this data would come from the API
 */
function generateMockGlucoseData(count = 24) {
    const data = [];
    const now = new Date();
    
    // Generate data points for the last 24 hours (or specified count)
    for (let i = count - 1; i >= 0; i--) {
        const timestamp = new Date(now.getTime() - (i * 60 * 1000)); // Every minute
        
        // Generate realistic glucose values with some patterns
        let baseValue = 100;
        const timeOfDay = timestamp.getHours();
        
        // Simulate typical glucose patterns
        if (timeOfDay >= 6 && timeOfDay <= 8) {
            baseValue += 20; // Morning spike
        } else if (timeOfDay >= 12 && timeOfDay <= 14) {
            baseValue += 30; // Lunch spike
        } else if (timeOfDay >= 18 && timeOfDay <= 20) {
            baseValue += 25; // Dinner spike
        }
        
        // Add some random variation
        const variation = (Math.random() - 0.5) * 40;
        const value = Math.max(60, Math.min(300, baseValue + variation));
        
        data.push({
            timestamp: timestamp.toISOString(),
            value: Math.round(value),
            trend: Math.random() > 0.5 ? 'stable' : (Math.random() > 0.5 ? 'rising' : 'falling')
        });
    }
    
    return data;
}

/**
 * Fetch initial glucose data
 * In a real implementation, this would fetch historical data from the API
 */
async function fetchInitialGlucoseData() {
    try {
        if (!authToken) {
            throw new Error('Not authenticated. Please authenticate first.');
        }
        
        console.log(`[MOCK] Fetching initial glucose data from: ${MOCK_BASE_URL}/glucose/history`);
        
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 800));
        
        // Mock API request - in real implementation:
        // const response = await fetch(`${MOCK_BASE_URL}/glucose/history`, {
        //     method: 'GET',
        //     headers: {
        //         'Authorization': `Bearer ${authToken}`,
        //         'Content-Type': 'application/json',
        //     }
        // });
        // 
        // if (!response.ok) {
        //     throw new Error(`HTTP error! status: ${response.status}`);
        // }
        // 
        // const data = await response.json();
        // return data.readings || data.data || [];
        
        const mockData = generateMockGlucoseData(144); // 24 hours of data (every 10 minutes)
        console.log('[MOCK] Initial glucose data fetched:', mockData.length, 'readings');
        
        return mockData;
    } catch (error) {
        console.error('Failed to fetch initial glucose data:', error);
        throw error;
    }
}

/**
 * Fetch the latest glucose reading
 * This function is called periodically to get new data points
 */
async function fetchLatestGlucoseReading() {
    try {
        if (!authToken) {
            throw new Error('Not authenticated. Please authenticate first.');
        }
        
        console.log(`[MOCK] Fetching latest glucose reading from: ${MOCK_BASE_URL}/glucose/latest`);
        
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, 300));
        
        // Mock API request - in real implementation:
        // const response = await fetch(`${MOCK_BASE_URL}/glucose/latest`, {
        //     method: 'GET',
        //     headers: {
        //         'Authorization': `Bearer ${authToken}`,
        //         'Content-Type': 'application/json',
        //     }
        // });
        // 
        // if (!response.ok) {
        //     throw new Error(`HTTP error! status: ${response.status}`);
        // }
        // 
        // const data = await response.json();
        // return data.reading || data.data || null;
        
        // Generate a new mock data point
        const mockData = generateMockGlucoseData(1);
        const latestReading = mockData[0];
        latestReading.timestamp = new Date().toISOString(); // Current time
        
        console.log('[MOCK] Latest glucose reading fetched:', latestReading);
        
        return latestReading;
    } catch (error) {
        console.error('Failed to fetch latest glucose reading:', error);
        throw error;
    }
}

/**
 * Check if the current token is still valid
 * In a real implementation, this would validate the token with the API
 */
function isAuthenticated() {
    return authToken !== null;
}

/**
 * Clear authentication token (logout)
 */
function clearAuthentication() {
    authToken = null;
    console.log('[MOCK] Authentication cleared');
}

// Export the API functions
window.EversenseAPI = {
    authenticate,
    fetchInitialGlucoseData,
    fetchLatestGlucoseReading,
    isAuthenticated,
    clearAuthentication
};