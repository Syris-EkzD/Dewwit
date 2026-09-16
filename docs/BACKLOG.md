# Kedis Backlog

This file separates working behavior from approved Kedis V1 work and later ideas. An item being listed does not mean it is already implemented.

## Implemented foundation

- [x] Create and view tasks
- [x] Edit task titles
- [x] Complete and uncomplete tasks
- [x] Delete tasks
- [x] Undo supported completion and deletion actions
- [x] Preserve active/completed task ordering
- [x] Persist tasks locally in SQLite
- [x] Android home-screen widget
- [x] Complete and uncomplete tasks from the widget
- [x] Synchronize application and widget through the same task database
- [x] Reload task state when the application resumes
- [x] System, Light, and Dark appearance support
- [x] Mirror application appearance to the native widget

## Planned Kedis V1

These items are active product direction but are not implemented yet.

- [ ] User-created task categories
- [ ] Rename categories
- [ ] Safe category deletion behavior
- [ ] User-selected category colors
- [ ] Create tasks within the current category
- [ ] Lightweight Inbox/default location for uncategorized tasks
- [ ] Task acknowledgement separate from completion
- [ ] Track appropriate acknowledgement or meaningful activity for active tasks
- [ ] Derive stale-task attention state from activity/acknowledgement
- [ ] Provide restrained local reminder notifications for stale tasks
- [ ] Preserve low-friction quick capture as categories and reminders are added

Kedis V1 stale-task reminders do not require mandatory due dates.

## Outside Kedis V1

Potential future work may be reconsidered after real use creates a concrete need. It is not active Kedis V1 implementation scope.

- Budget tracking
- Financial accounts
- Transaction tracking
- Financial recommendations
- AI or LLM functionality
- Cloud synchronization
- User accounts
- Google Sign-In
- Google Calendar integration
- Collaboration
- Web application
- iOS-specific functionality
- Recurring tasks
- Complex priority systems
- Tags
- Subtasks
- Mandatory due dates
- Additional advanced widget configuration beyond requirements created by Kedis V1

## Rule

Do not implement planned or future items during an unrelated task simply because they appear here. Move one requirement at a time into an explicit implementation task, preserve the working checklist foundation, and update the documentation when behavior actually changes.
