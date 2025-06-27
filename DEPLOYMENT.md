# Deployment Guide

This document provides step-by-step instructions for deploying the Eversense Companion D3.js blood glucose monitoring application.

## Quick Deployment

### From GitHub Releases

1. **Download a release**:
   - Go to the [Releases page](../../releases)
   - Download either `eversense-companion-static-site.zip` or `eversense-companion-static-site.tar.gz`

2. **Extract the archive**:
   ```bash
   # For ZIP
   unzip eversense-companion-static-site.zip
   
   # For TAR.GZ
   tar -xzf eversense-companion-static-site.tar.gz
   ```

3. **Deploy to your hosting service** (see platform-specific instructions below)

### From Source Code

1. **Clone and build**:
   ```bash
   git clone https://github.com/alexanderkyte/eversense-companion.git
   cd eversense-companion
   npm install
   npm run build
   ```

2. **Deploy the `dist/` folder** to your hosting service

## Platform-Specific Deployment

### GitHub Pages

#### Automatic Deployment (Recommended)
The repository includes GitHub Actions for automatic deployment:

1. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Source: "GitHub Actions"

2. **Create a release**:
   ```bash
   npm run release:patch
   ```

3. **Access your site**:
   - Your site will be available at `https://<username>.github.io/eversense-companion`

#### Manual Deployment
1. Build the site: `npm run build`
2. Push the `dist/` folder to a `gh-pages` branch
3. Enable GitHub Pages with the `gh-pages` branch as source

### Netlify

1. **Drag and Drop**:
   - Build: `npm run build`
   - Drag the `dist/` folder to [Netlify Drop](https://app.netlify.com/drop)

2. **Git Integration**:
   - Connect your GitHub repository
   - Build command: `npm run build`
   - Publish directory: `dist`

3. **Manual Upload**:
   - Download a release archive from GitHub
   - Extract and upload to Netlify

### Vercel

1. **Git Integration**:
   - Import your GitHub repository
   - Build command: `npm run build`
   - Output directory: `dist`

2. **Manual Deployment**:
   ```bash
   npm install -g vercel
   npm run build
   cd dist
   vercel --prod
   ```

### AWS S3 + CloudFront

1. **Create S3 bucket**:
   ```bash
   aws s3 mb s3://your-bucket-name
   ```

2. **Upload files**:
   ```bash
   npm run build
   aws s3 sync dist/ s3://your-bucket-name --delete
   ```

3. **Configure bucket for static hosting**:
   ```bash
   aws s3 website s3://your-bucket-name --index-document index.html
   ```

4. **Optional: Set up CloudFront for CDN**

### Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize project**:
   ```bash
   firebase init hosting
   # Public directory: dist
   # Single-page app: No
   ```

3. **Deploy**:
   ```bash
   npm run build
   firebase deploy
   ```

### Apache/Nginx

1. **Build the application**:
   ```bash
   npm run build
   ```

2. **Copy files to web root**:
   ```bash
   # Apache (typical locations)
   sudo cp -r dist/* /var/www/html/
   
   # Nginx (typical locations)
   sudo cp -r dist/* /usr/share/nginx/html/
   ```

3. **Configure server** (if needed):
   ```apache
   # Apache .htaccess (in dist/ or web root)
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule . /index.html [L]
   ```

   ```nginx
   # Nginx configuration
   location / {
       try_files $uri $uri/ /index.html;
   }
   ```

## Configuration for Production

### Environment-Specific Settings

The application may require configuration changes for production deployment:

1. **API Endpoints**: Update URLs in `src/api.js` if needed
2. **CORS Settings**: Ensure your API server allows requests from your domain
3. **HTTPS**: Always use HTTPS in production for secure data transmission

### Performance Optimization

1. **Enable Gzip Compression**:
   ```nginx
   # Nginx
   gzip on;
   gzip_types text/css application/javascript application/json;
   ```

2. **Set Cache Headers**:
   ```apache
   # Apache
   <IfModule mod_expires.c>
       ExpiresActive On
       ExpiresByType text/css "access plus 1 year"
       ExpiresByType application/javascript "access plus 1 year"
   </IfModule>
   ```

3. **CDN Integration**: Consider using a CDN for global content delivery

## Security Considerations

### HTTPS Configuration

Always serve the application over HTTPS in production:

```nginx
# Nginx HTTPS redirect
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        root /path/to/dist;
        try_files $uri $uri/ /index.html;
    }
}
```

### Content Security Policy

Add CSP headers for enhanced security:

```html
<!-- Add to index.html <head> section -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'self' https://d3js.org; style-src 'self' 'unsafe-inline';">
```

### API Security

1. **API Keys**: Never commit API keys to source code
2. **CORS**: Configure API server CORS settings properly
3. **Rate Limiting**: Implement rate limiting on API endpoints
4. **Authentication**: Use secure token storage and refresh mechanisms

## Troubleshooting

### Common Deployment Issues

1. **404 Errors on Refresh**:
   - Configure server to serve `index.html` for all routes
   - See server configuration examples above

2. **API Connection Issues**:
   - Check CORS configuration
   - Verify API endpoint URLs
   - Ensure HTTPS is used for API calls in production

3. **D3.js Not Loading**:
   - Verify CDN access to d3js.org
   - Consider hosting D3.js locally if CDN is blocked

4. **Caching Issues**:
   - Clear browser cache
   - Check server cache headers
   - Use cache-busting techniques if needed

### Health Check

Test your deployment:

1. **Basic Load Test**:
   ```bash
   curl -I https://your-domain.com/
   ```

2. **Content Verification**:
   ```bash
   curl https://your-domain.com/ | grep "Eversense Companion"
   ```

3. **API Connectivity** (if applicable):
   - Test login functionality
   - Verify data fetching works
   - Check for console errors

## Monitoring

### Basic Monitoring

1. **Uptime Monitoring**: Use services like UptimeRobot or Pingdom
2. **Error Tracking**: Monitor browser console errors
3. **Performance**: Use Google PageSpeed Insights or similar tools

### Analytics

Consider adding analytics to track usage:

```html
<!-- Google Analytics example -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## Support

For deployment-specific issues:

1. Check the platform-specific documentation
2. Review server logs for error messages
3. Test with browser developer tools
4. Open an issue on GitHub with deployment details