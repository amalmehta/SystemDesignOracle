# System Design Oracle — File Structure

```
system_design_oracle/
├── README.md                     What it is, screenshots, links
├── system_design_oracle.md       The project brief (spec, open questions, changelog)
├── Package.swift                 Swift package: one macOS executable, macOS 14+
├── Resources/
│   ├── AppIcon.icns              App icon (generated)
│   └── AppIcon.png               1024px icon, used in the README
├── Sources/SystemDesignOracle/
│   ├── App.swift                 App entry, menus & shortcuts, Navigator (selection + back stack),
│   │                             main window, sidebar, home screen
│   ├── ReaderViews.swift         Topic page and Design Problem page, layer by layer
│   ├── Components.swift          Shared pieces: layers, depth picker, diagram + flow layout,
│   │                             cards, trade-off table, hidden-answer questions, related links
│   ├── FeedbackView.swift        Feedback sheet → pre-filled GitHub issue
│   ├── Library.swift             Loads all content JSON, lookup, search
│   ├── Models.swift              Codable types matching docs/CONTENT-SCHEMA.md
│   └── Content/
│       ├── <domain>.json         One file per domain (10), each with its topics
│       └── problems/<id>.json    One file per worked design problem (10)
├── scripts/
│   ├── build_app.sh              Validate content, build, bundle "build/System Design Oracle.app"
│   ├── validate_content.py       Checks content against the schema and topic/problem lists
│   ├── make_icon.swift           Draws the app icon
│   └── window_shot.swift         Screenshots the app window (for the README)
├── docs/
│   ├── INSTRUCTIONS.md           Setup, run, use, add content
│   ├── FILE-STRUCTURE.md         This file
│   ├── CONTENT-SCHEMA.md         JSON format for topics and design problems
│   ├── TOPICS.md                 Every domain and topic id, in display order
│   ├── PROBLEMS.md               Every design problem id, domain and prompt
│   └── images/                   README screenshots
└── build/                        Built .app (not committed)
```

Content is copied into `System Design Oracle.app/Contents/Resources/Content` at build time;
`swift run` reads it from `Sources/SystemDesignOracle/Content` directly.
