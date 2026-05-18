# Relationship to Loon

[Loon](https://github.com/frodwith/loon) is an experimental Lisp dialect by ~fodwyt-ragful that compiles to Nock. `frodwith` describes it as a “lambda-delta calculus”: the untyped lambda calculus augmented with Nock's noun operations—cons, axis reads, edits, equality, increment, depth test, conditional branching, and hints—as language-level primitives. Delta abstractions are Nock formulas.

Loon uses Lisp-style S-expression syntax with square brackets for cell literals, lowercase symbols, and `_` for wildcards in binding patterns.  Its most distinctive feature is the split between two forms of abstraction:  `fn` produces an ordinary closure, while `dfn` produces a bare Nock formula.  The latter enables a clean module pattern in which a top-level `main` form is itself a Nock formula that takes its dependencies as an argument, with modules composed via Nock's opcode 2.

At the current time, Loon is a single-author prototype.  Its inline test suite serves as the specification.

## Example

This Loon program:

```loon
(focus a 42 a)
```

binds `a` to 42 and returns it, compiling directly to Nock opcode 7 (compose):

```nock
[7 [1 42] 0 1]
```

The bound value becomes the new subject (`[1 42]`), and the body retrieves it with `[0 1]`.  Loon's binding forms map onto Nock's structural opcodes with no runtime machinery in between.

## Further Reading

* [Loon GitHub Repository](https://github.com/frodwith/loon): The single-file implementation, with an inline test suite that serves as the working specification.
