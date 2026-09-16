# Kedis — Agent Instructions

## Project overview

Kedis by EkzD.dev is a local-first Android task manager built with Flutter. It is the renamed continuation of the existing Dewwit application.

The current codebase already provides a working checklist, local SQLite persistence, Android home-screen widget interaction, theme/settings behavior, and app/widget synchronization. Kedis V1 will later add categories, acknowledgement, stale-task detection, and restrained reminder notifications.

Reliability, maintainability, and ease of use take priority over feature quantity.

---

## Product-state rule

Always distinguish between:

1. **Implemented foundation** — behavior that exists and must be preserved.
2. **Planned Kedis V1** — approved direction that has not yet been implemented.
3. **Outside Kedis V1** — ideas that must not influence current architecture unless separately approved.

Do not claim a planned feature works merely because it is documented.

---

## Implemented foundation

Unless a task explicitly changes this behavior, preserve:

- Task creation and display.
- Inline task-title editing.
- Completion and uncompletion.
- Deletion.
- Existing undo behavior.
- Current active/completed ordering.
- SQLite persistence.
- Android home-screen widget display and task completion interaction.
- Shared application/widget task state.
- Widget refresh after Flutter-side mutations.
- Task reload when the application resumes.
- System, Light, and Dark application appearance.
- Native widget appearance mirroring.

---

## Planned Kedis V1

The following are product goals, not currently implemented behavior:

- User-created, color-coded categories.
- Safe category rename/deletion flows.
- Category-aware task capture and a lightweight Inbox/default location.
- Task acknowledgement separate from completion.
- Stale-task detection derived from acknowledgement or meaningful activity.
- Restrained local notifications that resurface stale tasks.

Implement these only through an explicit future task. Do not add their database fields, dependencies, services, or architectural layers speculatively.

---

## Outside Kedis V1

Do not implement or design around budget/finance features, AI/LLM features, cloud sync, user accounts, Google Sign-In, Google Calendar, collaboration, web functionality, iOS-specific functionality, recurring tasks, complex priorities, tags, subtasks, or mandatory due dates unless product scope is explicitly changed.

---

## Compatibility boundaries

Some internal values intentionally retain the former Dewwit name. Do not treat these as missed search-and-replace results:

- SQLite database filename: `dewwit.db`
- Flutter/native widget platform channel: `dewwit/widget`
- Native widget theme preference store: `dewwit_widget_preferences`

These values are compatibility details, not public branding. Renaming them requires a deliberate migration task.

Current public/project identity:

- Flutter package: `kedis`
- Android namespace/application ID: `dev.ekzd.kedis`
- Product label: `Kedis`

The repository may still contain generated, inactive non-Android platform scaffolding. Android is the current product target; do not broaden an Android task into desktop, web, or iOS work without a concrete requirement.

---

## Engineering principles

1. Prefer the smallest clear solution that satisfies the active requirement.
2. Do not rewrite working code without a concrete reason.
3. Avoid premature abstraction and speculative architecture.
4. Introduce dependencies only when they solve an implemented requirement.
5. Keep Flutter/native boundaries explicit.
6. Keep the SQLite task store authoritative; do not create duplicate task state.
7. Keep files and classes reasonably small and focused.
8. Preserve comments that explain non-obvious synchronization or compatibility behavior.
9. Do not suppress failures merely to make checks pass.
10. Do not silently expand product scope.
11. Keep task capture and common interactions lightweight.
12. Prefer boring, understandable code over clever code.

---

## Workflow

For substantial work:

1. Read this file and the relevant documents under `docs/`.
2. Inspect the implementation before changing behavior.
3. Identify Flutter, Android widget, persistence, resource, and test dependencies affected by the task.
4. Make the smallest coherent change.
5. Update tests without deleting meaningful coverage to accommodate implementation changes.
6. Run all applicable validation.
7. Search for stale references when a rename or migration is involved and classify intentional compatibility values instead of blindly replacing them.
8. Report exactly what changed and what could not be verified.

Do not use blind repository-wide search-and-replace for identity changes that touch persistence, Android packages, platform channels, resources, or widgets.

---

## Validation

For changes affecting Flutter, Dart, Android identity, or the native widget, run where applicable:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

Also inspect Android package/resource references and search relevant files for stale product identifiers.

If the environment supports runtime testing, smoke-check application launch, task creation, completion, editing, Settings, and the Android widget. Never claim a command or manual check succeeded unless it was actually performed.

---

## Git practices

Keep commits focused and do not commit generated build output, secrets, credentials, or unrelated refactors.

Use Conventional Commit style where practical, for example:

```text
feat: add category management
fix(widget): refresh stale task state
refactor: clarify acknowledgement flow
chore: rename Dewwit to Kedis
```

---

## Documentation authority

`docs/PRODUCT.md` defines current product scope. `docs/ARCHITECTURE.md` describes implemented technical boundaries. `docs/BACKLOG.md` distinguishes implemented behavior, planned Kedis V1 work, and later ideas.

Agents may identify risks and recommend changes, but must not silently turn planned behavior into implemented scope or design architecture for excluded features.
