# User Profile Feature Guide

## Overview
The SeaSmart app now includes a comprehensive user profile system that allows users to manage their personal information and upload custom avatars.

## Features

### 1. User Profile Screen
- **Location**: `lib/screens/user_profile_screen.dart`
- **Access**: Click the profile icon in the top-right corner of the dashboard
- **Functionality**:
  - View and edit personal information
  - Upload custom avatar images
  - Organized into sections: Personal Info, Contact Info, Additional Info

### 2. Avatar Management
- **Custom Uploads**: Users can upload their own avatar images from their device
- **File Support**: Supports common image formats (PNG, JPG, etc.)
- **Storage**: Custom avatars are stored in the app's documents directory
- **Fallback**: Default avatar icon if no image is selected

### 3. Profile Integration
- **Onboarding**: Profile data is collected during the initial onboarding process
- **Dashboard**: User name and avatar are displayed on the dashboard
- **Persistence**: All profile data is stored locally using SharedPreferences

## Technical Implementation

### Key Components

#### UserProfileScreen
- Full-featured profile management interface
- Form validation for required fields
- Image picker integration for avatar uploads
- Edit/view mode toggle

#### UserProfileService
- Handles all profile data persistence
- Methods for saving/loading profile information
- Avatar path management

#### Dashboard Integration
- Profile icon in top-right corner
- Displays user avatar and name
- Navigates to profile screen on tap

### File Structure
```
lib/
├── screens/
│   ├── user_profile_screen.dart    # Main profile screen
│   ├── dashboard_screen.dart       # Updated with profile integration
│   └── onboarding_screen.dart      # Collects initial profile data
├── services/
│   └── user_profile_service.dart   # Profile data management
└── models/
    └── user_profile.dart           # Profile data model
```

## Usage Instructions

### For Users
1. **Initial Setup**: Complete the onboarding process to set up your profile
2. **Access Profile**: Tap the profile icon on the dashboard
3. **Edit Information**: Tap the edit button to modify your details
4. **Upload Avatar**: 
   - Tap "Edit" mode
   - Tap the camera icon on your avatar
   - Select an image from your device
   - Save changes

### For Developers
1. **Profile Data**: Use `UserProfileService` to access user information
2. **Avatar Display**: Handle both asset-based and file-based avatars
3. **Validation**: Form validation is built into the profile screen
4. **Navigation**: Profile screen returns `true` when data is updated

## Dependencies Used
- `file_picker`: For selecting avatar images
- `path_provider`: For app directory access
- `shared_preferences`: For data persistence

## Future Enhancements
- Cloud storage for avatars
- Profile backup/restore
- Social profile integration
- Profile themes and customization