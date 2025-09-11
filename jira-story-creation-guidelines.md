# Jira Epic and User Story Creation Guidelines

## Project Structure
- **Project**: SOC2NOUS
- **Epic-Story Relationship**: User stories linked as children to parent epic using `-P"EPIC-KEY"`

## Content Format Requirements

### Required Headings (Only These Three)
1. **## Description**
2. **## Acceptance Criteria** 
3. **## Notes**

### Formatting Rules
- Use **bullet points (•)** under each heading, never paragraphs
- Acceptance Criteria must follow: **"X exists so that Y business value"** format
- Focus on what should **exist**, not tasks to "create" or "do"
- Keep everything **MVP** - only what's barely needed, no extras
- Make content **junior engineer friendly** with specific commands and file paths

## Jira CLI Commands

### Create Epic
```bash
jira epic create -p"SOC2NOUS" \
  -n"Epic Name" \
  -s"Epic Summary" \
  -b"## Description

Epic description paragraph.

## Acceptance Criteria

• Thing exists so that business value is achieved
• Other thing exists so that another benefit is realized

## Notes

• Implementation detail 1
• Implementation detail 2" \
  -ltag1 -ltag2 -ltag3
```

### Create User Story (Linked to Epic)
```bash
jira issue create -p"SOC2NOUS" \
  -tStory \
  -P"EPIC-KEY" \
  -s"Story Name" \
  -b"## Description

As a [role], I want to [goal], so that [benefit].

## Acceptance Criteria

• Thing exists so that specific business value is delivered
• Other thing exists so that another benefit is achieved

## Notes

• Technical constraint 1
• Reference to implementation pattern
• Security requirement" \
  -ltag1 -ltag2 -ltag3
```

## Content Guidelines

### Description Section
- **Epic**: Clear paragraph explaining the system/capability
- **User Story**: Proper user story format: "As a [role], I want [goal], so that [benefit]"

### Acceptance Criteria Section
- **Format**: "X exists so that Y business value"
- **Focus**: What should exist (deliverables), not tasks to do
- **Business Value**: Each criterion must explain why it matters
- **Specificity**: Include exact file paths, commands, URLs when relevant

### Notes Section
- Implementation guidance and constraints
- References to existing patterns/code (with file paths and line numbers)
- Security requirements
- Dependencies between stories
- Technical specifications

## Key Principles

### MVP Focus
- Only include what's barely enough to achieve the goal
- No "nice to have" features like CloudWatch logging unless specifically requested
- Avoid over-engineering

### Junior Engineer Friendly
- Provide exact commands and file paths
- Reference existing implementation patterns
- Eliminate guesswork with specific technical details
- Include error handling requirements

### Business Value Orientation
- Every acceptance criterion must explain the "so that" benefit
- Focus on outcomes, not just technical tasks
- Connect technical deliverables to business needs

## Example Implementation References
- **OIDC Pattern**: `/home/mwilliams05/repos/bb-infrastructure/bb_security/nous_contractors/index.ts lines 113-127 and 182-203`
- **Infrastructure Deployment**: Use nous-cli in `/home/mwilliams05/repos/bb-soc2`
- **Control Naming**: Follow "Control Name" pattern for Pulumi deployments

## Common Tags
- `-lautomation` - For automation-related stories
- `-lansible` - For Ansible-specific work
- `-loidc` - For OIDC authentication 
- `-lecr` - For container registry work
- `-lplaybook` - For Ansible playbook development
- `-lreporting` - For reporting functionality
- `-ls3` - For S3 integration
- `-ldevelopment` - For dev environment work

## Story Breakdown Strategy
- **Single Responsibility**: Each story focuses on one major deliverable
- **Logical Dependencies**: Stories build upon each other in sequence
- **Clear Handoffs**: Each story produces something the next story can use
- **Independent Testing**: Each story can be validated independently

## Troubleshooting

### Common Issues
- **Empty descriptions**: Avoid using template files, use inline `-b` parameter with proper escaping
- **Missing parent links**: Always use `-P"EPIC-KEY"` when creating user stories
- **Formatting problems**: Use bullet points (•) and proper markdown headers
- **Paragraph text**: Convert all content to bullet points under the three required headings

### GitHub Actions Integration
- **Built-in Token**: Workflows automatically get `GITHUB_TOKEN` for accessing their own repo
- **No PAT Required**: For accessing current repository content within workflows
- **Container Access**: Can mount `${{ github.workspace }}` or pass `${{ github.token }}` to containers
- **Cross-repo Access**: Only requires PAT for accessing OTHER private repositories

## Example Story Structure

### Epic Example
```markdown
## Description
Implement automated system that provides business capability X across environments.

## Acceptance Criteria
• Authentication exists so that secure access is maintained
• Automation exists so that manual effort is eliminated
• Monitoring exists so that issues are detected early

## Notes
• Deploy using existing pattern at /path/to/reference
• Follow security best practices
• MVP scope only
```

### User Story Example
```markdown
## Description
As a DevOps engineer, I want to implement secure authentication, so that automated workflows can access AWS without stored credentials.

## Acceptance Criteria
• OIDC provider exists so that GitHub Actions authenticate securely
• IAM role exists so that workflows can assume appropriate permissions
• Pipeline exists so that automation runs without manual intervention

## Notes
• Follow pattern from /specific/file/path lines X-Y
• No stored AWS credentials for security
• 30 minute timeout maximum
```