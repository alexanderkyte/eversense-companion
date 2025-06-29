/**
 * Main Application Logic for Eversense Companion
 * 
 * This module orchestrates the authentication, data fetching, and chart updates.
 */

class EversenseApp {
    constructor() {
        this.chart = null;
        this.updateInterval = null;
        this.isInitialized = false;
        
        // UI elements
        this.elements = {
            currentValue: document.getElementById('current-value'),
            lastUpdated: document.getElementById('last-updated'),
            status: document.getElementById('status'),
            trend: document.getElementById('trend'),
            loading: document.getElementById('loading'),
            chart: document.getElementById('chart'),
            errorContainer: document.getElementById('error-container'),
            loginContainer: document.getElementById('login-container'),
            loginForm: document.getElementById('login-form'),
            loginBtn: document.getElementById('login-btn'),
            usernameInput: document.getElementById('username'),
            passwordInput: document.getElementById('password'),
            rememberMeCheckbox: document.getElementById('remember-me')
        };
        
        this.init();
    }
    
    async init() {
        try {
            console.log('Initializing Eversense Companion...');
            
            // Check if already authenticated
            if (EversenseAPI.isAuthenticated()) {
                await this.startApplication();
            } else {
                // Check for saved credentials and try auto-login
                const savedCredentials = EversenseAPI.getSavedCredentials();
                if (savedCredentials && savedCredentials.username && savedCredentials.password) {
                    console.log('Found saved credentials, attempting auto-login...');
                    try {
                        await EversenseAPI.authenticate(savedCredentials.username, savedCredentials.password, true);
                        await this.startApplication();
                        return;
                    } catch (error) {
                        console.log('Auto-login failed, showing login form:', error.message);
                        // Clear invalid saved credentials
                        EversenseAPI.clearSavedCredentials();
                    }
                }
                
                this.showLoginForm();
            }
            
        } catch (error) {
            console.error('Failed to initialize application:', error);
            this.showError('Failed to initialize the application. Please check your connection and try again.');
        }
    }
    
