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

## Release Management

### Automated Releases

This project includes automated release workflows that build and package the static site for distribution.

#### Creating a Release

1. **Automatic Version Bump and Release**:
   ```bash
   # For patch version (1.0.0 -> 1.0.1)
   npm run release:patch
   
   # For minor version (1.0.0 -> 1.1.0)
   npm run release:minor
   
   # For major version (1.0.0 -> 2.0.0)
   npm run release:major
   ```

2. **Manual Release via GitHub Actions**:
   - Go to the GitHub Actions tab in your repository
   - Select "Build and Release" workflow
   - Click "Run workflow"
   - Enter the desired version (e.g., v1.0.1)
   - Click "Run workflow"

#### What Happens During a Release

When a release is triggered:

1. **Builds the static site** using `npm run build`
2. **Creates downloadable archives**:
   - `eversense-companion-static-site.zip`
   - `eversense-companion-static-site.tar.gz`
3. **Creates a GitHub Release** with:
   - Release notes
   - Downloadable static site archives
   - Deployment instructions
4. **Deploys to GitHub Pages** (for tagged releases)

#### Release Assets

Each release includes:
- **Complete static site** ready for deployment
- **All source files** (HTML, CSS, JavaScript)
- **Dependencies included** (D3.js)
- **Production-optimized** files

#### GitHub Pages Deployment

Tagged releases automatically deploy to GitHub Pages at:
`https://<username>.github.io/eversense-companion`

To enable GitHub Pages:
1. Go to repository Settings
2. Navigate to Pages section
3. Select "GitHub Actions" as the source
4. Create a release using one of the methods above

### Manual Deployment

#### Static Site Deployment

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

#### CDN Deployment

For better performance, consider using a CDN to serve the static assets. The application is optimized for edge caching.

### Version Management

The project uses semantic versioning (semver):
- **Patch** (x.x.X): Bug fixes and minor updates
- **Minor** (x.X.x): New features that don't break existing functionality
- **Major** (X.x.x): Breaking changes or major feature overhauls

#### Manual Version Updates

If you prefer manual version management:

```bash
# Update version without git operations
npm run version:patch  # or version:minor, version:major

# Then manually create git tag and push
git add package.json
git commit -m "Bump version to $(node -p "require('./package.json').version")"
git tag v$(node -p "require('./package.json').version")
git push && git push --tags
```

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

### CORS Issues in Development

When running `npm run dev`, you may encounter CORS (Cross-Origin Resource Sharing) errors when the application tries to connect to the Eversense API. This is normal behavior for browsers when making requests from localhost to external APIs.

**Symptoms:**
- "Access to fetch at 'https://...' has been blocked by CORS policy" error in browser console
- Login attempts fail with network errors
- The application displays a detailed CORS error message with instructions

**Solutions:**

1. **Use Chrome with disabled security** (easiest for development):
   ```bash
   # Close all Chrome windows first, then run:
   chrome --disable-web-security --disable-features=VizDisplayCompositor --user-data-dir=/tmp/chrome-dev-session
   ```

2. **Use a CORS browser extension**:
   - Install "CORS Unblock" or "CORS Everywhere" from Chrome Web Store
   - Enable the extension when developing locally

3. **Use Firefox Developer Edition**:
   - Firefox Developer Edition has more relaxed CORS policies for local development

4. **Use the production deployed version**:
   - The app works normally when deployed to a web server (no CORS issues)

5. **Run in a container or VM**:
   - Use a development environment that doesn't have strict CORS policies

**Note:** CORS is a security feature that protects users from malicious websites. Only disable it during development, never in production.

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