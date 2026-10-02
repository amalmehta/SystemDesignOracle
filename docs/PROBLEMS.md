# Design Problems

Problem id — domain — prompt. One JSON file per problem in
`Sources/SystemDesignOracle/Content/problems/<id>.json`.

- av-trajectory-prediction — autonomous-vehicles — Design the ML system that predicts the future trajectories of other agents (vehicles, pedestrians, cyclists) around an autonomous vehicle, and feeds those predictions into the planner. Cover it end to end: data, model, training, evaluation, and deployment on the vehicle.
- train-70b-llm — ml-training — Design the system to pre-train a 70B-parameter language model on ~15T tokens using a cluster of ~2,000 GPUs. Cover parallelism, data pipeline, fault tolerance, and how you know training is healthy.
- attention-kernel — gpu — Design a fused attention kernel for a modern datacenter GPU that reaches a high fraction of peak throughput for long sequences. Explain the memory traffic, tiling, and how you would verify and tune it.
- llm-chat-serving — inference — Design the serving system for a chat LLM used by 10 million daily users. Cover latency targets, batching, KV-cache memory, routing, autoscaling, and cost.
- single-node-kv-server — os — Design an in-memory key-value server that handles ~1 million requests per second on a single machine. Cover threading, I/O model, memory management, and tail latency.
- news-feed — distributed — Design a social news feed for 500 million users: posting, fan-out, ranking hooks, caching, and consistency.
- video-cdn — networking — Design a global CDN for on-demand video streaming. Cover request routing, caching tiers, transport, and handling a viral spike.
- blob-store — storage — Design an S3-like object store that holds exabytes with eleven nines of durability. Cover metadata, data placement, erasure coding, and repair.
- rag-retrieval — data — Design the retrieval system behind a RAG assistant over 1 billion documents that are updated continuously. Cover ingestion, chunking, embeddings, indexing, hybrid search, freshness, and evaluation.
- code-sandbox — security — Design a service that runs untrusted user-submitted code (like an online judge or AI code-execution tool) safely at scale. Cover isolation, resource limits, networking, and abuse.
