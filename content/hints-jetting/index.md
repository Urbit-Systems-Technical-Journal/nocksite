# Hints & Jetting

Hints are special annotations in Nock code that provide additional information to the Nock interpreter or compiler.  While they have no formal effect within the Nock noun itself, they can result in side effects or performance optimizations when executed in a Nock environment that recognizes them.  For instance, to issue a network request or print to a console, a Nock program can raise a specially structured noun that the evaluator interprets as a command to perform that action.

## Basic Side Effects

Side effects are bound to a particular Nock runtime environment, so the exact hints available may vary between implementations.  However, some common side effects that Nock runtimes may support include:

- `%bout`, which times calculations.
- `%fast`, which enables jet hinting for performance optimization.
- `%live`, which enables tracks profiling hit counters.
- `%meme`, which calculates and prints memory usage.
- `%memo`, which enables caching for repeated computations.
- `%slog`, which logs a message to the console or a log file.
- `%spot`, which generates stack traces for debugging.
- `%xray`, which prints bytecode for inspection.

Some of these are static hints, which use the form of opcode 11 that just accepts a noun.  `b` corresponds to the static hint label and `c` is the continuation of the program.

```
*[a 11 b c]         *[a c]
```

Others are dynamic hints, which use opcode 11 with a formula to evaluate.  `b` corresponds to the dynamic hint label, `c` is the hint's formula (which is evaluated against the subject and then discarded), and `d` is the continuation of the program.

```
*[a 11 [b c] d]     *[[*[a c] *[a d]] 0 3]
```

(The formula cannot be skipped even if the hint is not recognized by the runtime, because it could result in a crash.)

## Jetting

Jetting is a performance optimization technique used in Nock interpreters where certain frequently used or computationally intensive Nock formulas are replaced with pre-compiled native code implementations, known as “jets” (derived from “jet-accelerated code”).  When the Nock evaluator encounters a formula that has a corresponding jet, it can execute the optimized native code instead of interpreting the Nock formula directly, resulting in significant performance improvements.

Jetted code must exactly match the behavior of the original Nock formula to ensure correctness.  Jets are typically implemented for operations that are computationally expensive or frequently used, such as arithmetic operations, data structure manipulations, and cryptographic functions.  If a jet does not exactly reproduce the Nock standard's behavior, it is called  “jet mismatch”, which will lead to incorrect program behavior.
