# Kedis

**Kedis by EkzD.dev** is a local-first Android task manager built with Flutter.

Kedis keeps task capture lightweight while organizing tasks into persistent categories. The Android home-screen widget remains a fast global checklist surface across categories.

## Status

The checklist foundation and Kedis V1 category system are implemented. Task acknowledgement, stale-task detection, and reminder notifications remain planned and are **not implemented yet**.

### Implemented now

- Create, edit, complete, uncomplete, and delete tasks
- Undo supported completion and deletion actions
- Preserve active/completed ordering
- Persist tasks locally in SQLite
- User-created, color-coded task categories
- Built-in Inbox for zero-friction capture and migrated legacy tasks
- Category cards with active-task counts and compact previews
- Full task lists inside categories
- Create tasks directly in the current category
- Move existing tasks between categories without changing task state
- Safely delete custom categories by moving their tasks to Inbox
- Android home-screen widget showing tasks across all categories
- Complete and uncomplete tasks from the widget
- App/widget synchronization and lifecycle reload behavior
- System, Light, and Dark appearance in the application and widget

### Planned for Kedis V1

- Task acknowledgement separate from completion
- Stale-task detection derived from acknowledgement or meaningful activity
- Restrained local reminder notifications for stale tasks

Kedis V1 does not require mandatory due dates.

## Kedis V1 non-goals

Budget or transaction tracking, financial accounts or recommendations, AI/LLM features, cloud synchronization, user accounts, Google Sign-In, Google Calendar integration, collaboration, a web application, iOS-specific functionality, recurring tasks, complex priority systems, tags, subtasks, and mandatory due dates are outside the active Kedis V1 scope.

## Tech stack

- Flutter and Dart
- Native Android widget code in Kotlin
- SQLite through `sqflite` and Android SQLite APIs
- `shared_preferences` for application appearance preference

Development currently targets Android. Core task management is offline-first and requires no backend.

## Category behavior

Inbox is a durable system category. Quick capture from the home screen creates tasks in Inbox, while capture inside a category assigns that category automatically. Inbox cannot be renamed or deleted.

Deleting a custom category never deletes its tasks. Kedis moves those tasks to Inbox before removing the category.

The home screen shows category cards with active-task counts and up to three active-task previews. Completed tasks remain available inside each category but do not clutter the home preview.

## Widget behavior

The Android widget remains category-agnostic for Kedis V1. It reads the same authoritative SQLite database and continues to display tasks across all categories using the existing task ordering semantics.

## Compatibility note

The public product is Kedis, but these internal compatibility identifiers intentionally remain unchanged:

- SQLite database filename: `dewwit.db`
- Flutter/native widget channel: `dewwit/widget`
- Native widget theme preferences: `dewwit_widget_preferences`

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

Kedis should stay fast to open, fast to capture into, and easy to understand. Reliability and maintainability take priority over feature quantity or speculative architecture.
