# Dewwit Architecture

## Architecture Status

This document describes the implemented Dewwit architecture. V1 is complete
and has been manually validated on a real Android device. V1.1 adds Flutter
application theme and settings foundations without changing task storage or
the native Android widget.

---

# System Overview

Dewwit is an offline-first Flutter Android application.

No backend is required for V1.

High-level structure:

```text
┌─────────────────────────┐
│       Flutter UI        │
│                         │
│  Checklist / Task Input │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│      Task Logic         │
│                         │
│ Create / Toggle / Delete│
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│     Local Storage       │
│                         │
│ Persistent Task Data    │
└────────────┬────────────┘
             │
       ┌─────┴─────┐
       ▼           ▼
┌───────────┐ ┌──────────────┐
│Flutter App│ │Android Widget│
└───────────┘ └──────────────┘
```

---

# Platform

Primary platform:

```text
Android
```

Application framework:

```text
Flutter
```

Programming language:

```text
Dart
```

Android-specific Kotlin code implements the home-screen widget and its SQLite
access.

---

# Core Domain Model

V1 requires a minimal Task model.

Implemented model:

```text
Task
├── id: int
├── title: String
├── isCompleted: bool
├── createdAt: DateTime
└── completedAt: DateTime?
```

Additional fields should only be introduced when required by an implemented feature.

Do not add fields for hypothetical future functionality.

---

# Presentation Layer

The Flutter application is responsible for:

* Displaying tasks.
* Accepting task input.
* Displaying task completion state.
* Receiving user interaction.
* Presenting deletion controls.

V1 should remain small enough that complex state-management frameworks are unnecessary unless a concrete requirement emerges.

---

# Task Logic

Task operations include:

```text
createTask()
getTasks()
toggleTask()
deleteTask()
```

UI code should not need to understand storage implementation details.

A lightweight `TaskRepository` separates SQLite persistence from the Flutter
UI.

Avoid creating multiple architectural layers purely for architectural appearance.

## Application Settings and Theme

Flutter's standard `ThemeData`, `ColorScheme`, and `ThemeMode` APIs provide a
single theme-aware widget tree for system, light, and dark appearance. Light
and dark theme definitions are centralized under `lib/theme`.

A small `ThemeController` owns the active theme mode independently of the
Settings UI. The stable values `system`, `light`, and `dark` are stored with
`shared_preferences`; missing or invalid values resolve to system mode. These
preferences are separate from the authoritative SQLite task database.

The Settings screen is composed from simple settings sections and items so
new application preferences can be added without changing its overall
structure.

The native Android widget cannot read Flutter's `ThemeData`. After the app
loads or changes its selected theme, a platform channel explicitly mirrors
only the stable `system`, `light`, or `dark` value into a widget-owned native
preference and refreshes installed widgets. This avoids depending on the
internal storage format of the Flutter `shared_preferences` plugin. Flutter's
theme selection remains the user-facing source of truth, and task data remains
exclusively in the shared SQLite database.

---

# Persistence

Dewwit uses a local SQLite database as the authoritative task store.

The Flutter application accesses SQLite through `sqflite`. The native Android
home-screen widget accesses the same database so that the application and
widget do not maintain separate task state.

V1 uses one `tasks` table:

```text
tasks
├── id INTEGER PRIMARY KEY AUTOINCREMENT
├── title TEXT NOT NULL
├── is_completed INTEGER NOT NULL
├── created_at INTEGER NOT NULL
└── completed_at INTEGER NULL
```

Completion is stored as `0` or `1`, and creation time is stored as UTC epoch
milliseconds. Completion time is also stored as UTC epoch milliseconds and is
cleared when a task returns to active. Schema version 2 adds the nullable
`completed_at` column without rewriting existing rows. Active tasks retain
creation order; completed tasks follow in reverse completion order. Legacy
completed rows with no timestamp follow timestamped completions in creation
and ID order.

No remote database is required for V1.

---

# Android Home-Screen Widget

The widget is part of the core system architecture.

The Flutter application and native Android widget cannot be treated as completely independent sources of task state.

There should be one authoritative task state with a reliable mechanism for making relevant data available to the widget.

Conceptual flow:

```text
User modifies task in Flutter
          │
          ▼
Update local task state
          │
          ▼
Request widget refresh
          │
          ▼
Android widget displays new state
```

Widget interaction:

```text
User checks task in widget
          │
          ▼
Update task state
          │
          ▼
Persist change
          │
          ▼
Refresh widget
          │
          ▼
Flutter application reads updated state
```

The V1 widget uses Android's native `AppWidgetProvider`, `RemoteViewsService`,
and `RemoteViews` APIs. Its collection adapter reads the same `dewwit.db`
SQLite database used by `sqflite`; it does not keep a second task store.

Task taps send an explicit broadcast to the widget provider. The provider
toggles the matching SQLite row and invalidates the widget collection. After a
Flutter-side mutation, a small platform channel asks Android to perform the
same collection refresh. The Flutter application reloads tasks when it resumes
so changes made from the home screen are visible when the application opens.

---

# Networking

Dewwit V1 requires no network connection.

```text
Internet → Not required
Backend  → None
API      → None
Cloud DB → None
```

---

# Authentication

None.

---

# Security

V1 stores only ordinary personal checklist information locally.

No passwords, API keys, authentication tokens, or remote credentials should exist in the application.

Secrets must never be committed to the repository.

---

# Architectural Principle

Dewwit should remain proportional to its actual complexity.

The architecture should make V1 easy to understand and maintain without building infrastructure solely for hypothetical future functionality.

Future requirements may justify architectural changes when those requirements actually become part of the product.
