# Eversense Companion

A client-only D3.js application for visualizing blood glucose levels in a stock ticker style chart. This application provides real-time monitoring of blood glucose levels with colored zones indicating safe, high, and low glucose ranges.

## Features

- **Real-time Glucose Monitoring**: Displays current glucose levels with automatic updates every minute
- **Stock Ticker Style Chart**: Interactive D3.js chart showing glucose trends over time
- **Color-coded Zones**: Visual indicators for glucose ranges:
  - 🟢 **Good Zone**: 80-130 mg/dL
  - 🔴 **Too High**: >130 mg/dL  
  - 🟡 **Too Low**: <80 mg/dL
- **Trend Indicators**: Shows if glucose levels are rising, falling, or stable
- **Responsive Design**: Adapts to different screen sizes
- **Interactive Tooltips**: Hover over data points for detailed information

## Prerequisites

- Node.js (version 16.0.0 or higher)
- npm (comes with Node.js)
- Modern web browser with JavaScript enabled

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alexanderkyte/eversense-companion.git
   cd eversense-companion
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

## Usage

### Development Mode

To run the application in development mode with live reload:

```bash
npm run dev
```

This will start a local server at `http://localhost:8080`. The application will automatically reload when you make changes to the source files.

### Production Build

To build the application for production:

```bash
npm run build
```

This creates a `dist/` folder with all the compiled assets ready for deployment.

### Serve Production Build

To serve the production build locally:

```bash
npm run serve
```

## Project Structure

```
eversense-companion/
├── src/
│   ├── api.js          # API service for authentication and data fetching
│   ├── chart.js        # D3.js chart component
│   └── app.js          # Main application logic
├── index.html          # Main HTML file
├── package.json        # Node.js dependencies and scripts
└── README.md          # This file
```

## API Integration

The application currently uses mock data and stubbed API endpoints for demonstration purposes. To connect to a real Eversense API:

### Authentication Setup

1. **Update API URLs** in `src/api.js`:
   ```javascript
   const MOCK_BASE_URL = 'https://your-api-endpoint.com/api/v1';
   const MOCK_AUTH_URL = 'https://your-api-endpoint.com/auth/token';
   ```

2. **Implement Real Authentication**:
   - Replace the mock authentication in the `authenticate()` function
   - Add your actual credentials (API key, OAuth2, etc.)
   - Implement token refresh logic for expired tokens

### Data Fetching

1. **Update Data Endpoints**:
   - Modify `fetchInitialGlucoseData()` to call your historical data endpoint
   - Update `fetchLatestGlucoseReading()` to call your real-time data endpoint

2. **Data Format**:
   The application expects glucose readings in this format:
   ```javascript
   {
     timestamp: "2024-01-15T10:30:00Z",  // ISO 8601 format
     value: 105,                         // mg/dL
     trend: "stable"                     // "rising", "falling", or "stable"
   }
   ```

### Error Handling

The application includes comprehensive error handling for:
- Network connectivity issues
- Authentication failures
- API rate limiting
- Invalid data responses

## Customization

### Glucose Thresholds

You can modify the glucose level thresholds in `src/chart.js`:

```javascript
this.thresholds = {
    low: 80,    // Values below this are "too low"
    high: 130   // Values above this are "too high"
};
```

### Update Frequency

To change how often new data is fetched, modify the interval in `src/app.js`:

```javascript
// Update every minute (60,000 ms)
this.updateInterval = setInterval(() => {
    this.fetchLatestData();
}, 60000);
```

### Chart Appearance

The chart styling can be customized via CSS in `index.html`. Key classes:
- `.zone-good`, `.zone-high`, `.zone-low` - Background zones
- `.line` - Main glucose trend line
- `.dot` - Individual data points

## Browser Compatibility

This application is compatible with:
- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## Deployment

### Static Site Deployment

The application can be deployed to any static site hosting service:

1. **Build the application**:
   ```bash
   npm run build
   ```

2. **Deploy the `dist/` folder** to your hosting service:
   - Netlify
   - Vercel
   - GitHub Pages
   - AWS S3
   - Any other static hosting service

### CDN Deployment

For better performance, consider using a CDN to serve the static assets. The application is optimized for edge caching.

## Security Considerations

- **API Keys**: Never commit API keys or sensitive credentials to version control
- **HTTPS**: Always use HTTPS in production for secure data transmission
- **CORS**: Ensure your API server is configured to accept requests from your domain
- **Token Storage**: Consider using secure storage for authentication tokens

## Troubleshooting

### Common Issues

1. **Chart not displaying**:
   - Check browser console for JavaScript errors
   - Ensure D3.js library is loaded
   - Verify data format matches expected structure

2. **API connection issues**:
   - Check network connectivity
   - Verify API endpoint URLs are correct
   - Ensure CORS is properly configured

3. **Authentication failures**:
   - Verify API credentials are correct
   - Check if authentication tokens have expired
   - Ensure API server is accessible

### Debug Mode

To enable debug logging, open browser developer tools and check the console. The application logs all API calls and data updates.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or issues:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the browser console for error messages

## Acknowledgments

- [D3.js](https://d3js.org/) for data visualization
- [Eversense](https://www.eversensediabetes.com/) for inspiration
- The diabetes management community for feedback and requirements