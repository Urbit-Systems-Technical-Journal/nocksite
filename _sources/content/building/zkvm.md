# Nock zkVM

Nockchain is a blockchain which uses the Nock ISA as its primary instruction set.  The Nock zkVM is a STARK-based proving system that allows validators to efficiently verify off-chain computation without re-executing it (succinctness).  Despite the "zk" in its name, it is *not* yet a zero-knowledge system: it provides succinctness and soundness, not privacy, and the witness is not hidden.

This article is a short overview of the bottom layers of the Nock zkVM, primarily of interest for how it represents and interacts with Nock nouns and the formal verification of Nock-based computations.  The [“Open Proof Machine” page](https://nockchain.org/research/zkvm) has a comprehensive and widget-enabled explanation of the entire system.

* [`nockchain/nock-zkvm`](https://github.com/nockchain/nock-zkvm)
* [The Open Proof Machine: a Nock zkVM with an end-to-end soundness proof (2026)](https://nockchain.org/research/zkvm)

> **Status as of ~2026.11.17: the zkVM is an alpha research release.**  It has not been independently audited and must not be used in production.

How does the Nock ISA lend itself to STARK-based proofs?  The Nock ISA has several properties that make it a suitable target for STARK-based proving:

* **Small instruction set.**  With only twelve opcodes, the compute chip's state selector stays small, simplifying proof generation.
* **Deterministic behavior.**  Every Nock formula has one of three outcomes — a value, a deterministic crash, or non-termination — with no undefined behavior.  The reference interpreter `evalN` is fuel-indexed and returns `none` for both a crash and fuel exhaustion.
* **Stateless evaluation.**  Each Nock step is a pure function from `[subject formula] → noun`, which maps naturally onto a STARK execution trace.
* **No hidden state.**  The only non-structural opcode is 11 (hints).  In the modelled semantics hints are pure: static and dynamic hints are transparent, and a jet hint (a registered id with the exact body formula) is checked *inside* the circuit by the J and ALU chips.  There is no side-effect channel for the prover to model.

The zkVM is a Lean 4 formalization, with native executables, carrying kernel-checked soundness theorems for a STARK-based proof system over Nock.  It establishes soundness (a false claim is accepted only with negligible probability); it is not zero-knowledge, and completeness of the compiled protocol is not an end-to-end theorem.

## How it works

The design goal of this zkVM is to let a prover convince a verifier that a computation was performed correctly without the verifier re-executing it (succinctness).  The prover generates a proof that the claim `HoldsN c` is true, and the verifier checks it efficiently.  The system is not zero-knowledge: the prover is Reed–Solomon plus FRI with no masking, so the witness is not hidden — it delivers soundness and succinctness, not privacy.

A claim `c` consists of a subject, a formula, and an expected result.  The prover's goal is to demonstrate that evaluating the formula with the given subject produces the expected result.

All evaluation routes through `Nock.evalN`, which is a fuel-indexed big-step interpreter.

```
evalN : ℕ → Noun → Noun → Option Noun      -- fuel, subject, formula
```

A proof establishes a claim,

```
HoldsN c  :=  ∃ fuel, evalN fuel c.subject c.formula = some c.result
```

This definition states that a claim `c` holds if there exists some amount of fuel such that evaluating `c.formula` with `c.subject` using `evalN` produces `c.result`.  In other words, the claim is true if the formula successfully evaluates to the expected result within a finite number of steps.

Let's establish some terminology before we look at how the zkVM works:

* A *chip* is one table of the arithmetization.
* A *handle* is a reference to a noun by a `(kind, value)` pair rather than by content.
* A *coin* is a random field element the verifier draws.
* *Staged* means a trace column may depend only on coins drawn in earlier rounds.

### The machine

The point of a zkVM machine is to execute Nock formulas in a way that can be efficiently proven and verified using STARK-based proofs.  It maintains an execution trace that captures the evaluation of the formula step by step, allowing the prover to generate a proof that the computation was performed correctly.

The machine consists of several components, including the execution trace, the arithmetization tables (chips), and the mechanisms for handling coins and staged computations.  Each step of the Nock evaluation is recorded in the trace, and the arithmetization ensures that the trace can be checked efficiently by the verifier.

The first thing to do is convert a Nock evaluation run into a table-based execution trace.  This trace will record each step of the evaluation, including the current subject, formula, and intermediate results.  By organizing the computation in this way, we can later apply the arithmetization to generate the corresponding chips and ensure that the trace can be efficiently verified.

The honest prover runs a generator that mirrors `evalN` and emits an execution tree, one node per evaluation step.  A compute chip has one row per node, with a one-hot selector over 17 states:  ten for opcodes 0–9, one for cons, three for op 10 (`s10`, `s10L`, `s10T`) and three for op 11 (static, dynamic, jet).  It names nouns by handle, never by content.  The nouns themselves live in other chips:

- **Cell table**:  one row per distinct cell, hash-consed (each cell stored once).  Each row carries a fingerprint of its noun and the fingerprints of its two children.
- **Atom table**:  big atoms as chains of 32-bit limbs with the `+1` carry logic for op 4 built in.
- **Walk chips**:  forest walks over the cell and atom tables that turn a statement that "the noun at axis `a` of root `r`" into a record the compute chip consumes.  (This is how opcodes 0, 9 and 10 read memory.)
- **J chip**:  a straight-line interpreter for compiled [jet](../specification/opcode-11.ipynb) templates.
- **ALU chip**:  checks limb-level arithmetic for the primitive jets.

Tables are tied by arguments, such that one table provides records, another consumes them, and the verifier checks that the two multisets balance.  Each balance costs one coin, drawn from a quadratic extension `K′` of a cubic extension `K` of Goldilocks, so `|K′| = p⁶ ≈ 2³⁸⁴`.

A noun's fingerprint is a triple `(size, dyck, leaf)` at a random coin `z`.  The `leaf` component is `Σ zⁱ·vᵢ` over the noun's leaves in in-order position—consecutive powers of `z`, linear in the leaf values. Tree shape enters only through the separate `size` and `dyck` components.  Big atoms are supported through using a second, independent coin for their limbs, with coin collision detection enabled.

A jet call occurs due to a hint like `[11 [id clue] body]`.  In the zkVM, a registry maps an id to a *template* (argument axes plus a semantic function) and the Nock formula for which the template stands.

- Jets are keyed on the id and the exact body formula.  If the body is not literally the registered formula, the call is evaluated as an ordinary hint.
- A registry entry must be `Faithful ∧ Complete` against `evalN`:  the template returns a value exactly when the formula does.  Off-domain, the template returns nothing and the generator falls back to running the body.

The template jets are written in a tiny typed language and compiled to their Nock formula, so faithfulness is a theorem about the compiler, not a per-jet proof. The primitive arithmetic jets are hand-written guarded counting loops, proved against each specification.

The remainder of the Nock zkVM stack consists of the proof generation and verification layers, which go far beyond Nock evaluation as such.  We recommend the [“Open Proof Machine” page](https://nockchain.org/research/zkvm) for a comprehensive explanation of these layers.

<!-- ### Reading the library

These six theorems form the backbone of the library's correctness guarantees for the zkVM.  They cover the target predicate, library soundness and completeness, executable checking, and end-to-end soundness from input bytes to the final certified conclusion.

| # | Theorem | File:line | Says |
|---|---|---|---|
| 1 | `Nock.Jet.HoldsN` | [`Nock/Jet/Semantics.lean:41`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/Nock/Jet/Semantics.lean#L41) | The target predicate (a definition). |
| 2 | `probJ9AL_final_clean` | [`…/Handle/J9AL/ProbJ9AL.lean:550`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/Nock/NockVMROM/Thm54/VclL/Handle/J9AL/ProbJ9AL.lean#L550) | Library soundness, most general revision. |
| 3 | `complJ9AL_closed` | [`…/Handle/J9AL/ComplJ9ALClosed.lean:1031`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/Nock/NockVMROM/Thm54/VclL/Handle/J9AL/ComplJ9ALClosed.lean#L1031) | Library completeness (conditions below). |
| 4 | `checkJ9ALX_iff` | [`Nock/V1J9AL/CheckJ9ALIff.lean:644`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/Nock/V1J9AL/CheckJ9ALIff.lean#L644) | The executable checker equals the acceptance predicate. |
| 5 | `nock_e2e_J9AL_succinct_B` (twin [`nock_e2e_J9ALJ_succinct_B`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/nockvm-e2e/NockvmE2E/Z38/E2ESuccinctJ9ALJB.lean#L168)) | [`nockvm-e2e/NockvmE2E/J9AL/E2ESuccinctJ9ALB.lean:167`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/nockvm-e2e/NockvmE2E/J9AL/E2ESuccinctJ9ALB.lean#L167) | End-to-end soundness, random-oracle model. |
| 6 | `verifyBytesL_sound` (twin `verifyBytesLJ_sound`) | [`nockvm-e2e/NockvmE2E/Exec/CertSound.lean:166`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/nockvm-e2e/NockvmE2E/Exec/CertSound.lean#L166) ([`:242`](https://github.com/nockchain/nock-zkvm/blob/7a51d916ef29e117553d2ece2caff678c8731112/nockvm-e2e/NockvmE2E/Exec/CertSound.lean#L242)) | The certified verifier: from input bytes to theorem 5's conclusion. |

### The soundness statement

A proof system like this must be complete (an honest prover convinces the verifier of true statements) and sound (no dishonest prover can convince the verifier of a false statement).  A *zero-knowledge* proof would add a third property — that no information beyond the claim's truth reaches the verifier — but this system does not provide it; it targets soundness and does not hide the witness.

Two separate bounds are at play.  The `2⁻¹⁵⁵` figure below is the **library** bound, proved with ideal coins and no commitment scheme, low-degree test, or Fiat–Shamir theorem.  The `2⁻⁸²` figure in [What the zkVM proves](#what-the-zkvm-proves) is the separate, weaker **end-to-end** bound for the FRI/random-oracle package.

For every public layout, every faithful jet registry, every claim `c`, and every staged prover strategy within the fixed row budgets, "the fraction of coin vectors at which the verifier accepts and `c` is false is below `2⁻¹⁵⁵`."  This statement means that:

- The probability is a plain count over all of `K¹⁹`, nineteen coins of the cubic extension.
- The only restrictions on the prover's strategy are staging (each column depending only on coins drawn before its round) and row budgets fixed in advance (`hAX`, `hSP`, `hAL ≤ 2³¹`, `hLC…hLV`, `hk`, `hmax`).  Its public messages may depend on every coin.
- The claim, layout, row budgets and registry are fixed before the coins.
- The acceptance predicate contains no reference to `evalN`, to `HoldsN`, or to the honest generator. Every conjunct is computed from the claim and the trace.
- There is no low-degree assumption and none is needed, because at this layer the "verifier" inspects every row of the trace.  (That is, the library proves the constraint system is sound, not that a succinct protocol is.)
- `2⁻¹⁵⁵` is closed by a kernel computation at the actual field size, and is tight to within a bit (a companion lemma shows the bound is not `≤ 2⁻¹⁵⁶`).

## What the zkVM proves

The fundamental claim of the Nock zkVM (in our own words):

> For an instance that passes the verifier's gates, with the claim `c` and public input fixed before the random oracle is sampled, and for every adversary within the query budgets:

> > Pr[ the verifier accepts the adversary's output ∧ `c` is false ] ≤ `2⁻⁸²` + (three side-proof terms: `bfriErr`, a multi-checkpoint ROM term, and a collision term `(Q_Hf+Vf+T)²/2|Dg|`).

### What it does not say

This system is not zero-knowledge today (as it does not hide the witness) and its soundness theorem is narrower than it first appears.  The two easiest ways to over-read the result are to assume it keeps the computation private (it does not) or to misunderstand what soundness and completeness establish.  Let us therefore be precise about what the claim does not establish:

1. **It is not about the proof that was accepted.**  The theorem takes "the executable's verdict was accept" as a hypothesis, but its proof uses only the instance's gate checks and discards the result of checking the proof.  This is the normal shape of a soundness theorem ("this verifier, on instances like this one, is rarely fooled") and is correct.
2. **It is non-adaptive.**  The adversary may not choose the claim after seeing the oracle.  The verifiers bind the public input (claim cells, pins, atoms, the primitive table and calls) into the transcript, which is what one would do to make the adaptive statement true, but the adaptive theorem is not proved.  The verification key, table sizes and chip set are not bound.
3. **The headline confidence is established for the shipped examples.**  The figure of about `2⁻⁸¹·⁴` depends on side conditions proved for the `add` and `jp` fixtures and a toy.  For an arbitrary accepted instance they are hypotheses, and the executable does not check them.
4. **The executed verifier differs from the modelled one in small ways.**  The hash in the theorem is a sampled table, not Tip5; no theorem relates the two.  Query positions are reduced modulo a power of two where the theorem samples uniformly; the per-position bias is `2⁻⁶⁴`, and the obvious way to bound its effect is vacuous at the stated query budget.  (Both are disclosed.)

The certified verifier (`verify-cert`) turns an accept into the end-to-end conclusion *for the instance to which those bytes parse*.  The parser need not be correct:  a misparse would change which statement was proved, never whether it is true, and the claim printed is the parsed claim.  For that certified verifier, the trusted base is the Lean kernel, the Lean compiler and runtime, the C toolchain, `main`'s few lines of file I/O, and the random-oracle model for the hash. -->
