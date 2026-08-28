# Dewwit Architecture

## Architecture Status

This document defines the architectural boundaries for Dewwit V1.

Specific implementation details may change as the Android home-screen widget implementation is evaluated.

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

Android-specific code may be introduced where required for home-screen widget functionality.

---

# Core Domain Model

V1 requires a minimal Task model.

Conceptually:

```text
Task
├── id
├── title
├── isCompleted
└── createdAt
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

A lightweight repository or equivalent abstraction may be used if it meaningfully separates persistence from the UI.

Avoid creating multiple architectural layers purely for architectural appearance.

---

# Persistence

Dewwit requires reliable local persistence.

The final storage implementation should be selected based on:

1. Simplicity.
2. Reliability.
3. Flutter support.
4. Compatibility with the Android home-screen widget.
5. Ability for the application and widget to remain synchronized.

Potential options may include:

* SQLite
* SharedPreferences/DataStore-style storage
* Another appropriate local persistence mechanism

The storage mechanism should be chosen during implementation rather than assumed prematurely.

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

The exact implementation should be established after evaluating the appropriate Flutter/Android widget integration.

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
