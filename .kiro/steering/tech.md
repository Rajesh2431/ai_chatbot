# Technology Stack

## Framework & Language
- **Flutter** (Dart SDK ^3.8.1) - Cross-platform mobile development
- **Material Design 3** with custom theming

## Key Dependencies

### State Management
- `provider: ^6.1.0` - State management pattern

### AI & API Integration
- `http: 1.1.0` - HTTP requests to OpenRouter AI API
- `flutter_dotenv: ^5.0.2` - Environment variable management

### Audio & Voice
- `speech_to_text: ^7.1.0` - Voice input recognition
- `flutter_tts: ^4.2.3` - Text-to-speech output
- `just_audio: ^0.10.4` - Audio playback
- `flutter_sound: ^9.2.13` - Audio recording
- `audioplayers: ^5.2.1` - Additional audio functionality

### UI & UX
- `google_fonts: ^6.1.0` - Typography
- `curved_navigation_bar: ^1.0.6` - Custom navigation
- `animated_emoji: ^3.2.1` - Emoji animations
- `table_calendar: ^3.2.0` - Calendar widget

### Storage & Files
- `shared_preferences: ^2.2.2` - Local data persistence
- `path_provider` - File system access
- `file_picker: ^10.2.0` - File selection

### Utilities
- `intl: ^0.20.2` - Internationalization
- `permission_handler: ^12.0.1` - Device permissions

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run development
flutter run

# Build for release
flutter build apk --release
flutter build ios --release

# Update app icons
flutter pub run flutter_launcher_icons:main

# Clean build
flutter clean
flutter pub get
```

## Environment Setup

- Create `.env` file with `OPENROUTER_API_KEY`
- Ensure proper permissions for microphone and storage access
- Configure platform-specific settings in android/ios folders