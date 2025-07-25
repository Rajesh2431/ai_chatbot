# Project Structure

## Root Directory Organization

```
lib/                    # Main application code
├── main.dart          # App entry point with splash screen
├── screens/           # UI screens and pages
├── models/            # Data models and entities
├── services/          # API and business logic services
├── providers/         # State management providers
├── widget/            # Reusable UI components
└── assets/            # Static resources (icons, videos, sources)

android/               # Android platform configuration
ios/                   # iOS platform configuration
web/                   # Web platform configuration
test/                  # Unit and widget tests
```

## Core Architecture Patterns

### Screen-Based Navigation
- Each major feature has its own screen in `screens/`
- Main screens: `dashboard_screen.dart`, `chat_screen.dart`, `journal_screen.dart`
- Game screens: `game_selection.dart`, `tap_the_calm_game.dart`
- Utility screens: `breathing_timer.dart`, `voicechat_screen.dart`

### Service Layer
- `api_service.dart` - OpenRouter AI integration
- `depression_service.dart` - Mental health assessment logic

### State Management
- Provider pattern for global state
- `journal_entries_provider.dart` - Journal data management
- `chat_provider.dart` - Chat state management

### Models
- `message.dart` - Chat message structure
- `journal_entry.dart` - Journal entry data model
- `question.dart` - Assessment question structure

### Reusable Components
- `action_card.dart` - Dashboard action buttons
- `message_bubble.dart` - Chat message display
- `option_bubble.dart` - Interactive chat options

## Asset Organization

```
lib/assets/
├── icons/             # App icons and UI graphics
├── videos/            # Splash screen animations
└── sources/           # Additional resources
```

## Naming Conventions

- **Files**: snake_case (e.g., `chat_screen.dart`)
- **Classes**: PascalCase (e.g., `ChatScreen`)
- **Variables**: camelCase (e.g., `apiService`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_KEY`)

## Key Architectural Principles

- Separation of concerns between UI, business logic, and data
- Provider pattern for state management
- Service classes for external API integration
- Reusable widget components for consistent UI