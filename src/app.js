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
            errorContainer: document.getElementById('error-container')
        };
        
        this.init();
    }
    
    async init() {
        try {
            console.log('Initializing Eversense Companion...');
            
            // Show loading state
            this.showLoading();
            
            // Step 1: Authenticate
            console.log('Step 1: Authenticating...');
            await EversenseAPI.authenticate();
            
            // Step 2: Initialize chart
            console.log('Step 2: Initializing chart...');
            this.chart = new GlucoseChart('chart');
            
            // Step 3: Fetch initial data
            console.log('Step 3: Fetching initial glucose data...');
            const initialData = await EversenseAPI.fetchInitialGlucoseData();
            
            // Step 4: Update chart with initial data
            this.chart.updateChart(initialData);
            this.updateUI(this.chart.getLatestReading());
            
            // Step 5: Hide loading and show chart
            this.hideLoading();
            
            // Step 6: Start periodic updates
            this.startPeriodicUpdates();
            
            this.isInitialized = true;
            console.log('Eversense Companion initialized successfully!');
            
        } catch (error) {
            console.error('Failed to initialize application:', error);
            this.showError('Failed to initialize the application. Please check your connection and try again.');
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