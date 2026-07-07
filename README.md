# LifeOS

LifeOS is a Flutter application aimed at personal productivity and life management, designed with a dynamic, futuristic, and cyberpunk aesthetic.

## Features

The application is structured using a feature-based architecture to maintain scalability and organization:

- **Dashboard**: A customizable hub for an overview of your productivity.
- **Focus**: Integrated timers and screen time limit management to help you stay concentrated.
- **Notes**: A rich markdown editor supporting links and attachments for organized thoughts and project planning.
- **Onboarding**: A seamless entry flow for setting up your profile, goals, and themes.
- **Search**: Quick and powerful search capabilities across your notes, focus items, and overall workspace.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Language**: Dart
- **State Management**: `provider` package
- **Storage**: `flutter_secure_storage` for securely handling user preferences and data.

## Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Ensure your Dart SDK constraint supports `>=3.11.0`)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd life_os
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Development

- **Formatting**: The project relies on standard Dart formatting. Run `dart format lib/` before committing.
- **Static Analysis**: Maintain code quality by running `flutter analyze`.

## Architecture

The source code is organized primarily under `lib/features/`, isolating business logic, UI, and services for each core module (dashboard, focus, notes, search, onboarding). This approach ensures components are decoupled and maintainable.
