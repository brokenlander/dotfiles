-- Basic TODO comments examples
-- TODO: This is a standard todo comment
-- FIXME: This needs to be fixed urgently
-- BUG: There's a bug here that needs attention
-- FIXIT: This functionality is broken and needs repair
-- ISSUE: Known issue that should be addressed

-- HACK: This is a temporary workaround
-- XXX: Problematic code that needs attention
-- WARNING: Be careful with this section
-- WARN: This might cause problems later

-- PERF: This could be optimized for better performance
-- OPTIM: Candidate for optimization
-- PERFORMANCE: This is a performance bottleneck
-- OPTIMIZE: This should be made more efficient

-- NOTE: Important information about the code
-- INFO: Additional context or explanation

-- TEST: Test-related comment
-- TESTING: This needs testing
-- PASSED: Test passing note
-- GOOD: Looking good
-- OK: Ok
-- STALLION: Top form
-- FAILED: Test failing note

--[[ 
  TODO: This is a multiline todo comment
  that spans across multiple lines
  and can contain detailed information
  about what needs to be done.
]]

--[[ FIXME: Another multiline comment
  explaining a complex issue
  that requires fixing
]]

-- You can also use TODO comments in inline code
local function example() -- TODO: Refactor this function
  local x = 10 -- HACK: Temporary value, should be calculated
  return x -- NOTE: Return value should be validated
end

-- Alternative format without colon (requires config change)
-- TODO This works if you change the pattern in the config
-- FIXME No colon here either

-- Custom keywords (if configured)
-- REVIEW: Code that needs review
-- IDEA: Potential improvement
-- QUESTION: Something that needs clarification
-- REFACTOR: Code that needs restructuring

-- Comments with additional context
-- TODO(username): Assigned todo
-- FIXME(high): High priority fix
-- BUG(#123): References issue number

-- TODO comments with dates
-- TODO(2025-05-01): Implement this feature by May
-- FIXME(Q2): Fix this in the second quarter

--[[
  Multiple TODO tags in a single comment block
  TODO: First task to do
  FIXME: Something to fix
  NOTE: Important information
]]
