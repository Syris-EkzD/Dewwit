# Dewwit — Agent Instructions

## Project Overview

Dewwit is a lightweight Android checklist application built with Flutter.

Its primary purpose is to provide a fast and convenient personal to-do list, with particular emphasis on an Android home-screen widget.

The project should remain simple, maintainable, and offline-first.

---

## Current Development Target

Only implement features that belong to Dewwit V1 unless explicitly instructed otherwise.

### Dewwit V1

V1 must allow the user to:

* Create a task.
* View tasks as checklist items.
* Check and uncheck tasks.
* Delete tasks.
* Keep tasks after closing and reopening the application.
* Add a Dewwit widget to the Android home screen.
* View current checklist items from the widget.
* Complete tasks from the widget where technically practical.

---

## Out of Scope

Do not implement the following unless explicitly requested:

* User accounts
* Google Sign-In
* Google Calendar integration
* Cloud synchronization
* Backend APIs
* Notifications
* Reminders
* Recurring tasks
* Categories
* Tags
* Priorities
* Collaboration
* Web application
* iOS support

Future requirements belong in `docs/BACKLOG.md`.

Do not implement backlog items simply because the architecture could support them.

---

## Engineering Principles

1. Prefer the simplest solution that satisfies the current requirements.
2. Avoid premature abstraction.
3. Avoid speculative architecture for features that do not exist yet.
4. Introduce dependencies only when they solve a concrete problem.
5. Keep business logic separate from presentation where doing so improves maintainability.
6. Keep files and classes reasonably small and focused.
7. Prefer clear names over clever names.
8. Preserve Android as the primary target.
9. Keep Dewwit usable without an internet connection.
10. Do not silently expand product scope.

---

## Existing Code

The repository may contain prototype Flutter code created while learning Flutter.

Before modifying existing code:

1. Inspect the repository.
2. Identify what is still useful.
3. Remove obsolete prototype code only when appropriate.
4. Do not rewrite working code without a reason.
5. Preserve a runnable application throughout refactoring whenever practical.

---

## Workflow

For substantial work:

1. Read this file.
2. Read the relevant files under `docs/`.
3. Inspect the existing implementation.
4. Explain the intended approach before making major architectural changes.
5. Implement only the requested scope.
6. Validate the result.
7. Summarize what changed.

For small and obvious changes, implementation may proceed directly.

---

## Validation

After modifying Flutter or Dart code, run where applicable:

```bash
dart format .
flutter analyze
flutter test
```

If tests do not exist for the affected functionality, state that clearly.

Do not claim validation succeeded unless the command was actually run successfully.

---

## Dependencies

Before adding a new package:

* Explain what problem the dependency solves.
* Prefer established and actively maintained packages.
* Avoid adding a package when the same requirement can be reasonably implemented with existing dependencies or platform functionality.
* Do not add backend, authentication, cloud, analytics, or telemetry dependencies during V1 unless explicitly requested.

---

## Git Practices

Keep changes focused.

Do not:

* Modify unrelated files.
* Commit generated build output.
* Commit secrets or credentials.
* Make unrelated refactors while implementing a feature.

Prefer commits that represent one logical change.

Recommended examples:

```text
chore: prepare Dewwit project structure
feat: add local task persistence
feat: implement checklist interface
feat: add Android home screen widget
fix: synchronize widget task state
```

---

## Documentation

Update project documentation when a change affects:

* Product scope
* Architecture
* Setup instructions
* Important technical decisions

Do not allow the implementation and documentation to contradict each other.

---

## Product Authority

The documentation defines the current agreed product direction.

AI agents may recommend alternatives and identify problems, but should not independently change product scope or architectural direction without clearly explaining the proposed change first.
