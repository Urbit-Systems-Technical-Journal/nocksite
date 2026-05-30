# NockApp and Nockchain

NockApp is a framework for building and executing applications whose business logic is written in Nock and runs inside a Rust host runtime.  Nockchain is one such application:  a Proof-of-(Useful)-Work blockchain in which the work being done is the generation of zero-knowledge proofs over [`NockVM`](https://docs.nockchain.org/reference-runtime/nockvm) execution traces.  This page describes how those pieces fit together and which properties of Nock they rely on.  It is not a tutorial for either system; for hands-on material, see [`docs.nockchain.org`](https://docs.nockchain.org).

NockApp began life as the Ares project associated with the Urbit Foundation, then became briefly Sword when Zorp Corp took over development.

## The Two-Component Pattern

A NockApp is split into a **kernel** and a **runtime**:

* The **kernel** is a Nock noun—usually compiled from [Hoon](../languages/relationship-to-hoon.md)—that holds the application's state and exposes a small standard interface.  It is the part that is, in principle, formally provable in Nockchain's zkVM.
* The **runtime** is a Rust program that hosts a Nock evaluator (`NockVM`) plus a set of I/O drivers.  It handles networking, disk, gRPC, and the boot sequence—everything the kernel can't or shouldn't reason about.

A kernel presents three arms that the runtime invokes:

* `+load` — upgrade entry point.  Receives the previous kernel state and returns a state in the new kernel's type.
* `+peek` — read-only scry.  Accepts a path and returns a value (or signals absence).
* `+poke` — state-altering event.  Accepts a noun, returns a list of effects plus the new state.

This (alongside an outer wrapper for `+wish`) is the same kernel shape used by Arvo, covered on the [Kernels](kernel.md) page; NockApp standardizes it and ships a runtime that knows how to drive it.  The runtime persists state to a **Persistent Memory Arena (PMA)**—a file-backed arena that demand-pages the kernel's noun so the working set fits in memory regardless of total state size.

NockApp instances communicate via gRPC as the framework's interop layer.

## Nock as a Proof Target

Nockchain's central technical bet is that Nock makes a usable target for STARK-based zero-knowledge proofs.  Per the [docs](https://docs.nockchain.org/architecture/why-nockchain):

> The Nock ZKVM is a STARK-based proving system over the Goldilocks field, transparent (no trusted setup), achieving approximately 121 bits of security and roughly an order of magnitude more efficiency than general-purpose ZKVMs in the RISC-V family.

A few properties of Nock ISA shape the proof system:

* **Small instruction set.**  Twelve opcodes mean a small set of circuit constraints to instantiate, with ongoing work to prove opcodes 9, 10, and 11.
* **No undefined behavior.**  Every formula either produces a value or crashes deterministically; there is nothing for the prover to model that the spec doesn't already pin down.
* **Solid-state evaluation.**  A Nock step is `[subject formula] → noun`.  A sequence of pokes against a kernel is a chain of noun→noun transitions, which maps naturally onto a STARK execution trace.
* **Opcode 11 (hints) is the only side-effect channel** and is handled by the host, outside the circuit—see [Hints & Jetting](../hints-jetting/index.md) and [Virtualization](virtualization.md).

* [Kattis, Klatt, Quirk, & Allen (2025), *A Framework for Compiling Custom Languages as Efficiently Verifiable Virtual Machines* (IACR ePrint 2025/1110)](https://eprint.iacr.org/2025/1110).

## ZK-Intents and Off-Chain Execution

Nockchain's transaction model differs from the "embed a VM in consensus" pattern used by Ethereum.  From the docs:

> Computation occurs offchain in NockApps, where developers have arbitrary resources and no gas constraints; the results are then proven via the Nock ZKVM, and validators verify the proofs without re-execution.  Verification cost is effectively independent of computation size.

In this design, users submit *intents*—declarative statements about desired outcomes—and an off-chain NockApp does the work of satisfying them.  Settlement is a succinct proof that the work was done correctly.

Concrete consequences worth noting:

* There is no gas metering on execution; fees are quoted on transaction size alone.
* Validators verify proofs but do not re-execute the underlying computation.
* Multiple NockApps can share a settlement root without sharing an execution environment.

Whether this trade-off (proving cost shifted off-chain, verification cost held roughly constant) is a net win in practice depends on workload and on how cheap Nock-based proving turns out to be.

## Proof-of-Useful-Work

Nockchain frames its mining work as "Proof-of-Useful-Work" (PoUW):  the energy that secures the chain is spent generating ZK proofs that have value outside consensus, rather than on hashes that are discarded.  The unit of network capacity in this model is *proofpower* rather than hashpower.

## Further Reading

* [Nockchain documentation](https://docs.nockchain.org) — kernel, runtime, drivers, transaction engine, and ZK-Intents reference.
* [Nockchain whitepaper](https://docs.nockchain.org/introduction/whitepaper).
* [`zorp-corp/nockchain`](https://github.com/zorp-corp/nockchain) — Rust runtime and reference NockApp implementations.
* [Kattis, Klatt, Quirk, Allen (2025), "A Framework for Compiling Custom Languages as Efficiently Verifiable Virtual Machines"](https://eprint.iacr.org/2025/1110) — the underlying compilation framework.
* [NockApp's reference kernel](https://docs.nockchain.org/reference-kernel/architecture#kernel-structure) — the canonical kernel layout NockApp expects.
