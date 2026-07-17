---
name: user-preference
description: "Use at BOOT and whenever a user preference is discovered. Loads and updates .devin/user_profile.md to remember language, model tier, project type, and custom red lines."
---

# Skill: user-preference

> Remember the user, not just the task.

## Trigger
- At BOOT, after reading `loop_state.md` and `knowledge_distill.md`.
- Whenever the user states a preference (language, model, style, "never do X").
- When the user corrects the agent or rejects an approach.

## When to run
At BOOT and after any explicit preference statement.

## How

1. Read `.devin/user_profile.md` if it exists.
2. If it does not exist, create it from the template:
   ```yaml
   ---
   language: "zh|en|auto"
   preferred_model_tier: "cheap|mid|high"
   project_type: "unknown"
   communication_style: "caveman|verbose|balanced"
   never_read: []
   custom_red_lines: []
   updated_at: ""
   ---
   ```
3. Update fields based on the current session:
   - `language` from user input.
   - `preferred_model_tier` from model choices.
   - `project_type` from repo analysis (e.g., python, web, godot).
   - `communication_style` from user feedback.
   - `never_read` from files the user says to skip.
   - `custom_red_lines` from user-imposed constraints.
4. Keep the file < 2KB. Merge, don't append blindly.
5. Write `updated_at`.

## Output
```
## User profile
- loaded from: .devin/user_profile.md
- updated: <fields>
- active constraints: <list>
```

Caveman compact. No prose. Use the profile to shape every response.
