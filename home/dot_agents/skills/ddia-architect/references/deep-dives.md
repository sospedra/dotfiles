# DDIA Deep Dives Reference

Extended reference material for specific topics. Read relevant sections when
the main skill's decision frameworks need more detail.

## Encoding & Schema Evolution

### Format Comparison

| Format | Schema | Human-readable | Binary size | Evolution |
|---|---|---|---|---|
| JSON | Optional (JSON Schema) | Yes | Large (field names repeated) | Add/remove fields freely if code handles unknown |
| Protocol Buffers | Required (.proto) | No | Small (field tags, not names) | Add optional fields with new tag numbers. Never reuse tags. |
| Thrift | Required (.thrift) | No | Small | Same as Protobuf. BinaryProtocol and CompactProtocol variants. |
| Avro | Required but separate | No | Smallest (no tags in data) | Writer's schema embedded or negotiated. Reader resolves diffs. Best for Hadoop/data pipelines. |

Rules for schema evolution:
- Forward compatibility: old code can read new data (ignore unknown fields)
- Backward compatibility: new code can read old data (use defaults for missing fields)
- You can add optional fields but never remove required ones
- Never change a field's tag number or type in incompatible ways

### Modes of Dataflow

- **Through databases**: Process writes new schema, old process reads it (and vice versa).
  Schema migration must handle both directions. Be careful with "read then write back" —
  old code can drop new fields.
- **Through services (REST/RPC)**: API versioning. REST is better for experimentation
  (human-readable, widely tooled). RPC tries to make remote calls look local — this
  is fundamentally flawed because network calls have different failure modes.
- **Through message queues**: Async, decoupled. Producer and consumer evolve independently.
  Message broker is durable buffer. Actor model (Akka, Erlang) is a programming model
  built on this.

## Replication Deep Dive

### Replication Log Implementations

| Method | How it works | Pro | Con |
|---|---|---|---|
| Statement-based | Forward SQL statements | Compact | Nondeterministic functions break it (NOW(), RAND()) |
| WAL shipping | Send write-ahead log bytes | Exact replica | Coupled to storage engine version — can't do rolling upgrades |
| Logical (row-based) | Log of row-level changes | Decoupled from engine, good for CDC | More verbose |
| Trigger-based | Application-level via DB triggers | Most flexible | Most overhead, most fragile |

### Replication Lag Guarantees

| Guarantee | What it means | How to implement |
|---|---|---|
| Read-your-writes | User sees own writes | Read own data from leader; or track last write timestamp, route to follower only if caught up |
| Monotonic reads | User never sees time go backward | Sticky sessions (same user → same replica) |
| Consistent prefix reads | Causally related writes seen in order | Write causally related data to same partition |

### Conflict Resolution (Multi-Leader & Leaderless)

- **Last-write-wins (LWW)**: Simple but silently drops data. Achieves convergence at cost of durability.
- **On-read resolution**: Store all conflicts, let application resolve on next read (CouchDB).
- **On-write resolution**: Conflict handler in DB evaluates and merges.
- **CRDTs**: Data structures that auto-merge without conflicts (counters, sets, registers).
- **Operational transform**: Used by collaborative editors (Google Docs).
- **Version vectors**: Track causality across replicas to detect concurrent writes.

## Partitioning Deep Dive

### Rebalancing Strategies

| Strategy | How it works | Pro | Con |
|---|---|---|---|
| Fixed number of partitions | Create many more partitions than nodes, assign several per node | Simple rebalancing (move whole partitions) | Must choose count upfront; hard to tune |
| Dynamic partitioning | Split partition when too large, merge when too small | Adapts to data volume | Empty DB starts with one partition (bottleneck) |
| Proportional to nodes | Fixed partitions per node; more nodes = more partitions | Keeps partition sizes stable as cluster grows | Random boundaries |

### Request Routing

Three approaches:
1. Client contacts any node; node forwards if needed (Cassandra, Riak — gossip protocol)
2. Routing tier (partition-aware load balancer) — separate service
3. Client is partition-aware (requires client library that tracks assignments)

ZooKeeper as coordination service: nodes register partitions in ZK, routing tier/clients
subscribe to changes. Used by HBase, SolrCloud, Kafka.

## Transactions Deep Dive

### Write Skew & Phantoms

