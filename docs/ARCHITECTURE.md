# Kedis Architecture

## Architecture status

This document describes the architecture that is implemented today. Kedis currently provides the reliable local checklist and Android widget foundation inherited from Dewwit.

Custom categories, task acknowledgement, stale-task calculations, and local reminder scheduling are planned Kedis V1 work but are **not implemented yet**. Their future requirements do not justify a feature-module refactor, new schema fields, or notification infrastructure during the product rename.

---

# System overview

Kedis is a local-first Flutter Android application with a native Android home-screen widget.

```text
┌─────────────────────────┐
│       Flutter UI        │
│                         │
│ Checklist / Task Input  │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│     TaskRepository      │
│                         │
│ CRUD / completion state │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│       SQLite DB         │
│       dewwit.db         │
└────────────┬────────────┘
             │
       ┌─────┴─────┐
       ▼           ▼
┌───────────┐ ┌──────────────┐
│Flutter App│ │Android Widget│
└───────────┘ └──────────────┘
```

There is one authoritative task store. The Flutter application and native widget must not maintain competing copies of task state.

---

# Platform and identity

Primary platform: Android

Application framework: Flutter

Application language: Dart

Native widget language: Kotlin

Flutter package name: `kedis`

Android namespace/application ID: `dev.ekzd.kedis`

Android-specific Kotlin code implements the home-screen widget, direct widget task completion, native widget theming, and direct access to the same SQLite database used by Flutter.

---

# Current domain model

The implemented Task model remains intentionally small:

```text
Task
├── id: int
├── title: String
├── isCompleted: bool
├── createdAt: DateTime
└── completedAt: DateTime?
```

No category ID, acknowledgement timestamp, stale flag, due date, notification metadata, or other future field exists yet.

Additional domain fields should be introduced only when the corresponding Kedis V1 feature is deliberately implemented and its migration behavior has been designed.

---

# Flutter presentation and task flow

The Flutter application currently handles:

- Loading and displaying tasks.
- Inline task capture.
- Inline task-title editing.
- Completion and uncompletion.
- Deletion and supported undo flows.
- Active/completed presentation and ordering.
- Settings navigation.
- Lifecycle-driven task reload when the app resumes.

`TaskRepository` separates SQLite persistence from Flutter UI code. The current scale does not justify a larger state-management or feature-module framework.

Task mutations follow the existing flow:

```text
User action
    │
    ▼
TaskRepository mutation
    │
    ▼
Native widget refresh request
    │
    ▼
Reload tasks into Flutter UI
```

Do not add architectural layers solely to prepare for hypothetical later functionality.

---

# Application settings and theme

Flutter's `ThemeData`, `ColorScheme`, and `ThemeMode` provide System, Light, and Dark appearance from centralized definitions under `lib/theme`.

A small `ThemeController` owns the active mode. `ThemePreferenceStore` persists the Flutter preference using `shared_preferences`.

The native Android widget cannot consume Flutter `ThemeData` directly. Kedis therefore mirrors only the stable `system`, `light`, or `dark` mode through the existing platform channel and stores it in a widget-owned Android preference before refreshing installed widgets.

The platform channel identifier remains `dewwit/widget` intentionally. It is an internal protocol key rather than public branding, and changing both sides provides no user benefit during this rename.

The native preference store name remains `dewwit_widget_preferences` for the same compatibility reason. Public classes, resources, logs, and labels use Kedis names.

---

# Persistence

SQLite is the authoritative task store.

Flutter accesses SQLite through `sqflite`. The native Android widget opens the same database through Android SQLite APIs.

The database filename remains:

```text
dewwit.db
```

This is an intentional compatibility value. The product rename does not rename or migrate the database.

Current schema version: 2

```text
tasks
├── id INTEGER PRIMARY KEY AUTOINCREMENT
├── title TEXT NOT NULL
├── is_completed INTEGER NOT NULL
├── created_at INTEGER NOT NULL
└── completed_at INTEGER NULL
```

Completion is stored as `0` or `1`. Creation and completion timestamps use epoch milliseconds. `completed_at` is cleared when a task returns to active.

Current ordering is shared conceptually by Flutter and the widget:

1. Active tasks first, in creation/ID order.
2. Completed tasks after active tasks, newest completion first.
3. Legacy completed rows without `completed_at` follow timestamped completions safely.

The product rename must not change this schema or ordering behavior.

---

# Android home-screen widget

The native widget uses `AppWidgetProvider`, `RemoteViewsService`, and `RemoteViews`.

Application-side flow:

```text
Flutter changes a task
        │
        ▼
SQLite is updated
        │
        ▼
Platform channel requests widget refresh
        │
        ▼
Native widget rereads dewwit.db
```

Widget-side completion flow:

```text
User taps widget task
        │
        ▼
Explicit broadcast to KedisWidgetProvider
        │
        ▼
KedisTaskDatabase updates dewwit.db
        │
        ▼
Widget collection refreshes
        │
        ▼
Flutter rereads data when app resumes
```

The widget broadcast action uses the current Android identity: `dev.ekzd.kedis.TOGGLE_TASK`.

---

# Planned Kedis V1 architecture work

Categories, acknowledgement, stale-task derivation, and local reminders will require a separate architecture/implementation task. That future work should decide, based on concrete requirements:

- Category persistence and safe deletion semantics.
- How uncategorized/Inbox tasks are represented.
- Which task interactions update acknowledgement/activity timestamps.
- How staleness thresholds are calculated without treating stale state as a permanent flag.
- How local notifications are scheduled, summarized, throttled, and cancelled.
- How the native widget exposes categories without duplicating application state.

None of those decisions are implemented by the product rename.

---

# Networking and authentication

Current Kedis task management requires no backend, remote API, user account, or network connection.

Cloud synchronization, authentication, Google integrations, collaboration, and AI functionality are outside Kedis V1 scope.

---

# Security

Current data is ordinary local task and appearance-preference information. No passwords, API keys, remote credentials, or authentication tokens should exist in the application.

Secrets must never be committed to the repository.

---

# Architectural principle

Keep Kedis proportional to what is actually implemented. Prefer explicit Flutter/native boundaries, one authoritative task store, small focused files, and understandable code over speculative abstractions.
