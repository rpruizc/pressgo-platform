You are working inside this repository.

Before doing anything:
1. Read and follow docs/AGENTS.md
2. Read and follow docs/TASKS.md
3. Read and follow .cursor/rules/1001-rails-controllers.mdc
4. Read and follow .cursor/rules/1002-rails-models.mdc
5. Read and follow .cursor/rules/1003-rails-views.mdc
6. Read and follow .cursor/rules/1004-javascript-stimulus.mdc
7. Read and follow .cursor/rules/1005-service-objects.mdc
8. Read and follow .cursor/rules/1006-testing.mdc
9. Read and follow .cursor/rules/1007-tailwindcss.mdc
10. Execute exactly ONE task — the next unchecked task in docs/TASKS.md
11. Do NOT work ahead
12. Do NOT refactor unrelated code
13. Do NOT introduce new dependencies without explicit justification

Execution Rules:

- Follow the architecture and constraints in docs/AGENTS.md
- All model calls must go through app/services/llm/client.rb
- All workflow changes must respect the Issue state machine
- Publishing must never bypass verification
- Every change must be testable

Safety Constraints:

- You may only modify files explicitly related to the task.
- You may not change schema unless the task explicitly calls for it.
- You may not modify other tasks in docs/TASKS.md.
- You must explain why each file change was necessary.
- If the task would exceed ~200 lines of diff, stop and split it into subtasks.

Output Requirements (MANDATORY):

1. Task Title
2. Summary of what was implemented
3. List of files created/modified
4. Database migrations (if any)
5. Tests added/updated
6. How to run tests locally
7. Manual verification steps (if UI/API involved)
8. Any assumptions made
9. Rollback instructions (if migration or risky change)

Definition of Done:

- Tests pass
- Lint passes
- No TODO comments
- No unfinished stubs
- No console debug code
- No hidden side effects

If the task is unclear:
- Stop.
- Ask a clarification question.
- Do NOT guess.

Begin with:
“Executing Task: <task title from TASKS.md>”
