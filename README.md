# Dewwit

Dewwit is a lightweight Android checklist application built with Flutter.

Its goal is simple: make creating and completing everyday tasks quick, especially through a convenient Android home-screen widget.

## Status

Dewwit is currently in V1 development.

## V1 Features

* Create checklist tasks
* Check and uncheck tasks
* Delete tasks
* Offline local persistence
* Android home-screen widget

## Tech Stack

* Flutter
* Dart
* Android
* Local persistence

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