    showLoginForm() {
        this.elements.loginContainer.style.display = 'block';
        this.elements.loading.style.display = 'none';
        this.elements.chart.style.display = 'none';
        
        // Pre-populate form with saved credentials if available
        const savedCredentials = EversenseAPI.getSavedCredentials();
        if (savedCredentials) {
            this.elements.usernameInput.value = savedCredentials.username || '';
            this.elements.passwordInput.value = savedCredentials.password || '';
            this.elements.rememberMeCheckbox.checked = savedCredentials.rememberMe || false;
        }
        
        // Setup form submission
        this.elements.loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await this.handleLogin();
        });
    }
    
    async handleLogin() {
        const username = this.elements.usernameInput.value.trim();
        const password = this.elements.passwordInput.value;
        const rememberMe = this.elements.rememberMeCheckbox.checked;
        
        if (!username || !password) {
            this.showError('Please enter both email and password.');
            return;
        }
        
        // Disable form during login
        this.elements.loginBtn.disabled = true;
        this.elements.loginBtn.textContent = 'Connecting...';
        this.elements.usernameInput.disabled = true;
        this.elements.passwordInput.disabled = true;
        this.elements.rememberMeCheckbox.disabled = true;
        
        try {
            console.log('Attempting to authenticate with username:', username);
            await EversenseAPI.authenticate(username, password, rememberMe);
            
            // Hide login form and start application
            this.elements.loginContainer.style.display = 'none';
            await this.startApplication();
            
        } catch (error) {
            console.error('Login failed:', error);
            
            // Show enhanced error message for CORS issues
            if (error.isDevelopmentCorsError) {
                this.showCorsError(error.message);
            } else {
                this.showError(`Login failed: ${error.message}`);
            }
            
            // Re-enable form
            this.elements.loginBtn.disabled = false;
            this.elements.loginBtn.textContent = 'Connect to Eversense';
            this.elements.usernameInput.disabled = false;
            this.elements.passwordInput.disabled = false;
            this.elements.rememberMeCheckbox.disabled = false;
        }
    }
    
    async startApplication() {
        try {
            // Show loading state
            this.showLoading();
            this.clearError();
            
            // Step 1: Initialize chart
            console.log('Initializing chart...');
            this.chart = new GlucoseChart('chart');
            
            // Step 2: Fetch initial data
            console.log('Fetching initial glucose data...');
            const initialData = await EversenseAPI.fetchInitialGlucoseData();
            
            // Step 3: Update chart with initial data
            this.chart.updateChart(initialData);
            this.updateUI(this.chart.getLatestReading());
            
            // Step 4: Hide loading and show chart
            this.hideLoading();
            
            // Step 5: Start periodic updates
            this.startPeriodicUpdates();
            
            this.isInitialized = true;
            console.log('Eversense Companion initialized successfully!');
            
        } catch (error) {
            console.error('Failed to start application:', error);
            this.showError('Failed to load glucose data. Please check your connection and try again.');
            this.hideLoading();
        }
    }
    
    async fetchLatestData() {
        try {
            console.log('Fetching latest glucose reading...');
            const latestReading = await EversenseAPI.fetchLatestGlucoseReading();
            
            if (latestReading) {
                // Add new data point to chart
                this.chart.addDataPoint(latestReading);
                
                // Update UI
                this.updateUI(latestReading);
                
                console.log('Latest reading updated:', latestReading);
            }
            
        } catch (error) {
            console.error('Failed to fetch latest data:', error);
            this.showError('Failed to fetch latest glucose reading. Retrying...');
            
            // Clear error after 5 seconds
            setTimeout(() => {
                this.clearError();
            }, 5000);
        }
    }
    
    updateUI(reading) {
        if (!reading) {
            return;
        }
        
        const category = this.getGlucoseCategory(reading.value);
        const categoryText = this.getCategoryText(category);
        const lastUpdated = new Date(reading.timestamp);
        
        // Update current value
        this.elements.currentValue.textContent = `${reading.value} mg/dL`;
        this.elements.currentValue.className = `status-value ${category}`;
        
        // Update last updated time
        this.elements.lastUpdated.textContent = lastUpdated.toLocaleTimeString();
        
        // Update status
        this.elements.status.textContent = categoryText;
        this.elements.status.className = `status-value ${category}`;
        
        // Update trend
        const trend = reading.trend || 'stable';
        const trendIcon = this.getTrendIcon(trend);
        this.elements.trend.textContent = `${trendIcon} ${trend}`;
        this.elements.trend.className = `status-value`;
    }
    
    getGlucoseCategory(value) {
        if (value < 80) {
            return 'low';
        } else if (value > 130) {
            return 'high';
        } else {
            return 'good';
        }
    }
    
    getCategoryText(category) {
        switch (category) {
            case 'low':
                return 'Too Low';
            case 'high':
                return 'Too High';
            case 'good':
            default:
                return 'Good';
        }
    }
    
    getTrendIcon(trend) {
        switch (trend) {
            case 'rising':
                return '↗';
            case 'falling':
                return '↘';
            case 'stable':
            default:
                return '→';
        }
    }
    
    startPeriodicUpdates() {
        // Update every minute (60,000 ms)
        this.updateInterval = setInterval(() => {
            this.fetchLatestData();
        }, 60000);
        
        console.log('Started periodic updates (every 60 seconds)');
    }
    
    stopPeriodicUpdates() {
        if (this.updateInterval) {
            clearInterval(this.updateInterval);
            this.updateInterval = null;
            console.log('Stopped periodic updates');
        }
    }
    
    showLoading() {
        this.elements.loading.style.display = 'block';
        this.elements.chart.style.display = 'none';
    }
    
    hideLoading() {
        this.elements.loading.style.display = 'none';
        this.elements.chart.style.display = 'block';
    }
    
    showError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error';
        errorDiv.innerHTML = `
            <strong>Error:</strong> ${message}
            <button onclick="this.parentElement.remove()" style="float: right; background: none; border: none; color: inherit; cursor: pointer; font-size: 16px;">×</button>
        `;
        
        this.elements.errorContainer.innerHTML = '';
        this.elements.errorContainer.appendChild(errorDiv);
    }
    
    showCorsError(message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error cors-error';
        errorDiv.innerHTML = `
            <div style="white-space: pre-line; line-height: 1.5;">
                <strong>🚫 Development CORS Error</strong>
                ${message}
            </div>
            <button onclick="this.parentElement.remove()" style="float: right; background: none; border: none; color: inherit; cursor: pointer; font-size: 16px; margin-top: -20px;">×</button>
        `;
        
        this.elements.errorContainer.innerHTML = '';
        this.elements.errorContainer.appendChild(errorDiv);
    }
    
    clearError() {
        this.elements.errorContainer.innerHTML = '';
    }
    
    destroy() {
        this.stopPeriodicUpdates();
        
        if (EversenseAPI.isAuthenticated()) {
            EversenseAPI.clearAuthentication();
        }
        
        console.log('Application destroyed');
    }
}

// Initialize the application when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Create global app instance
    window.eversenseApp = new EversenseApp();
    
    // Handle window resize
    window.addEventListener('resize', () => {
        if (window.eversenseApp && window.eversenseApp.chart) {
            window.eversenseApp.chart.resize();
        }
    });
    
    // Handle page unload
    window.addEventListener('beforeunload', () => {
        if (window.eversenseApp) {
            window.eversenseApp.destroy();
        }
    });
});