Write skew: two transactions read overlapping data, make disjoint writes that violate
a constraint neither checked against the other's write. Example: two doctors both check
"at least one doctor on call" is satisfied, both go off call → zero doctors on call.

Phantom: a write in one transaction changes the result of a search query in another.
The WHERE clause matched different rows before and after the write. Can't lock rows
that don't exist yet.

Materializing conflicts: artificially create lock objects. Instead of checking "is a room
booked for this time slot" (phantom — no row to lock), pre-create rows for every
possible time slot and lock the relevant row. Last resort — prefer serializable isolation.

### Two-Phase Commit (2PC) vs Consensus

2PC:
1. Coordinator sends prepare. Each participant votes yes/no.
2. If all yes → coordinator sends commit. If any no → abort.
- Coordinator is single point of failure. If it crashes after prepare but before
  commit/abort, participants are stuck (in-doubt) holding locks.
- XA transactions (standard API for 2PC) hurt performance badly.

Consensus (Raft, Paxos, Zab):
- Fault-tolerant agreement among nodes
- Requires majority quorum (survives minority failures)
- Total order broadcast: all nodes deliver same messages in same order
- Leader-based: leader proposes, followers accept/reject
- Used by ZooKeeper, etcd for: leader election, distributed locking, config,
  service discovery, membership

## Batch Processing Deep Dive

### MapReduce vs Dataflow Engines

MapReduce limitations:
- Materializes all intermediate state to disk (HDFS) between stages
- Multiple stages = multiple disk round-trips
- Must restructure algorithms into map/shuffle/reduce phases

Dataflow engines (Spark, Flink, Tez):
- Operators connected by data flow, pipeline processing
- Intermediate state can stay in memory
- Optimizer can reorder operations, push down predicates
- But: for fault tolerance, may need to recompute from last checkpoint

### Join Strategies in Distributed Processing

| Join type | When to use | How it works |
|---|---|---|
| Sort-merge join (reduce-side) | Both datasets large | Both inputs partitioned by join key, sorted, merged |
| Broadcast hash join (map-side) | One dataset small enough to fit in memory | Small dataset loaded into hash table on every mapper |
| Partitioned hash join (map-side) | Both datasets partitioned the same way | Each partition joined independently |

## Stream Processing Deep Dive

### Messaging Guarantees

| System type | Ordering | Delivery | Backpressure |
|---|---|---|---|
| Direct messaging (UDP, HTTP) | None | At-most-once | Drop or retry at sender |
| Message broker (RabbitMQ, SQS) | Per-queue | At-least-once with ack | Broker buffers |
| Log-based (Kafka, Kinesis) | Per-partition (total) | At-least-once, exactly-once with transactions | Consumer controls pace |

Log-based messaging vs traditional brokers:
- Traditional: message deleted after ack. Good for task distribution (work queue pattern).
- Log-based: append-only, consumers track offset. Good for event streams, CDC, replay.
  Supports multiple independent consumers without message duplication.

### Stream Join Types

| Join | Left | Right | Example |
|---|---|---|---|
| Stream-stream | Events | Events | Match click with impression within 1hr window |
| Stream-table | Events | DB changelog | Enrich activity events with user profile |
| Table-table | Changelog | Changelog | Materialized view maintenance |

### Fault Tolerance in Streams

- **Microbatching** (Spark Streaming): Break stream into small batches. Simple but adds latency.
- **Checkpointing** (Flink): Periodic consistent snapshots of operator state. On failure, restart from checkpoint.
- **Idempotent writes**: Make downstream writes idempotent so retries are safe. Requires operation IDs.
- **Transactions**: Atomic write of output + offset commit (Kafka transactions). Exactly-once within the stream system.

## The End-to-End Argument

A crucial principle from Chapter 12: reliability mechanisms at lower levels are not
sufficient if higher levels can still fail. TCP guarantees delivery within one connection,
but if the app crashes after receiving but before processing, the message is lost.
Exactly-once processing requires end-to-end design:

1. Use idempotent operations with unique IDs that span the entire pipeline
2. Don't trust intermediate systems to provide exactly-once — verify at the endpoints
3. Make operations deterministic where possible
4. Design audit mechanisms to detect and correct inconsistencies

This applies to every layer: database transactions, message delivery, RPC retries,
cache invalidation. The guarantee you need must be implemented end-to-end.
