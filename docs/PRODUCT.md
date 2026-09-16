# Kedis Product Specification

## Product identity

**Name:** Kedis

**Producer:** EkzD.dev

**Primary platform:** Android

**Type:** Local-first personal task manager

Kedis may be described as **Kedis by EkzD.dev** where producer identity is useful. The producer name does not need to appear throughout the application UI.

## Purpose

Kedis should make capturing and managing tasks lightweight while helping surface tasks that have gone too long without acknowledgement.

The application should still feel useful as a simple checklist. Opening Kedis, creating a task, checking a task, or viewing a category must not become heavy just because more organizational features are introduced.

The Android home-screen widget remains a core part of the product rather than an optional side feature.

---

# Current implemented foundation

The current Kedis codebase is the renamed continuation of the working Dewwit task foundation. The following behavior is implemented today and must remain reliable while Kedis V1 expands:

- Create tasks.
- View active and completed tasks.
- Edit task titles inline.
- Complete and uncomplete tasks.
- Delete tasks.
- Undo completion, uncompletion, and deletion where currently supported.
- Persist task data locally in SQLite.
- Keep active tasks in creation order.
- Keep completed tasks in reverse completion order, with safe handling for legacy rows without completion timestamps.
- Add an Android home-screen widget.
- Display task state from the same authoritative SQLite database in the widget.
- Complete and uncomplete tasks from the widget.
- Refresh the widget after application-side task mutations.
- Reload application task state after returning to the app so widget-side changes appear.
- Select System, Light, or Dark application appearance.
- Mirror the selected appearance to the native Android widget.

The existing checklist behavior is not a temporary prototype. It is the stable base that planned Kedis V1 features must extend without making ordinary task capture cumbersome.

---

# Kedis V1 planned scope

The features in this section are approved Kedis V1 product goals, but **they are not implemented yet**. Documentation must not describe them as working behavior until their implementation has been completed and verified.

## Custom categories

Kedis V1 will support multiple user-defined task categories. Example categories may include School, Programming, Daily Bullshit, Personal, or Shopping, but examples must never become hard-coded categories.

Users should eventually be able to:

- Create categories.
- Rename categories.
- Delete categories safely.
- Assign colors to categories.
- Create and manage tasks within categories.

A lightweight default location such as Inbox may hold tasks that have not yet been organized.

When a user is already viewing a category, creating a task should naturally place that task in the current category without requiring extra fields or screens.

## Task acknowledgement

Kedis will distinguish acknowledgement from completion.

Acknowledgement means, conceptually:

> I know this task is still here and I still intend to deal with it.

A reminder should not force the user to mark a task complete just to stop treating it as forgotten. Kedis V1 should eventually track when an active task was last acknowledged or otherwise meaningfully interacted with.

## Stale tasks

Kedis V1 will identify active tasks that have gone an appropriate amount of time without acknowledgement or meaningful interaction.

Staleness should be derived state, not a permanent manually maintained flag. A task may be visually marked as stale or needing attention when appropriate.

Mandatory due dates are not required for this system.

## Reminder pings

Kedis should eventually send local notifications for stale tasks that may have been forgotten.

The goal is useful resurfacing, not notification spam. Reminder behavior should favor restrained summaries or appropriately paced reminders instead of emitting one notification for every stale task.

## Ease of use

Ease of use is a Kedis V1 requirement, not merely visual polish.

- Opening Kedis should feel lightweight.
- Quick capture should require minimal interaction.
- The basic task flow should remain understandable without configuring advanced fields.
- Category context should reduce work rather than add work.
- Future stale-task and reminder controls should not turn task creation into a form.

When product goals conflict, preserving a fast and dependable core checklist is preferred over adding complexity merely because another task manager has it.

---

# Kedis V1 non-goals

The following are outside active Kedis V1 implementation scope:

- Budget tracking.
- Financial accounts.
- Transaction tracking.
- Financial recommendations.
- AI or LLM functionality.
- Cloud synchronization.
- User accounts.
- Google Sign-In.
- Google Calendar integration.
- Collaboration.
- Web application functionality.
- iOS-specific functionality.
- Recurring tasks.
- Complex priority systems.
- Tags.
- Subtasks.
- Mandatory due dates.

These may be reconsidered later if real usage creates a concrete need. Do not design current architecture around them in advance.

---

# Product principles

## Reliability before feature quantity

Existing task and widget behavior must stay dependable as Kedis grows.

## Local-first operation

Core task management must remain useful without an internet connection.

## Fast interaction

Common actions such as opening the app, capturing a task, acknowledging a task, and completing a task should require minimal effort.

## Progressive complexity

New functionality should not prevent someone from using Kedis as a straightforward checklist.

## Real usage drives development

Observed friction from day-to-day use may legitimately change priorities. Planned features are direction, not an excuse to overbuild.

## Architecture follows implemented requirements

Categories, acknowledgement, stale detection, and reminders will require deliberate implementation work later. Their future presence does not justify adding unused domain fields, modules, services, dependencies, or abstractions during unrelated tasks.
