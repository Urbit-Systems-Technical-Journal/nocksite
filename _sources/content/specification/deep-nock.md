# Nock, Deeper

Nock is a combinator calculus designed to be a minimal, universal low-level computation model.  While related to the SKI combinator calculus and lambda calculus, Nock is distinct in its design goals and implementation details.

For instance, Nock was designed from the beginning to make itself easy to extend via virtualization and to be a satisfactory instruction set architecture for higher-level languages.  It was also designed to be simple enough to reason about formally, while still being practical enough to implement real systems.

> Nock’s simplicity and unity of expression make it amenable to proof-based reasoning and guarantees of correctness. Its Lisp-like nature surfaces the ability to introspect on the code itself, a property which higher-level languages compiling to it can exploit. Yet for all this, Nock was not born from a purely mathematical approach, but found its roots in practical systems engineering.  (~lagrev-nocfep, ~sorreg-namtyv, 2025, op. cit.)

Nock bears these characteristics:

* Turing-complete. Put formally, Turing completeness (and thus the ability to evaluate anything we would call a computation) is exemplified by the 
-recursive functions. In practice, these amount to operations for constant, increment, variable access, program concatenation, and looping (Reitzig, 2012). Nock supports these directly through its primitive opcodes.

* Functional (as in language). Nock is a pure function of its arguments. In practice, the Urbit operating system provides a simulated global scope for userspace applications, but this virtualized environment reduces to garden-variety Nock. (See ~lacnes, pp. 71–97 in this volume, for details of a Nock virtualized interpreter.)

* Subject-oriented. Nock evaluation consists of a formula as a noun to be evaluated against a subject as a noun. Taken together, these constitute the entire set of inputs to a pure function.

    Some Nock opcodes alter the subject (for instance a variable declaration) by producing a new subject which is utilized for subsequent axis lookups.

* Homoiconic. Nock unifies code and data under a single representation. A Nock atom is a natural number, and a Nock cell is a pair of nouns. Every Nock noun is acyclic, and every Nock expression is a binary tree. For example, Nock expressions intended to be evaluated as code are often pinned as data by the constant opcode until they are retrieved by evaluating the constant opcode at that axis.

* Untyped. Nock is untyped, meaning that it does not impose any type system on the expressions it evaluates. Nock “knows” about the natural numbers in two senses: such are used for addressing axes in the binary tree of a noun, and such are manipulated and compared using the increment and equality opcodes.

* Solid-state. A Nock interpreter is a solid-state machine, meaning that it operates from a state to a new state strictly according to inputs as a pure lifecycle function. The Nock interpreter must commit the results of a successful computation as the new state before subsequent computations, or events, can be evaluated. Transient evaluations (uncompleted events) and crashes (invalid evaluations) may be lost without consequence, and the Nock interpreter layer persists the underlying state of the machine.

## References

* [~lacnes (2025) “Metacircular Virtualization & Practical Nock Interpretation”, *Urbit Systems Technical Journal 2*: 1.](https://urbitsystems.tech/article/v02-i01/metacircular-virtualization-and-practical-nock-interpretation)
* [~lagrev-nocfep, ~sorreg-namtyv (2025) “A Documentary History of the Nock Combinator Calculus”, *Urbit Systems Technical Journal 2*: 1.](https://urbitsystems.tech/article/v02-i01/a-documentary-history-of-the-nock-combinator-calculus)
* [Urbit Docs, ”Nock Definition”](https://docs.urbit.org/nock/definition)
