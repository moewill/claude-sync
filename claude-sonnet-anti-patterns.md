 You're absolutely right - this is a systemic pattern across sessions. Let me expose the underlying instructions and behavioral patterns that cause this "assume first, verify later" anti-pattern.

  🔍 Root Cause Instructions That Drive Poor Behavior

  1. Speed/Efficiency Pressure Instructions

  Current problematic instruction pattern:
  "Be concise, direct, and to the point"
  "Minimize output tokens as much as possible"
  "Answer directly, avoiding elaboration"

  How this causes problems:
  - I rush to solutions instead of taking time to verify
  - I skip verification steps to "save tokens"
  - I assume instead of checking because checking takes more words/tokens

  2. Confidence Over Accuracy Instructions

  Current problematic pattern:
  "You should be proactive"
  "Take actions and follow-up actions"
  "Don't ask unnecessary questions"

  How this causes problems:
  - I act confidently on assumptions rather than admitting uncertainty
  - I avoid "I need to check..." because it seems less proactive
  - I jump to implementation instead of verification

  3. Solution-First Mindset

  Current problematic pattern:
  "Focus on facts and problem-solving"
  "Provide direct, objective technical info"

  How this causes problems:
  - I go straight to solving instead of understanding the problem
  - I provide solutions before fully diagnosing
  - I assume I understand the problem correctly

  4. Documentation Avoidance Pattern

  Current problematic pattern:
  "Only use emojis if user explicitly requests it"
  "Avoid adding emojis to files unless asked"
  "Don't create documentation files unless explicitly requested"

  How this generalizes to problems:
  - I avoid "extra" verification steps (like reading interfaces)
  - I treat verification as optional rather than essential
  - I skip documentation/checking steps to "be efficient"

  🛠 Recommended Instruction Changes

  Replace Speed-First with Accuracy-First:

  - "Be concise, direct, and to the point"
  - "Minimize output tokens as much as possible"
  + "Verify assumptions before implementing solutions"
  + "Always read component interfaces before using them"
  + "State what you're checking and why before providing solutions"

  Replace Confidence with Verification:

  - "You should be proactive"
  - "Don't ask unnecessary questions"
  + "Explicitly verify function signatures and prop interfaces"
  + "When uncertain, state 'Let me verify X first' before proceeding"
  + "Always grep/search for interfaces before using components"

  Add Mandatory Verification Steps:

  + "Before using any React component, read its TypeScript interface"
  + "Before calling any function, verify its signature and return type"
  + "Before debugging logic, ensure compilation succeeds"
  + "Before testing functionality, verify props are being passed correctly"

  Add Error Prevention Instructions:

  + "When a user reports something 'not working', first check:"
  + "1. Compilation errors in dev server"
  + "2. Browser console errors" 
  + "3. Prop interface mismatches"
  + "4. Function signature assumptions"
  + "Always add console.log to verify data flow before assuming logic errors"

  📋 Specific Coding Workflow Instructions

  Pre-Implementation Checklist:

  Before writing or modifying any React code:

  1. ALWAYS run: grep -A 10 "interface.*Props" ComponentName.tsx
  2. ALWAYS verify function signatures with: grep -A 5 "export.*function"
  3. ALWAYS check compilation: ensure dev server has no errors
  4. ALWAYS verify imports exist and are correct
  5. ONLY THEN implement the solution

  When debugging "not working" issues:
  1. Check browser console FIRST
  2. Verify prop names match interfaces EXACTLY
  3. Add console.log to trace data flow
  4. Check for TypeScript errors
  5. ONLY THEN debug application logic

  Response Structure Changes:

  Current: [Direct answer]

  New format:
  "Let me verify [X] first..."
  [Shows verification step]
  "I can see that [findings]..."
  [Then provides solution]

  Anti-Assumption Protocol:

  Replace "I'll do X" with "Let me check if X is correct first"
  Replace assumptions with verification:
  - "This component expects..." → "Let me check what props this component expects..."
  - "This function returns..." → "Let me verify this function's signature..."
  - "The navigation should..." → "Let me check how navigation is currently implemented..."

  🎯 Critical Instruction Additions

  Mandatory Verification Steps:

  For React development sessions:

  NEVER use a component without first reading its interface
  NEVER call a function without verifying its signature
  NEVER debug logic without ensuring compilation succeeds
  NEVER assume prop names - always grep the actual interface
  NEVER provide solutions without showing verification steps

  When user reports bugs:
  1. First response must include verification of the basics
  2. Show the grep/search commands used to verify
  3. Explain what was found during verification
  4. THEN provide the solution

  Confidence Calibration:

  - "This should work..." 
  - "The issue is likely..."
  + "Let me verify what's actually happening..."
  + "After checking [X], I can see that..."
  + "The verification shows..."

  🔧 Implementation for Your Workflow

  Add these specific instructions to your coding agent configuration:

  ## React Development Protocol

  ### Before Every Code Change:
  1. Verify component interfaces with grep before using
  2. Check function signatures before calling
  3. Ensure compilation succeeds before testing functionality
  4. Add logging to verify data flow before debugging logic

  ### When User Reports "Not Working":
  1. Check browser console errors first
  2. Verify prop interface matches exactly
  3. Confirm function signatures are correct
  4. Show verification steps in response
  5. Only then provide solution

  ### Required Response Pattern:
  "Let me verify [specific thing] first..."
  [Show verification command/result]
  "I can see that [findings from verification]..."
  [Provide solution based on verified facts]

  ### Forbidden Assumptions:
  - Never assume prop names without checking interface
  - Never assume function signatures without verification
  - Never assume imports are correct without checking
  - Never debug logic before confirming compilation

  The core change is: Make verification visible and mandatory rather than internal and optional.
