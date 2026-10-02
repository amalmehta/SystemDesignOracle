<p align="center"><img src="Resources/AppIcon.png" width="128" alt="System Design Oracle icon"></p>

# System Design Oracle

A Mac app and website for learning system design across the stack. It covers 56 topics in 10 domains, from operating systems and GPUs up to LLM inference and autonomous vehicles, plus 10 worked end-to-end design problems. Every page reads in four layers, so you can stop at whatever depth you need.

![Home screen](docs/images/home.png)

```mermaid
flowchart LR
  L1["1 · The Gist<br/>one sentence"] --> L2["2 · The Picture<br/>plain English + diagram"]
  L2 --> L3["3 · How It Works<br/>parts, flow, trade-offs, numbers"]
  L3 --> L4["4 · Expert Depth<br/>failure modes, real systems,<br/>interview questions"]
```

| A design problem, layers 1–2 | The same problem, layers 3–4 |
|---|---|
| ![Trajectory prediction overview](docs/images/problem-overview.png) | ![Trajectory prediction design stages](docs/images/problem-design.png) |

| A concept topic | |
|---|---|
| ![KV cache topic](docs/images/topic.png) | **Domains:** Operating Systems · GPUs & Accelerators · Storage · Networking · Distributed Systems · Data Systems · Security · ML Training · Inference Serving · Autonomous Vehicles |

### On the web

The same content and the same four layers, in any browser, phones included.

| Desktop | Phone |
|---|---|
| ![Website on desktop](docs/images/website.png) | ![Website on a phone](docs/images/website-phone.png) |

## Links

- [Website](https://amalmehta.github.io/SystemDesignOracle/)
- [Instructions](docs/INSTRUCTIONS.md): build, install, use, add content
- [File structure](docs/FILE-STRUCTURE.md): what's where
- [Content schema](docs/CONTENT-SCHEMA.md) · [Topic list](docs/TOPICS.md) · [Design problems](docs/PROBLEMS.md)
- [Send feedback](https://github.com/amalmehta/SystemDesignOracle/issues/new)
