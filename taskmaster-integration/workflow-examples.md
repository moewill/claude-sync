# Task Master Workflow Examples

Common workflows and usage patterns for Task Master AI integrated with Claude Code agents.

## Daily Development Workflows

### 1. Starting a New Work Session

```bash
# Check current project status
task-master list

# Get next available task
task-master next

# View detailed task information
task-master show 1

# Start working on the task
task-master set-status --id=1 --status=in-progress
```

### 2. Feature Development Workflow

**Step 1: Create PRD**
```bash
# Create PRD file
touch tasks/prd-user-authentication.md
```

**Step 2: Generate Tasks**
```bash
# Parse PRD to generate tasks
task-master parse-prd tasks/prd-user-authentication.md

# Analyze complexity
task-master analyze-complexity --research

# Expand complex tasks
task-master expand --id=1 --research
```

**Step 3: Implementation Loop**
```bash
# Work on tasks sequentially
task-master next                                    # Get next task
task-master show 1.1                               # View subtask details
task-master set-status --id=1.1 --status=in-progress  # Start work

# [Implement the feature using Claude Code agents]

task-master update-subtask --id=1.1 --prompt="Completed JWT implementation, tests passing"
task-master set-status --id=1.1 --status=done      # Mark complete
```

## Multi-Agent Workflows

### 1. React + FastAPI Development

**Backend Development**
```bash
# Start with API tasks
task-master next --filter="API"
task-master show 2

# Use FastAPI agent for implementation
# [Claude Code with fastapi-coding-agent]

task-master set-status --id=2 --status=done
```

**Frontend Development**
```bash
# Move to frontend tasks
task-master next --filter="React"
task-master show 7

# Use React agent for implementation
# [Claude Code with reactcoding-agent]

task-master set-status --id=7 --status=done
```

### 2. Infrastructure + Application Workflow

**Infrastructure Setup**
```bash
task-master show 12  # Deployment task
task-master expand --id=12  # Break into infrastructure subtasks

# Use Pulumi agent for infrastructure
# [Claude Code with pulumi-coding-agent]
```

**Application Deployment**
```bash
# After infrastructure is ready
task-master set-status --id=12.1 --status=done
task-master next  # Get next deployment subtask
```

## Task Management Patterns

### 1. Complex Task Breakdown

```bash
# For large, complex tasks
task-master show 5
task-master expand --id=5 --research --force

# View the generated subtasks
task-master list --parent=5

# Work through subtasks systematically
for subtask in 5.1 5.2 5.3; do
    task-master show $subtask
    task-master set-status --id=$subtask --status=in-progress
    # [Implement]
    task-master set-status --id=$subtask --status=done
done
```

### 2. Dependency Management

```bash
# Add dependencies between tasks
task-master add-dependency --id=3 --depends-on=2

# Validate dependency graph
task-master validate-dependencies

# View tasks ready to work on (no blocking dependencies)
task-master list --ready
```

### 3. Parallel Development

```bash
# Create separate branches for parallel work
git checkout -b feature/auth-system
task-master set-status --id=1 --status=in-progress

# In another terminal/worktree
git checkout -b feature/ui-components
task-master set-status --id=7 --status=in-progress
```

## Advanced Workflows

### 1. Multi-Phase Project Management

**Phase 1: Core Features**
```bash
task-master parse-prd tasks/prd-core-features.md --tag=phase1
task-master list --tag=phase1
```

**Phase 2: Advanced Features**
```bash
task-master parse-prd tasks/prd-advanced-features.md --tag=phase2 --append
task-master list --tag=phase2
```

**Work on specific phases**
```bash
task-master next --tag=phase1
```

### 2. Research and Implementation Separation

**Research Phase**
```bash
# Add research tasks
task-master add-task --prompt="Research best practices for JWT implementation" --research
task-master add-task --prompt="Evaluate authentication libraries" --research

# Complete research
task-master set-status --id=13 --status=done
```

**Implementation Phase**
```bash
# Update implementation tasks based on research
task-master update-task --id=1 --prompt="Use Auth0 library based on research findings"
```

