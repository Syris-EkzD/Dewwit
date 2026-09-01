# Dewwit Product Specification

## Product

**Name:** Dewwit

**Platform:** Android

**Type:** Personal checklist / to-do application

---

## Purpose

Dewwit is a lightweight personal checklist designed around fast task creation and convenient task completion.

The main differentiating requirement is a useful Android home-screen widget that allows the user's current checklist to remain accessible without constantly opening the full application.

Dewwit should prioritize convenience and simplicity over having a large number of productivity features.

---

# Version 1

## Status

Dewwit V1 is complete and has been manually validated on a real Android
device.

## Goal

Deliver a small but genuinely usable Android checklist application.

V1 proves the complete core experience before additional productivity features are considered.

---

## Core User Experience

A user should be able to:

1. Open Dewwit.
2. See their current checklist.
3. Add a task.
4. See the new task represented with a checkbox.
5. Check a task when it is completed.
6. Uncheck a task if necessary.
7. Delete a task.
8. Close the application.
9. Reopen the application without losing their checklist.
10. Add a Dewwit widget to their Android home screen.
11. See current tasks from the home-screen widget.
12. Interact with task completion from the widget where technically practical.

---

## Example

```text
Dewwit

☐ Finish FBA activity
☐ Buy groceries
☑ Review networking

                         +
```

The home-screen widget should provide a similarly simple checklist-oriented experience.

---

# Functional Requirements

## Task Creation

The user can create a task.

Minimum required task information:

* Task title

An empty task should not be saved.

---

## Task List

The main screen displays saved tasks.

Each task should have a checkbox indicating its completion state.

---

## Task Completion

The user can:

* Mark an incomplete task as completed.
* Restore a completed task to incomplete.

The completion state must persist after the application closes.

---

## Task Deletion

The user can remove a task.

The exact interaction may be determined during UI implementation provided it remains simple and discoverable.

---

## Persistence

Tasks must remain available after:

* Closing Dewwit.
* Reopening Dewwit.
* Restarting the Android application process.

V1 should function completely offline.

---

# Home-Screen Widget

The Android widget is a core V1 requirement rather than an optional enhancement.

At minimum, the widget must:

* Be placeable on the Android home screen.
* Display Dewwit's current tasks.
* Reflect task changes made inside the application.

The widget supports checking and unchecking tasks directly. Changes made in
the application refresh the widget, and changes made in the widget persist to
the same SQLite database used by the application.

Widget functionality should remain simple.

---

# V1 Non-Goals

The following are explicitly excluded from V1:

* Accounts
* Authentication
* Google Sign-In
* Google Calendar
* Cloud synchronization
* Notifications
* Due-date reminders
* Recurring tasks
* Categories
* Priority levels
* Tags
* Collaboration
* Sharing
* Web version
* iOS version

These features may be considered after V1 works reliably.

---

# V1 Success Criteria

Dewwit V1 meets the agreed success criteria:

* [x] A build can be installed on Android.
* [x] Tasks can be created.
* [x] Tasks appear as checklist items.
* [x] Tasks can be checked and unchecked.
* [x] Tasks can be deleted.
* [x] Task state survives application restarts.
* [x] A Dewwit Android home-screen widget can be added.
* [x] The widget displays saved tasks.
* [x] App and widget state remain synchronized reliably.

A polished visual design is desirable but is not required for V1 completion.

---

# Version 1.1

V1.1 focuses on UI and UX polish. Its settings foundation lets users choose
System, Light, or Dark application appearance and preserves that selection
across launches. The native Android home-screen widget retains its existing
V1 appearance and behavior.
