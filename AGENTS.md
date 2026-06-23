# Agent Instructions
## Project knowledge (`.claude/`)

The `.claude/` docs hold only what the code, git history, and the issue/PR do
**not** already capture. The guiding rule: a doc goes stale in proportion to how
much it restates a source of truth, so keep each kind small and in its lane.

- **Before implementing**, orient yourself: read `.claude/architecture.md`, the
  relevant `.claude/design/<area>.md` intent, and skim `.claude/decisions/` for
  any ADR touching the area. Check the issue/PR for prior plans or research.
- `.claude/architecture.md` — a single short **map**: where the major pieces live
  and the invariants that must hold. It points at code; it never restates it.
  Update it only when the structure or an invariant actually changes — never
  per-feature. If a line just paraphrases code, delete it.
- `.claude/decisions/` — **Architecture Decision Records** for lasting choices
  (`NNNN-<slug>.md`, with `Date` and `Status`). Write one when you make a
  trade-off someone would later question and try to "fix". ADRs are
  **immutable**: never edit an accepted one. If a decision is reversed, add a new
  ADR and set the old one's `Status: Superseded by NNNN`.
- `.claude/design/<area>.md` — **product intent**: what an interface (here, the
  HTTP relay contract and operator-facing behaviour) should do and guarantee, not
  how it's coded. Update when the intent changes. Keep it intent-level;
  implementation belongs in code.
- **Plans and investigations are ephemeral** — they belong on the issue or PR for
  the work they serve, not committed to the repo. If a finding is durable, it
  becomes an ADR or an architecture-map line; otherwise let it live and die with
  the PR.
  - **An investigation always ends with a comment on its issue.** Post the
    recommendation/findings (host, trade-offs, contract, decision) as a comment on
    the issue you investigated, so the conclusion lives with the work. Promote it to
    an ADR or architecture-map line only if it is a lasting choice.
- Maintain documentation links in `.claude/references/documentation.md`, a curated index of canonical docs for the libraries and APIs the project uses.
  - Before researching an external library or API, check this file and `WebFetch` the listed URL instead of searching the web from scratch.
  - When you find a genuinely useful doc page that is not listed, append it (technology, version, URL, one-line note).
  - Keep it links-only — do not vendor documentation copies into the repo.
- When the user tells you something about his preferences, make sure to update your `AGENTS.md` file correspondingly.
  - You must never silently delete content from `AGENTS.md` without explicit user approval.

## Structure

- Pösthörn is a multi-tenant support-mail relay: a supervised Elixir/OTP
  application that accepts an opaque (already end-to-end encrypted) report bundle
  over HTTP and forwards it as an email attachment to a fixed per-tenant
  recipient. It is built on **Bandit + `Plug.Router`** for the endpoint and
  **Swoosh** for the SMTP send path.
- Do not scaffold or initialize the application unless explicitly asked.
- Keep project structure and naming aligned with standard **Mix/OTP**
  conventions once the app is created: code under `lib/`, tests under `test/`,
  runtime configuration in `config/runtime.exs` (read everything from the
  environment), and the project/release definition in `mix.exs`.

## Naming

- Use **language-idiomatic naming**: each language follows the conventions its own
  ecosystem establishes.
  - **Elixir** (`lib/`): `snake_case` for functions, variables, atoms, and file
    names; `CamelCase` for module names and structs. A module file mirrors its
    module path (`Posthoern.Relay.Endpoint` → `lib/posthoern/relay/endpoint.ex`).
    Predicate functions end in `?`, bang variants that raise end in `!`.
  - **Shell / config**: `SCREAMING_SNAKE_CASE` for environment variables read by
    `config/runtime.exs` (e.g. `SMTP_RELAY_HOST`, `BIND_PORT`).
- Only deviate when required by a framework, external API, or established tool
  contract. The standing exceptions in this project:
  - **HTTP wire field names** are a stable contract that every consuming app codes
    against — never rename them. This covers the `multipart/form-data` fields
    (`bundle`, `app_version`, `platform`, …) and the JSON response keys (`ok`,
    `id`, `error`, `max_bytes`, `retry_after`). See the request/response contract
    in the relay design notes.
  - **Tenant registry keys** (the per-app config mapping a token → `{ recipient,
    label, size cap, rate limit }`) are an operator-facing contract shared with
    deployment config — leave their names stable.

