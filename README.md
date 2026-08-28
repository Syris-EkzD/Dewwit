# Dewwit

Dewwit is a lightweight Android checklist application built with Flutter.

Its goal is simple: make creating and completing everyday tasks quick, especially through a convenient Android home-screen widget.

## Status

Dewwit V1 is complete and has been manually tested on a real Android device.

## V1 Features

* Create checklist tasks
* Check and uncheck tasks
* Delete tasks
* Keep tasks in offline SQLite storage
* Display current tasks in an Android home-screen widget
* Check and uncheck tasks directly from the widget
* Keep the application and widget synchronized through the same task database

## Tech Stack

* Flutter
* Dart
* Native Android widget code in Kotlin
* SQLite through `sqflite` and Android's SQLite APIs

No backend or cloud service is required for V1.

## Requirements

Development currently targets Android.

You will need:

* Flutter SDK
* Android SDK
* Android emulator or physical Android device

## Run

Install dependencies:

```bash
flutter pub get
```

Check the development environment:

```bash
flutter doctor
```

List available devices:

```bash
flutter devices
```

Run Dewwit:

```bash
flutter run
```

## Validation

Format Dart code:

```bash
dart format .
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build a debug Android APK:

```bash
flutter build apk --debug
```

## Project Documentation

Detailed project documentation is available under `docs/`.

* `docs/PRODUCT.md` — current product requirements and scope
* `docs/ARCHITECTURE.md` — architecture and technical boundaries
* `docs/BACKLOG.md` — potential future features

AI coding agents should also read:

* `AGENTS.md`

## Development Philosophy

Dewwit should remain small and focused.

Dependencies and architectural complexity should only be introduced when they solve an actual requirement.
