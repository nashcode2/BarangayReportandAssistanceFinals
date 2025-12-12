# Web Admin Dashboard Setup Guide

## Overview

The admin interface is designed to run on web browsers (Chrome, Firefox, etc.), while residents use the mobile app. The web admin dashboard includes an interactive map view showing all reports with their locations.

## Google Maps API Configuration for Web

### Step 1: Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project (or create a new one)
3. Navigate to **APIs & Services** → **Library**
4. Search for and enable:
   - **Maps JavaScript API** (required for web)
   - **Geocoding API** (optional, for address lookups)
   - **Places API** (optional, for place searches)

### Step 2: Create API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Copy your API key

### Step 3: Configure API Key Restrictions (Recommended)

1. Click on your API key to edit it
2. Under **Application restrictions**, select **HTTP referrers (web sites)**
3. Add your website domains (e.g., `yourdomain.com/*`, `localhost:*` for development)
4. Under **API restrictions**, restrict to:
   - Maps JavaScript API
   - Geocoding API (if enabled)
   - Places API (if enabled)

### Step 4: Add API Key to Web App

Edit `web/index.html` and replace `YOUR_API_KEY` with your actual API key:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY&libraries=places"></script>
```

## Running the Web App

### Development

```bash
flutter run -d chrome
```

### Production Build

```bash
flutter build web
```

The built files will be in the `build/web` directory. Deploy these files to your web server.

## Features

### Admin Dashboard (Web)

- **Dashboard Overview**: Statistics and quick actions
- **Reports Map View**: Interactive map showing all reports with location markers
  - Color-coded markers by status (Orange: Pending, Blue: In Progress, Green: Resolved)
  - Click markers to view report details
  - Filter reports by status
  - Sidebar with report list
- **Report Management**: View and manage all reports
- **Residents Database**: Manage resident information
- **Announcements**: Create and manage announcements
- **Analytics**: View statistics and charts
- **Events**: Manage community events
- **Service Requests**: Manage service requests

### Resident App (Mobile)

- Report issues with location
- View report status
- Request services
- View announcements
- View events
- And more...

## Platform Detection

The app automatically detects the platform:
- **Web**: Admins see the web dashboard
- **Mobile**: Residents see the mobile interface
- **Mobile (Admin)**: Admins on mobile see the mobile admin dashboard

## Troubleshooting

### Maps Not Loading

1. Verify API key is correct in `web/index.html`
2. Check that Maps JavaScript API is enabled in Google Cloud Console
3. Verify API key restrictions allow your domain
4. Check browser console for errors

### Reports Not Showing on Map

1. Ensure reports have location data (latitude/longitude)
2. Check that reports are being loaded (check Network tab)
3. Verify Firebase permissions for admin users

## Security Notes

- Never commit API keys to version control
- Use environment variables or secure configuration for production
- Restrict API keys to specific domains/IPs
- Monitor API usage in Google Cloud Console

