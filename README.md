# Eversense Companion

A repository containing tools and applications for working with Eversense continuous glucose monitoring data.

## Quick Setup

### Automatic Setup (Recommended)

Run the platform-appropriate setup script to install all dependencies:

**Linux/macOS:**
```bash
./setup.sh
```

**Windows (PowerShell - Recommended):**
```powershell
.\setup-windows.ps1
```

**Windows (Command Prompt):**
```cmd
setup-windows.bat
```

### Manual Setup

If you prefer to install dependencies manually, use the platform-specific scripts:

- **Linux:** `./setup-linux.sh`
- **macOS:** `./setup-macos.sh`
- **Windows:** `setup-windows.bat` or `setup-windows.ps1`

These scripts will install:
- Node.js 16+ and npm (for browser application)
- Python 3.x and pip (for Python client)
- Java 11+ (for Garmin development)
- Garmin Connect IQ SDK (for Garmin watchface/datafield)

## Contents

### Browser Application

The `/browser` directory contains a complete client-only D3.js application for visualizing blood glucose levels in a stock ticker style chart.

**Features:**
- Real-time glucose monitoring with D3.js charts
- Color-coded glucose zones (Good: 80-130 mg/dL, High: >130 mg/dL, Low: <80 mg/dL)
- Interactive tooltips and trend indicators
- Responsive design for desktop and mobile
- Direct integration with Eversense API
- Credential persistence with localStorage

**Quick Start:**
```bash
cd browser
npm install
npm run dev
# Visit http://localhost:8080
```

For detailed setup instructions, see [browser/README.md](browser/README.md).

## License

MIT License - see [LICENSE](LICENSE) file for details.