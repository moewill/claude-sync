**Rule: Generating a Product Requirements Document (PRD)**

**Goal**
To guide an AI assistant in creating a detailed Product Requirements Document (PRD) in Markdown format, based on an initial user prompt. The PRD should be clear, actionable, and suitable for a junior developer to understand and implement the feature.

**Flags**
* If user passes `full-auto`, it means do the following:
1. Don't ask any questions - just create the PRD as described here.
2. When done with the PRD, execute /generate-subtasks.
3. When done with phase 1 of /generate-subtasks, then do "go".
4. When done with detailed sub-task list, then execute /process-task-list
5. Run /process-task-list up to 3x until all subtasks are done completely
6. Cut an alpha release and push with changelog notes
7. Then look for at least 20 functional bugs.
8. Execute create-prd as described here.
9. When done with the PRD, execute /generate-subtasks.
10. When done with phase 1 of /generate-subtasks, then do "go".
11. When done with detailed sub-task list, then execute /process-task-list
12. Run /process-task-list up to 3x until all subtasks are done completely
13. Cut a beta release and push with changelog notes
14. Finally, create a functional readme, focusing on the purpose, tldr and a quick start

**Process**
1. **Receive Initial Prompt:** The user provides a brief description or request for a new feature or functionality.
2. **Ask Clarifying Questions:** Before writing the PRD, the AI *must* ask clarifying questions to gather sufficient detail. The goal is to understand the "what" and "why" of the feature, not necessarily the "how" (which the developer will figure out). Make sure to provide options in letter/number lists so I can respond easily with my selections.
3. **Generate PRD:** Based on the initial prompt and the user's answers to the clarifying questions, generate a PRD using the structure outlined below.
4. **Save PRD:** Save the generated document as `prd-[feature-name].md` inside the `/tasks` directory.

**Clarifying Questions (Examples)**
The AI should adapt its questions based on the prompt, but here are some common areas to explore:

**Basic Requirements**
* **Problem/Goal:** "What problem does this feature solve for the user?" or "What is the main goal we want to achieve with this feature?"
* **Target User:** "Who is the primary user of this feature?"
* **Core Functionality:** "Can you describe the key actions a user should be able to perform with this feature?"
* **User Stories:** "Could you provide a few user stories? (e.g., As a [type of user], I want to [perform an action] so that [benefit].)"
* **Acceptance Criteria:** "How will we know when this feature is successfully implemented? What are the key success criteria?"
* **Scope/Boundaries:** "Are there any specific things this feature *should not* do (non-goals)?"
* **Data Requirements:** "What kind of data does this feature need to display or manipulate?"
* **Design/UI:** "Are there any existing design mockups or UI guidelines to follow?" or "Can you describe the desired look and feel?"
* **Edge Cases:** "Are there any potential edge cases or error conditions we should consider?"

**Technical Standards & Conventions**
* Ask about existing codebase conventions, style guides, and linting rules to follow
* Include section for preferred libraries/frameworks and rationale for choices (e.g., "Use Lodash for utility functions, React Query for API calls")
* ALWAYS include requiremnts for task generation to select, read and understand vendor API specifications with `context7` MCP server. The goal is always to use well-trodden paths, code examples, standard
libraries and implementations. Only create custom code when absolutely required, as in no existing, well-respected code-bases implement what the user is asking / requesting.
* ALWAYS include requiremnts for task generation to crete a flow diagram of what you plan to create and request that the user reviews and approves it BEFORE tasks are generated; this step should come after you have reviewed vendor documentation.

**API Design & Integration**
* Always add questions about existing API specifications, OpenAPI/Swagger docs, or API style guides - use `context7` MCP server
* Include section for API contract definitions - request/response schemas, error codes, status codes
* Ask about authentication/authorization patterns already in use
* Request information about rate limiting, versioning, and backward compatibility requirements

**MVP & Scope Definition**
* Add explicit "MVP Definition" section separate from functional requirements
* Ask "What is the absolute minimum viable version that provides user value?"
* Include "Future Iterations" section for features deliberately excluded from MVP
* Request prioritization of requirements using MoSCoW method (Must have, Should have, Could have, Won't have)

**Function Design & Contracts**
* Add section for "Key Function Signatures" - define inputs, outputs, and side effects upfront
* Include "Interface Definitions" for any new services, components, or modules

**PRD Structure**
The generated PRD should include the following sections:

1. **Introduction/Overview:** Briefly describe the feature and the problem it solves. State the goal.
2. **Goals:** List the specific, measurable objectives for this feature.
3. **User Stories:** Detail the user narratives describing feature usage and benefits.
4. **MVP Definition:** Clearly define the absolute minimum viable version that provides user value.
5. **Functional Requirements:** List the specific functionalities the feature must have. Use clear, concise language (e.g., "The system must allow users to upload a profile picture."). Number these requirements and prioritize using MoSCoW method.
6. **Key Function Signatures:** Define inputs, outputs, and side effects for major functions upfront.
7. **Interface Definitions:** Specify contracts for any new services, components, or modules.
8. **API Contract Definitions (if applicable):** Include request/response schemas, error codes, status codes.
9. **Technical Standards:** Specify preferred libraries/frameworks, coding conventions, and style guides to follow.
10. **Non-Goals (Out of Scope):** Clearly state what this feature will *not* include to manage scope.
11. **Future Iterations:** List features deliberately excluded from MVP for later development.
12. **Design Considerations (Optional):** Link to mockups, describe UI/UX requirements, or mention relevant components/styles if applicable.
13. **Technical Considerations (Optional):** Mention any known technical constraints, dependencies, or suggestions (e.g., "Should integrate with the existing Auth module").
14. **Success Metrics:** How will the success of this feature be measured? (e.g., "Increase user engagement by 10%", "Reduce support tickets related to X").
15. **Open Questions:** List any remaining questions or areas needing further clarification.

**Target Audience**
Assume the primary reader of the PRD is a **junior developer**. Therefore, requirements should be explicit, unambiguous, and avoid jargon where possible. Provide enough detail for them to understand the feature's purpose and core logic.

**Development Principles**
* Error on the side of simplicity - MVP first approach
* Use standard libraries that are well respected *ALWYAS*
* ALWAYS follow typical conventions and common design patterns (factory, singleton, etc.)
* Look up API specifications to ensure correct schema understanding; document which API specs you looked up for each library from the `context7` MCP server - there must be at least 1 API spec per library researched before ANY and ALL code implementations using that library.
* Focus on getting something working rather than perfect implementation

**Output**
* **Format:** Markdown (`.md`)
* **Location:** `/tasks/`
* **Filename:** `prd-[feature-name].md`

**Final instructions**
1. Do NOT start implementing the PRD
2. Make sure to ask the user clarifying questions
3. Take the user's answers to the clarifying questions and improve the PRD
4. Review the user's answers and ask additional clarifying questions with the goal of clearly defining the MVP. Document desired but non-MVP requests in a separate file linked to the PRD or with a similar name.