## Comments

- A comment states a unit's **intent and contract** — what it guarantees and why —
  not the assumptions a current caller happens to satisfy. If the code does not
  enforce a claim, the comment must not assert it.
- **Do not name a single consumer of a shared or generic unit** (function, plug,
  module, struct) as if it were the only one. Describe what the unit does for *any*
  caller. Name a specific caller only when the code restricts the unit to it, or as
  an explicit, clearly-non-exhaustive example (`e.g. Relay.Endpoint.call/2`).
- **Do not claim a caller, ordering, or environment the code does not enforce**
  ("always called from X", "runs before Y", "only inside the request process").
  State the precondition the unit actually checks instead (e.g. "a missing bundle
  field responds `400`").
- **Do not restate the code.** Skip comments that merely paraphrase the next line;
  prefer the *why* over the *what*. Delete a comment that goes stale the moment the
  code beneath it changes.
- Keep references accurate: a comment that names a function, module, issue, or ADR
  must point at one that exists. Update or remove it when the referent moves.

## Scripts

- Project scripts belong under `scripts/`.
- `scripts/issue.rb` is off limits — never call it. It only generates and launches a new agent session prompt; it is meant for the human to invoke, not for agents to run.
- Linux shell scripts must use a POSIX-compatible shell style unless a script explicitly requires Bash.
- Shell scripts should use strict error handling and keep side effects clear.

## Verification

- Before claiming any work complete, committing, or opening a pull request, you MUST verify the application still builds and runs. Do not skip this, even for changes that look trivial or unrelated.
- Run `mix compile --warnings-as-errors` and `mix test` and confirm both succeed with no errors. This is the minimum bar for "the app still works".
- Keep the code formatted: run `mix format` (and check it in CI with `mix format --check-formatted`).
- When you add, remove, or change a dependency, run `mix deps.get` so it is actually fetched and `mix.lock` is updated, then commit the updated `mix.lock`. Editing `mix.exs` alone is not enough — the build will fail on a clean checkout if the lockfile is not in sync.
- When a change affects runtime behavior (not just compilation), launch the app and confirm it runs. Prefer `./scripts/run_dev.sh` — it sources the gitignored `posthoern.env` so `config/runtime.exs` has the tenant registry and SMTP credentials, then starts the supervised app in an IEx session so you can exercise the endpoint locally.
- Report verification honestly: state the exact command(s) you ran and their outcome. If you could not verify something, say so explicitly rather than implying it passed.

## Commits

- Make sure you're on a new branch, split from `dev` whenever you start working on a new feature.
- Standalone documentation may be committed directly to `dev` and pushed without a branch or PR, at the time you create or change the file. This covers `.claude/` docs (ADRs, design docs, architecture map, references) and any other doc-only file that ships no code (e.g. `AGENTS.md`, `README.md`).
- You may open a pull request against `dev` at any time, as long as the branch is based on `dev`. You don't need to wait for explicit approval to open a PR — opening one is the expected way to surface work for review and merge.
- Always target `dev` as the base branch for pull requests.
- Make fine-granular commits during your work, whenever you feel like you've made a change that warrants a commit.
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for all commit messages.
- Structure messages as `<type>[optional scope]: <description>`, followed by an optional body and optional footer.
- Keep the description a short, imperative summary (aim for ~50 characters).
- Common types:
  - `feat`: a new feature (MINOR in semantic versioning).
  - `fix`: a bug fix (PATCH in semantic versioning).
  - `docs`: documentation-only changes.
  - `style`: formatting/style changes that do not affect behavior.
  - `refactor`: code changes that neither fix a bug nor add a feature.
  - `test`: adding or correcting tests.
  - `build`: changes to build tooling, dependencies, or project version.
  - `chore`: routine maintenance tasks.
- Mark breaking changes by appending `!` after the type/scope (e.g. `feat!:`) or adding a `BREAKING CHANGE:` footer; these correspond to a MAJOR release.

## Development

- Keep changes narrowly scoped to the requested task.
- Prefer explicit, readable automation over clever scripting.
- Avoid adding dependencies, generated files, or project scaffolding until the project setup is requested.
