PROJECT NAME: system_design_oracle

META-INSTRUCTIONS:

<Read it all before acting. Ask about anything unclear, contradictory or
 underspecified — before starting and mid-build. Ask in the question widget
 (AskUserQuestion): related questions batched, concrete options, your
 recommendation first. Plain text only if the widget isn't available.>

<Don't expand scope. Anything not listed here is a proposal, including changes
 to this file — propose it, don't do it.>

<Prefer doing over describing: run the code, write the files, test it.>

<Always in scope, no proposal needed: when it goes on GitHub, a README that is
 easy to read at a glance — a line on what it is, then clear visuals
 (screenshots, a diagram or a chart), then links. Everything else goes in
 linked files: docs/INSTRUCTIONS.md (setup, run, use) and
 docs/FILE-STRUCTURE.md (what's where). Also a small unobtrusive feedback tab
 if what you're building is an application rather than a script.>

<If what you're building is an application, build it as a Mac app first; the
 website comes after, as its own step.>

<Name things the way a person would say them — "Goal Tracker", not
 goal_tracker — for the app, its windows, titles, files people open, repo
 descriptions and README headings. When you create the GitHub repo, name it
 with no "_" or "-": one word or joined words, e.g. GoalTracker.>

<Finish by listing every deliverable: path, what it is, how to check it works.>

<Git rules (no Claude attribution, never commit .claude/) are in
 ~/.claude/CLAUDE.md and apply on their own — nothing to repeat here.>

<Keep the changelog at the bottom current.>

CONTEXT:

figure out a system design oracle to help anyone learn system design across the stack (ml, gpu, inference, operating system, autonomous vehicles) etc etc. should go several layers deep, but also be easily accessable to read

DELIVERABLES:

a mac application with this information.

OPEN QUESTIONS / ASSUMPTIONS:

<Agent fills in: what it guessed, what it decided without asking.>

Asked and answered (2026-10-02):
- Oracle type: a curated, offline library shipped inside the app (no API key, no chat).
- Depth: 4 layers per topic: 1 The Gist, 2 The Picture (plain English + diagram),
  3 How It Works (parts, flow, trade-offs, numbers), 4 Expert Depth (failure modes,
  real systems, interview questions).
- Domains: the five named plus distributed systems, networking, storage, data and
  security, so 10 domains and 56 topics.
- Design problems (added after the user's AV trajectory-prediction example): 10 worked,
  end-to-end answers, one per domain, read in the same 4 layers. The user's prompt is
  used word for word.
- GitHub: private repo SystemDesignOracle. The feedback tab opens a pre-filled GitHub
  issue in the browser.

Decided without asking:
- Built as a SwiftUI Swift package plus a script that bundles "System Design
  Oracle.app" (universal, ad-hoc signed, macOS 14+), not an Xcode project.
- Content is JSON (one file per domain, one per problem), checked by
  scripts/validate_content.py against docs/TOPICS.md and docs/PROBLEMS.md.
- Content was written from model knowledge with no web check. Approximate figures are
  marked with "~". The newest figures are the ones worth spot-checking: 2025–26 hardware
  (B300, MI355X, TPU Ironwood, Trainium2, Rubin/HBM4, DRIVE Thor), Waymo ride and
  simulated-mile counts, Tesla Cortex size, Cloudflare post-quantum share, and M-Trends
  and IBM 2025 breach figures.
- Diagrams are simple left-to-right step flows drawn natively, not images.
- Extras that support the brief: search across every layer, related-topic links with
  Back, hidden answers on interview questions, depth remembered between launches, a
  generated app icon.
- Website (built 2026-10-02 after the user asked): a static site (HTML, CSS and JS, no
  framework) in website/. It reads the same content JSON as the app, merged by
  scripts/build_site.py, and has the same features as the app. A GitHub Actions workflow
  deploys it to GitHub Pages; the site is public even though the repo is private. Web keys
  are 1–4, /, [ and j/k instead of ⌘ shortcuts.
- The feedback tab (app and site) opens issues on the private repo, so only people with
  access to the repo can file them.

CHANGELOG:

- 2026-10-02 — created
- 2026-09-15 — added meta-instruction: built-out applications include a small feedback tab
- 2026-09-15 — added meta-instruction: no "Claude" attribution in commits, PRs, or branches
- 2026-09-16 — added meta-instruction: always include a README when adding to GitHub
- 2026-09-16 — changed meta-instruction: ask clarifying questions in the question widget
- 2026-09-17 — added meta-instructions: Claude never a contributor; never commit .claude/
- 2026-09-26 — compressed the meta-instructions and every field prompt; git rules moved to the global instruction file
- 2026-09-27 — added meta-instruction: applications are built as a Mac app first, then a website
- 2026-09-28 — folded inputs, instructions, constraints, deliverables and done criteria into one free-form CONTEXT
- 2026-09-28 — changed meta-instruction: a README on GitHub always includes a visual
- 2026-09-28 — added meta-instruction: name things like a person would, never snake_case
- 2026-09-28 — changed meta-instruction: README leads with visuals; instructions live in a linked guide
- 2026-09-28 — changed meta-instruction: README is visuals and links; details in docs/INSTRUCTIONS.md and docs/FILE-STRUCTURE.md
- 2026-09-29 — changed meta-instruction: GitHub repo names have no "_" or "-"
- 2026-10-02 — added a DELIVERABLES field after CONTEXT
- 2026-10-02 — built v1.0 of the Mac app: 10 domains, 56 topics, 10 worked design problems, 4 reading layers; filled in OPEN QUESTIONS / ASSUMPTIONS
- 2026-10-02 — built the website version (same content and features) with GitHub Pages deploy
