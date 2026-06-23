#!/usr/bin/env ruby
# frozen_string_literal: true

issue = ARGV[0]

if issue.nil? || issue.strip.empty?
  warn "Usage: #{File.basename($PROGRAM_NAME)} <issue-number>[: <name>]"
  exit 1
end

# Accept either a bare issue number (`59`) or a number with a name
# (`59: Bla`). A trailing colon with no name (`59:`) is rejected.
match = issue.strip.match(/\A(?<number>\d+)(?::\s*(?<name>\S.*?))?\s*\z/)

if match.nil?
  warn "Invalid issue: #{issue.inspect} (expected `<issue-number>` or `<issue-number>: <name>`)"
  exit 1
end

issue_number = match[:number]
issue_name = match[:name]
session_name = issue_name ? "Issue #{issue_number}: #{issue_name}" : "Issue #{issue_number}"

user_prompt = ARGV[1]
system_prompt = \
  "Let's work on issue #{issue_number} with test driven development and subagents.\n" \
  "1. Move the ticket to 'In Progress'.\n" \
  "2. Run `mix deps.get` to fetch the dependencies which are absent on your worktree.\n" \
  "3. Create a fresh branch off of a newly fetched origin/dev. Include the issue number in the branch name, but otherwise name the branch as you usually would.\n" \
  "  - Example: feat12/parse-report-upload\n" \
  "  - Cleanup: delete the worktree branch you were originally on\n" \
  "4. Make fine grained commits along the way.\n" \
  "5. Create a pull request at the end.\n" \
  "6. Finally, move the ticket to 'In Review'.\n" \
  "\n\nOPTIONAL (only if code changed): Final functional review by the user\n\n" \
  "- Open the application for the user to quickly review if everything is fine.\n" \
  "- No need to wait for the application to close, you can stop working and wait for user input.\n\n" \
  "Have fun!"

system_prompt += "\n\n#{user_prompt}" unless user_prompt.nil?
  

exec(
  "claude",
  "-w", "issue#{issue_number}",
  "-n", session_name,
  "--permission-mode", "auto",
  system_prompt
)