### 3. Code Review Integration

```bash
# Mark task as ready for review
task-master set-status --id=1 --status=review

# After review feedback
task-master update-subtask --id=1.1 --prompt="Address review feedback: add input validation"
task-master set-status --id=1 --status=in-progress

# Final completion
task-master set-status --id=1 --status=done
```

## Integration with Git Workflows

### 1. Feature Branch Workflow

```bash
# Start feature branch
git checkout -b feature/task-1-database-models
task-master set-status --id=1 --status=in-progress

# Regular commits with task references
git commit -m "feat: add Task model (task 1.1)"
git commit -m "feat: add Priority enum (task 1.2)"

# Complete and merge
task-master set-status --id=1 --status=done
git checkout main
git merge feature/task-1-database-models
```

### 2. Pull Request Integration

```bash
# Create PR with task context
gh pr create --title "Complete Task 1: Database Models" \
  --body "$(task-master show 1 --format=markdown)"

# Reference in commits
git commit -m "Complete task 1.3: Add Alembic migrations

Resolves task 1.3 from Task Master.
Migration includes proper indexes for optimization."
```

## Testing Workflows

### 1. Test-Driven Development with Tasks

```bash
# Break down into test and implementation subtasks
task-master expand --id=2 --prompt="Split into TDD subtasks: tests first, then implementation"

# Typical breakdown:
# 2.1: Write unit tests for Task CRUD
# 2.2: Implement Task CRUD to pass tests
# 2.3: Write integration tests
# 2.4: Add error handling

# Work through TDD cycle
task-master set-status --id=2.1 --status=in-progress
# [Write tests]
task-master set-status --id=2.1 --status=done

task-master set-status --id=2.2 --status=in-progress
# [Implement to pass tests]
task-master set-status --id=2.2 --status=done
```

### 2. Quality Assurance Workflow

```bash
# Add QA tasks after implementation
task-master add-task --prompt="Manual testing of authentication flow" --depends-on=1
task-master add-task --prompt="Performance testing of API endpoints" --depends-on=2

# QA cycle
task-master next --filter="testing"
task-master update-subtask --id=14 --prompt="Found edge case with expired tokens"
task-master add-task --prompt="Fix expired token handling" --depends-on=14
```

## Reporting and Analytics

### 1. Progress Reporting

```bash
# Generate progress report
task-master complexity-report

# View completion statistics
task-master list --stats

# Export task data
task-master export --format=csv --output=progress-report.csv
```

### 2. Time Tracking Integration

```bash
# Start time tracking when beginning work
task-master set-status --id=1 --status=in-progress
# [Log start time externally]

# Update with time estimates
task-master update-subtask --id=1.1 --prompt="Estimated 2 hours, actual 3 hours. Complexity was higher due to schema constraints"
```

## Custom Workflows

### 1. Documentation-First Development

```bash
# Add documentation tasks first
task-master add-task --prompt="Write API documentation for Task endpoints"
task-master add-task --prompt="Create user guide for task management features"

# Make implementation depend on documentation
task-master add-dependency --id=2 --depends-on=15
```

### 2. Security-First Development

```bash
# Add security review tasks
task-master add-task --prompt="Security review of authentication implementation"
task-master add-task --prompt="Penetration testing of API endpoints"

# Add security dependencies
task-master add-dependency --id=11 --depends-on=16  # Testing depends on security review
```

## Team Collaboration Workflows

### 1. Task Assignment

```bash
# Add assignee information to tasks
task-master update-task --id=1 --prompt="Assign to backend team lead for database expertise"
task-master update-task --id=7 --prompt="Assign to frontend developer for React components"
```

### 2. Handoff Management

```bash
# Mark tasks ready for handoff
task-master set-status --id=1 --status=ready-for-handoff
task-master update-subtask --id=1 --prompt="Database models complete, ready for API team to implement endpoints"

# Next team picks up
task-master set-status --id=2 --status=in-progress
```

These workflows demonstrate the flexibility of Task Master AI when integrated with Claude Code agents, enabling structured development processes while maintaining the power of automated implementation.