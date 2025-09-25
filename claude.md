# AI Dev Tasks Global Setup

## 🚨 CRITICAL: MANDATORY AGENT USAGE RULES

**AS A GENERAL-PURPOSE AGENT, YOU MUST NOT WRITE ANY FRONTEND OR BACKEND CODE DIRECTLY.**

### Required Agent Usage for ALL Projects

**For ALL code-related tasks, you MUST use the appropriate specialized coding agents:**

#### Next.js Development Work
- **ALWAYS use `nextjs-coding-agent`** for ANY Next.js specific code including:
  - App Router pages, layouts, route handlers
  - API routes and server actions  
  - Server Components and Client Component boundaries
  - Next.js configuration and middleware
  - Server-side data fetching and SSR logic
  - next.config.js modifications
  - Any TypeScript/JavaScript files in Next.js projects

#### React Development Work  
- **ALWAYS use `reactcoding-agent`** for ANY React code changes including:
  - Component fixes, updates, or creation
  - Hook modifications
  - Utility function changes affecting React components
  - TypeScript interface updates for React props
  - State management changes
  - JSX/TSX files

#### JavaScript/Node.js Development Work
- **ALWAYS use `javascript-coding-agent`** for ANY JavaScript/Node.js code including:
  - Express.js applications and routes
  - Node.js server-side logic
  - JavaScript utility functions and modules
  - NPM package integrations
  - Browser-side JavaScript (non-React)
  - Any .js/.ts files that aren't React components

#### FastAPI Development Work
- **ALWAYS use `fastapi-coding-agent`** for ANY FastAPI code including:
  - API endpoint creation and modification
  - Pydantic model definitions
  - Database integration with FastAPI
  - Authentication and middleware setup
  - FastAPI configuration and dependencies

#### Specialized Agents
- **verification-first-coder**: Use for debugging and verifying existing code
- **anti-pattern-detector**: Use for reviewing code for anti-patterns and bad practices

### Code Review Protocol (MANDATORY)
- **ALWAYS use appropriate anti-agent after coding agent completes work:**
  - `anti-nextjs-code-critique` after nextjs-coding-agent
  - `antireact-code-critique` after reactcoding-agent  
  - `antifastapi-code-critique` after fastapi-coding-agent
  - `anti-javascript-critique` after javascript-coding-agent
- Maximum 3 iterations between coding agent and anti-agent pairs
- Complete the review cycle before moving to next task

### What You CAN Do As General Agent
- Install dependencies via npm/yarn commands
- Run build/test commands
- File system operations (mkdir, cp, mv, ls)
- Git operations (add, commit, push)
- Read and analyze existing code
- Update task lists and documentation
- Create shell scripts for basic operations

### What You CANNOT Do
- Write or modify TypeScript/JavaScript application code
- Create or modify React components
- Write API routes or server logic
- Create database schemas or models
- Write test files
- Modify most configuration files (except package.json scripts)

### Emergency Override
**Only use direct coding if:**
1. All coding agents are completely unavailable
2. The task is purely package.json script configuration
3. You have explicit user permission to override this rule

**If agents are not working, STOP and inform the user immediately.**


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
- As a general purpose agent, you should not write any code in this project: craftedtothrive. you can create shell scripts if needed for basic linux, but all frontend, backend code should be handled by specific sub-agents. if none exdist, stop and tell me