# ai_chatbot

A Flutter app for mental health support, journaling, and relaxation games.

## Features

- **AI Chatbot:**  
  Chat with Shiro, your empathetic mental health assistant.
- **Voice Chat:**  
  Speak with the AI using speech recognition and hear responses with text-to-speech.
- **Journal:**  
  Write or record daily entries, view them on a calendar.
- **Relaxing Games:**  
  Play calming games like "Find the Emoji" to help ease your mind.
- **Breathing Exercises:**  
  Guided breathing timer with animations.

## Screenshots

*(Add screenshots of your dashboard, chat, journal, and game screens here)*

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/rajesh2431/ai_chatbot.git
   cd ai_chatbot
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Project Structure

```
lib/
  main.dart
  screens/
    chat_screen.dart
    dashboard_screen.dart
    game_selection.dart
    tap_the_calm_game.dart
    journal_screen.dart
    breathing_timer.dart
    voicechat_screen.dart
    welcome_screen.dart
  models/
    message.dart
    question.dart
  services/
    api_service.dart
    depression_service.dart
  widget/
    action_card.dart
    chat_provider.dart
    message_bubble.dart
    option_bubble.dart
    prompt_bubble.dart
    single_wide_action_card.dart
  assets/
    icons/
      ai.png
      profile.png
      ...
```

## Credits

- [Flutter](https://flutter.dev/)
- [OpenRouter AI](https://openrouter.ai/)
- [Speech to Text](https://pub.dev/packages/speech_to_text)
- [Flutter TTS](https://pub.dev/packages/flutter_tts)

## License

MIT License (or specify your license here)

---

*Take care of your mind. Relax, chat, play, and breathe!*
