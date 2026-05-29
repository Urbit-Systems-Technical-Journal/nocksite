# Virtualization

Virtualization is the technique of implementing a Nock interpreter in Nock itself.  Because Nock is homoiconic and crash-only, a virtualized interpreter is not a curiosity—it is the natural way to build practical systems on Nock.

> Metacircularity in most languages is a curiosity and corner case.  Practical metacircularity is a particular strength of Nock, or any functional assembly language.  (Curtis Yarvin, quoted in ~lacnes 2025)

A virtual interpreter gives a host system three things that bare Nock cannot:

1. **A crash boundary.**  A crash inside the virtualized layer is a `unit` returned by the host, not a halt of the whole system.
2. **Hint handling.**  Opcode 11 carries side-effect signals that only an enclosing interpreter can act on.
3. **Namespace extension.**  Lookups beyond the subject (Urbit's *scry*) are mediated by the virtualizer, preserving referential transparency.

This page sketches the design of the Urbit standard library's interpreter family—`++mink`, `++mock`, `++mule`, `++soft`—and the role each plays.  The treatment here is condensed from ~lacnes (2025); see the article for the full code listing and discussion.

## Three Kinds of Result

Because Nock has no types, the virtualizer must distinguish "produced a noun" from "blocked" from "deterministically crashed".  The convention is a tagged sum:

| Tag | Shape          | Meaning                                              |
| --- | -------------- | ---------------------------------------------------- |
| `%0` | `[0 noun]`     | Success—the product is `noun`.                       |
| `%1` | `[1 paths]`    | Block—the computation needs values not yet available.|
| `%2` | `[2 trace]`    | Halt—a deterministic error, with a stack trace.      |

> Because Nock is untyped and we need to distinguish a "zero" from a "block", the structure of each scry result fundamentally differs from the other options.  (~lacnes 2025)

A bare Nock interpreter would simply loop forever or crash; a virtual interpreter returns one of these three values so the host can decide what to do.

## The Interpreter Family

### `++mink` — the metacircular core

`++mink` is the foundational interpreter:  a function that takes a subject, a formula, and a `scry` gate, and returns a tagged result of one of the three shapes above.  It is written in Hoon and compiles to Nock, but the runtime jets it (in Vere, as `u3m_soft_run()`) so it runs at near-native speed.

`++mink` walks the formula opcode by opcode:

- `0` extracts an axis from the subject, returning `%2` if the axis is invalid.
- `1` returns the formula's constant.
- `2` evaluates `b` and `c` against the subject, then evaluates the first product against the second.
- `3`–`5` reduce to the corresponding axiomatic operators after evaluating arguments.
- `6` evaluates the test, then takes one of two branches.
- `7`/`8` compose formulas or augment the subject.
- `9` selects an arm and evaluates it structurally.
- `10` traverses to perform a functional update.
- `11` evaluates hints (see below).
- `12` invokes the supplied scry gate (see below).

Each step propagates `%1`/`%2` results upward unchanged, so a single failure or block aborts the whole computation cleanly.

### `++mock` — `++mink` plus hint handling

`++mock` wraps `++mink` and adds runtime support for opcode 11 hints.  When the inner interpreter reports a recognized hint tag (`%hunk`, `%hand`, `%lose`, `%mean`, `%spot`, ...), `++mock` lets the host act on it—annotating a trace, recording a profile sample, or throwing a typed error.

This is the common entrypoint for "I want to run this formula and get a useful answer back, including a debuggable trace if it crashes".

### `++mule` — kicking a trap

`++mule` wraps `++mock` to evaluate a *trap* (a zero-argument core) and return a tagged result.  It's what Hoon programs reach for when they want to try a computation and catch its failure as a `unit`.

### `++soft` — typed catch

`++soft` wraps the result of a typecast so that a Nock crash inside it becomes `~` rather than tearing down the calling computation.  It is the type-system-facing counterpart to `++mule`.

Together these form a stack: `++mink` does the work, `++mock` adds hints, `++mule` adds trap invocation, `++soft` adds typed graceful failure.

## Opcode 11: Hints

> Hints cannot simply be discarded by the interpreter, because [evaluating them] may result in a crash.  Thus, as with direct Nock execution, the hint must be evaluated.  (~lacnes 2025)

Opcode 11 has two forms—a static hint `[11 tag c]` and a dynamic hint `[11 [tag clue] c]`—where the runtime compares `tag` against a whitelisted set.  Recognized tags hand the runtime a chance to do something practical:

- `%spot` annotates the source span of a Hoon expression for stack traces.
- `%mean` carries a thunk for a human-readable error message.
- `%hand`/`%lose` mark a formula as a known/unknown jet target.
- `%bout`, `%memo`, `%slog`, etc. are listed on [Hints & Jetting](../hints-jetting/index.md).

Unknown tags are passed through unchanged:  the formula evaluates as if the hint weren't there.

## Opcode 12: Scry

The virtualized layer extends Nock with a twelfth opcode for namespace lookups outside the subject.  Its formula is `[12 ref path]`; both `ref` and `path` evaluate against the subject, and the resulting pair is passed to the supplied `scry` gate of type:

```
$-(^ (unit (unit)))
```

The three result shapes—`[~ ~ value]`, `~`, `[~ ~]`—match the success/block/halt taxonomy above.  Importantly, scry does *not* punch a hole in Nock's referential transparency:

> It appears like a GOTO or remote call but actually preserves Nock semantics including strict subject scoping.  (~lacnes 2025)

In Arvo, each vane is handed a `+$roof` function so it can answer scry requests with type-aware results.  The `.^` ("dotket") rune in Hoon compiles to a `[12 ...]` formula bound to the kernel's scry handler, giving userspace mediated access into the wider namespace without baking the entire system state into the subject.

## A Minimal Worked Example

Once you have `++mink`, adding a new opcode is a few lines of Hoon.  ~lacnes uses opcode 13 as a fake "logical negation":

```
[%13 subject=*]
```

The handler evaluates the subformula, checks for `0`, and returns the loobean inverse.  In the virtualized interpreter this is a single arm; in bare Nock it would mean changing the language spec.

> Functional metacircular interpreters can collapse "towers of interpreters" without excessive overhead.  (~lacnes 2025, citing Amin & Rompf)

The same approach is what Urbit uses for production:  Arvo, Gall agents, and Vere's `u3m_soft_run()` all run formulas through `++mink`/`++mock` rather than against bare Nock 4K.

## Why It Matters

Solid-state systems—machines whose entire state is a Nock noun—depend on virtualization for both safety and extensibility.  Hints, scry, and crash boundaries are not features of base Nock; they are features of the virtualized layer that bare Nock makes cheap to build.

> A metacircular functional dissemination protocol can serve as a complete, general-purpose system software environment ... such a protocol can be described as an "operating function" or OF — the functional analog of an imperative operating system.  (Curtis Yarvin, quoted in ~lacnes 2025)

If you're implementing a Nock runtime, `++mink` is probably the first thing you should jet.

## References

This page is a condensed summary of:

* [~lacnes (2025) "Metacircular Virtualization and Practical Nock Interpretation", *Urbit Systems Technical Journal* 2:1](https://urbitsystems.tech/article/v02-i01/metacircular-virtualization-and-practical-nock-interpretation), which provides the full implementation, opcode-by-opcode treatment, and historical context.

Reference implementations and related documentation:

* [Virtualized Nock (`+mock`)](https://docs.urbit.org/build-on-urbit/core-academy/ca00#virtualized-nock-mock)
* [Urbit docs, `+mink` evaluator](https://docs.urbit.org/hoon/stdlib/4n#mink)
* [Opcode 11 (Hint)](../specification/opcode-11.ipynb)
* [Hints & Jetting](../hints-jetting/index.md)
