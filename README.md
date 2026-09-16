# Kedis

**Kedis by EkzD.dev** is a local-first Android task manager built with Flutter.

Kedis is designed to keep task capture lightweight while eventually helping surface active tasks that have gone too long without acknowledgement. The current application already provides the reliable checklist foundation; Kedis V1 will extend that foundation with categories, acknowledgement, stale-task detection, and restrained reminder pings.

## Status

The existing task foundation is implemented. The Kedis V1 organization and reminder features described below are planned and are **not implemented yet**.

### Implemented now

- Create and view tasks
- Edit task titles
- Complete and uncomplete tasks
- Delete tasks and undo relevant task actions
- Keep active tasks in creation order and completed tasks in reverse completion order
- Persist tasks locally in SQLite
- Display and complete tasks from an Android home-screen widget
- Keep application and widget task state synchronized
- Reload task state when the application resumes
- Use System, Light, or Dark appearance in the application and widget

### Planned for Kedis V1

- User-created, color-coded task categories
- A lightweight default location such as Inbox for uncategorized tasks
- Task acknowledgement that is separate from completion
- Stale-task detection derived from acknowledgement or meaningful task activity
- Restrained local reminder notifications for stale tasks
- Category-aware quick capture without making basic task creation cumbersome

Kedis V1 does not require due dates for stale-task reminders.

## Kedis V1 non-goals

Budget or transaction tracking, financial accounts or recommendations, AI/LLM features, cloud synchronization, user accounts, Google Sign-In, Google Calendar integration, collaboration, a web application, iOS-specific functionality, recurring tasks, complex priority systems, tags, subtasks, and mandatory due dates are outside the active Kedis V1 scope.

## Tech stack

- Flutter and Dart
- Native Android widget code in Kotlin
- SQLite through `sqflite` and Android SQLite APIs
- `shared_preferences` for the application appearance preference

Development currently targets Android. Core task management is offline-first and requires no backend.

## Compatibility note

The public product is Kedis, but the existing authoritative SQLite filename remains `dewwit.db`. This is intentional: renaming or migrating the database is outside this product-rename task and must not be done casually because both Flutter and the native widget depend on it.

## Run

```bash
flutter pub get
flutter doctor
flutter devices
flutter run
```

## Validation

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

## Project documentation

- `docs/PRODUCT.md` — Kedis product scope and V1 direction
- `docs/ARCHITECTURE.md` — implemented architecture and compatibility boundaries
- `docs/BACKLOG.md` — implemented foundation, planned V1 work, and later ideas
- `AGENTS.md` — instructions for coding agents working in this repository

## Development principle

Kedis should stay fast to open, fast to capture into, and easy to understand. Reliability and maintainability take priority over adding feature quantity or speculative architecture.
