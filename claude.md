# AI Dev Tasks Global Setup

  # MANDATORY AGENT USAGE RULES

  ## React Development Work
  - **ALWAYS use reactcoding-agent for ANY React code changes** including:
    - Component fixes, updates, or creation
    - Hook modifications
    - Utility function changes affecting React components
    - TypeScript interface updates for React props
    - State management changes

  ## Code Review Protocol
  - **ALWAYS use antireact-code-critique after reactcoding-agent completes work**
  - Maximum 3 iterations between the two agents
  - Complete the review cycle before moving to next task

  ## Exceptions
  - Only skip agents for:
    - Pure configuration files (package.json, tsconfig.json)
    - Non-React utility functions with no component dependencies
    - Documentation-only changes


Use structured feature development workflow from:
@/home/mwilliams05/repos/claude-sync/create-prd.md
@/home/mwilliams05/repos/claude-sync/generate-tasks.md  
@/home/mwilliams05/repos/claude-sync/process-task-list.md

Follow this workflow for complex feature requests:
1. Create PRD with clarifying questions
2. Generate detailed task lists
4. Mark tasks complete and commit when parent tasks finish
5. Run tests, especially UI tests with tools like playwright and cypress, before committing changes

Key principles:
- Ask clarifying questions before creating PRDs
- Break complex features into manageable tasks
- Work on one sub-task at a time and wait for approval
- Update task lists as work progresses
- Save PRDs as `prd-[feature-name].md` in `/tasks/`
- Save task lists as `tasks-prd-[feature-name].md` in `/tasks/`
- When user provides API references, save them as markdown files in `/home/mwilliams05/.claude/` for future retrieval

