# System Design Oracle — Instructions

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15+ or the Xcode command-line tools (for `swift`) — only needed to build
- Python 3 — only needed to build (it runs the content check)

## Build and install

```bash
scripts/build_app.sh
```

This checks every content file, builds a release binary, and writes
`build/System Design Oracle.app`. Open it with Finder or:

```bash
open "build/System Design Oracle.app"
```

To also copy it into `/Applications`:

```bash
scripts/build_app.sh --install
```

The app is ad-hoc signed. If macOS ever refuses to open it, right-click it in Finder and choose **Open**.

### Run during development

```bash
swift run
```

`swift run` reads content straight from `Sources/SystemDesignOracle/Content`, so edits to the JSON
show up on the next launch without rebuilding the `.app`.

## Use

- **Sidebar** — *Design Problems* (worked, end-to-end answers) at the top, then concept topics
  grouped by domain, ordered from the bottom of the stack (operating systems, GPUs) to the top
  (inference, autonomous vehicles). Click a section header to collapse it.
- **Depth (toolbar, ⌘1–⌘4)** — every page reads in four layers:
  1. **The Gist** — one sentence
  2. **The Picture** — plain English and a diagram
  3. **How It Works / The Design** — components, step-by-step flow, trade-offs, numbers to know;
     for problems, requirements, back-of-the-envelope estimates and each stage of the design
  4. **Expert Depth** — subtleties, failure modes, real production systems, interview questions
     (answers stay hidden until you click *Show answer*), and each problem stage's deep dive

  Depth is remembered between launches. *Go deeper* at the end of a page adds the next layer.
- **Search** — the sidebar search looks through every layer, not just titles. Every word must match.
- **Links** — *Related topics* and *Concepts used* jump across domains. Back is ⌘[ or the toolbar
  arrow. **Go ▸ Next / Previous Topic** (⌥⌘↓ / ⌥⌘↑) walks the whole library in order.
- **Feedback** — the small *Feedback* button at the bottom of the sidebar (or **Help ▸ Send
  Feedback…**) opens a pre-filled GitHub issue in your browser. Nothing is sent until you submit it there.

## Add or edit content

1. Topics live in `Sources/SystemDesignOracle/Content/<domain>.json`; design problems in
   `Sources/SystemDesignOracle/Content/problems/<id>.json`. The format is in
   [CONTENT-SCHEMA.md](CONTENT-SCHEMA.md).
2. Add new topic ids to [TOPICS.md](TOPICS.md) and new problems to [PROBLEMS.md](PROBLEMS.md) —
   the checker uses those lists.
3. Check everything:

   ```bash
   python3 scripts/validate_content.py
   ```

4. Rebuild with `scripts/build_app.sh`.

## Screenshots

`swift scripts/window_shot.swift SystemDesignOracle out.png` captures the app's window.
Launch arguments open a given page at a given depth, e.g.

```bash
.build/debug/SystemDesignOracle -open problem:av-trajectory-prediction -depth 3
```

The app icon is drawn by `swift scripts/make_icon.swift`, which writes `Resources/AppIcon.icns`.
