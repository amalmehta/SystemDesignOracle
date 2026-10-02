# Content Schema

Each domain is one JSON file in `Sources/SystemDesignOracle/Content/<domain-id>.json`.
The app reads every `.json` file in that folder at launch.

```json
{
  "id": "gpu",
  "name": "GPUs & Accelerators",
  "symbol": "cpu",
  "summary": "One or two sentences on what this domain is and why it matters.",
  "topics": [ TOPIC, ... ]
}
```

`symbol` is an SF Symbols name.

## Topic: four layers

Each topic is read in four layers. A reader can stop after any layer.

```json
{
  "id": "gpu-memory-hierarchy",
  "title": "GPU Memory Hierarchy",

  "gist": "LAYER 1 — one sentence, under 30 words, no jargon a newcomer wouldn't know.",

  "overview": [
    "LAYER 2 — 2 to 4 short paragraphs in plain English. Use an analogy.",
    "Inline markdown allowed: **bold**, *italic*, `code`. No headings, lists or links."
  ],
  "diagram": {
    "caption": "What the diagram shows, one line.",
    "steps": [
      { "label": "Registers", "detail": "~1 cycle, per thread" },
      { "label": "Shared memory / L1", "detail": "~30 cycles, per SM" },
      { "label": "L2 cache", "detail": "~200 cycles, whole chip" },
      { "label": "HBM", "detail": "~500 cycles, 80 GB" }
    ]
  },

  "howItWorks": {
    "components": [ { "name": "Streaming Multiprocessor", "role": "What it does, one or two sentences." } ],
    "flow": [ "Step-by-step sentence describing how a request/data moves through the system." ],
    "tradeoffs": [ { "choice": "Bigger tiles", "pro": "More reuse", "con": "Fewer resident warps" } ],
    "numbers": [ { "metric": "H100 HBM3 bandwidth", "value": "~3.35 TB/s" } ]
  },

  "expert": {
    "details": [ "LAYER 4 — dense paragraphs on subtleties, edge cases, what the textbooks skip." ],
    "failureModes": [ { "name": "Bank conflicts", "description": "What goes wrong, symptom, fix." } ],
    "realSystems": [ { "name": "FlashAttention", "note": "How it uses this idea, one or two sentences." } ],
    "questions": [ { "q": "Design-interview style question.", "a": "Model answer, 2-5 sentences." } ]
  },

  "related": [ "kernel-optimization", "kv-cache" ]
}
```

## Rules

- Topic `id`s are globally unique, kebab-case, and come from `docs/TOPICS.md`.
- `related` may only reference ids listed in `docs/TOPICS.md` (any domain).
- Diagram: 3–7 steps, a left-to-right flow or a stack; labels ≤ 4 words, details ≤ 8 words.
- Minimums per topic: overview 2 paragraphs; components 3; flow 3; tradeoffs 2; numbers 3;
  details 2; failureModes 2; realSystems 2; questions 2; related 2.
- Numbers must be real, approximate orders of magnitude are fine (use "~"). Name the hardware/version.
- Write for a smart newcomer in layers 1–2, a working engineer in layer 3, a specialist in layer 4.

# Design Problems

One file per problem in `Sources/SystemDesignOracle/Content/problems/<id>.json`; ids and prompts
come from `docs/PROBLEMS.md`. A problem is a worked, end-to-end answer, read in the same four layers.

```json
{
  "id": "av-trajectory-prediction",
  "title": "Trajectory Prediction for an Autonomous Vehicle",
  "domain": "autonomous-vehicles",
  "prompt": "Exact prompt from docs/PROBLEMS.md.",

  "gist": "LAYER 1 — the shape of the answer in one sentence (≤ 35 words).",

  "overview": [ "LAYER 2 — 2–4 plain-English paragraphs: the approach, why, and the big decisions." ],
  "diagram": { "caption": "End-to-end system.", "steps": [ { "label": "Fleet logs", "detail": "petabytes of drives" } ] },

  "requirements": {
    "functional": [ "LAYER 3 — what it must do" ],
    "nonFunctional": [ "latency, scale, safety, cost targets" ],
    "estimates": [ { "metric": "Agents per scene", "value": "~50–200" } ]
  },
  "stages": [
    {
      "name": "Data",
      "summary": "One or two sentences on this stage's job and key decision.",
      "points": [ "Concrete design decision with the reason." ],
      "deepDive": [ "LAYER 4 — specialist paragraph for this stage." ]
    }
  ],
  "tradeoffs": [ { "choice": "", "pro": "", "con": "" } ],

  "expert": {
    "failureModes": [ { "name": "", "description": "" } ],
    "realSystems": [ { "name": "", "note": "" } ],
    "questions": [ { "q": "Interviewer follow-up", "a": "Model answer" } ]
  },

  "related": [ "prediction-planning", "perception" ]
}
```

Stage names fit the problem (an ML problem: Data, Model, Training, Evaluation, Deployment; a backend
problem: API, Data Model, Write Path, Read Path, Scaling…). Minimums: overview 2; functional 3;
nonFunctional 3; estimates 3; stages 4 (each ≥ 3 points and ≥ 1 deepDive); tradeoffs 3;
failureModes 3; realSystems 2; questions 3; related 3 (topic ids from `docs/TOPICS.md`).
