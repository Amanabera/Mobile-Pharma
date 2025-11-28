# PharmaHub - Flutter Mobile App

A Flutter mobile application for pharmacy management, based on the Angular customer component. This app allows customers to browse pharmacies and explore medicines.

## Features

- **Pharmacies List**: Browse and search through available pharmacies
- **Explore Medicine**: Search and filter medicines by category and price range
- **Detail Views**: View detailed information about pharmacies and medicines
- **Modern UI**: Clean and intuitive user interface with Material Design

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- An Android emulator or physical device for testing

### Installation

1. Navigate to the project directory:
   ```bash
   cd pharmacy_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update API URL (if needed):
   - Open `lib/services/pharmacy_service.dart` and `lib/services/stock_service.dart`
   - Update the `baseUrl` to match your backend API URL
   - Default: `http://localhost:5170/api`

   **Note**: For Android emulator, use `http://10.0.2.2:5170` instead of `localhost`
   **Note**: For iOS simulator, use `http://localhost:5170`
   **Note**: For physical devices, use your computer's IP address (e.g., `http://192.168.1.100:5170`)

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
pharmacy_app/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── models/
│   │   ├── pharmacy.dart         # Pharmacy model
│   │   └── stock.dart            # Stock/Medicine model
│   ├── services/
│   │   ├── pharmacy_service.dart # Pharmacy API service
│   │   └── stock_service.dart    # Stock/Medicine API service
│   └── screens/
│       ├── pharma_list_screen.dart      # Pharmacies list screen
│       └── explore_medicine_screen.dart  # Medicine exploration screen
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## API Endpoints

The app uses the following API endpoints:

- `GET /api/pharmacy` - Get all pharmacies
- `GET /api/Stock/all` - Get all medicines (public)

## Dependencies

- `http`: ^1.1.0 - For making HTTP requests
- `shared_preferences`: ^2.2.2 - For storing user preferences
- `intl`: ^0.18.1 - For date formatting

## Features Overview

### Pharmacies Screen
- Display all available pharmacies in a grid layout
- Search functionality to filter pharmacies by name
- Tap on a pharmacy card to view detailed information
- Modal dialog showing full pharmacy details

### Explore Medicine Screen
- Display all medicines in a grid layout
- Search functionality to filter medicines by name
- Filter by category (dropdown)
- Filter by price range (min/max)
- Tap on a medicine card to view detailed information
- Modal dialog showing full medicine details

### Navigation
- Drawer navigation with sidebar menu
- Bottom navigation bar for quick access
- User profile display in drawer footer
- Logout functionality

## Customization

### Colors
The app uses a green color scheme (`#1f8c4d`) matching the original design. You can customize colors in:
- `lib/main.dart` - Theme configuration
- Individual screen files - Card and button colors

### API Configuration
Update the base URLs in:
- `lib/services/pharmacy_service.dart`
- `lib/services/stock_service.dart`

## Troubleshooting

### Network Issues
- Ensure your backend API is running
- Check that the API URL is correct for your platform (see Installation step 3)
- Verify network permissions in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```

### Build Issues
- Run `flutter clean` and then `flutter pub get`
- Ensure you're using Flutter SDK 3.0.0 or higher
- Check that all dependencies are compatible

## Future Enhancements

- User authentication and login screen
- Shopping cart functionality
- Order placement
- Push notifications
- Offline data caching
- Image loading for medicines and pharmacies

## License

This project is part of the Pharmacy Management System.

