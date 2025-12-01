# General Guidelines

- Use Japanese in chat. Docs and code comments can be in English depending on context (follow existing style).
- Keep documentation brief. Docs are just high-level concepts (WHAT), not for describing implementation details (HOW). Code are for that.

## Project Structure

- `docs/` contains documentation related to the project.
  - `docs/*.md`: high-level design docs and guidelines. Avoid describing implementation details (code) and decision logs (ADRs) here.
  - `docs/adr/*.md`: Architecture Decision Records (ADRs) documenting key decisions.
- `TODO.md` is a todo-list for tracking tasks that need to be implemented or improved in the project. Finished tasks should be removed.

## Softwre Development

- TDD: Write tests before implementation.
