# Glossary

A reference for terms that recur in Nock and the languages built on it.  Definitions are adapted from the [Urbit Developers glossary](https://developers.urbit.org/reference/glossary), focused on what's useful when reading Nock specifications, code, and runtime documentation.

## Nock's Universe

These four terms describe the entire data model.

`noun`
: An atom or a cell.  Every value in Nock is a noun, and code and data share this representation.

`atom`
: A non-negative integer of any size.  Atoms are Nock's only primitive scalar; everything else (booleans, signed integers, dates, byte arrays, text) is encoded as an atom under a higher-level interpretation.

`cell`
: An ordered pair of nouns.  Cells are right-associative: `[a b c]` is shorthand for `[a [b c]]`.

`cons`
: Lisp's name for the pair operation.  In Nock, constructing a cell from two values is implicit when a formula's head is itself a cell—see [Cell Distribution](specification/cell-distribution.ipynb).

## Evaluation

`subject`
: The data side of an evaluation `*[subject formula]`.  Acts as scope, environment, and argument all at once.

`formula`
: The code side of an evaluation.  Always a cell whose head selects an opcode (or recursively, a pair of formulas; see [Cell Distribution](specification/cell-distribution.ipynb)).

`product`
: The result of evaluation—itself a noun.

`leg`
: Some subtree of the current subject reachable by a tree address.  Subjects are referred to by leg paths during Nock execution.

## Cores

A core is the standard "structured object" in Nock-targeted languages.

`core`
: A cell of `[battery payload]`.  The battery holds code; the payload holds data.

`battery`
: A noun (usually a cell of formulas) interpreted as the code part of a core.

`payload`
: The data side of a core.  In compound cores (like doors and gates), the payload subdivides into sample and context.

`sample`
: The argument slot of a gate or door.  Typically lives at address `+6` inside the payload.

`context`
: The lexical environment a core was built in.  Typically lives at address `+7` inside the payload, alongside the sample.

`arm`
: A named Hoon expression compiled into the battery and evaluated against its own enclosing core as subject.

### Core Variants

`gate`
: A core with a single arm named `$`.  Hoon's analogue to a function:  set the sample, evaluate the arm, get a product.

`door`
: A core whose payload is `[sample context]`.  A gate is a degenerate door whose sample isn't set at construction time.

`trap`
: A gate with no sample—a thunk.  Used for recursion and lazy computation.

## Types and Data Shapes

Nock is untyped; these are conventions on top of nouns, used by Hoon and other compilers.

`aura`
: A type annotation for atoms (e.g.  `@ud` for unsigned decimal, `@t` for UTF-8 text, `@p` for a ship name).  Auras have no runtime effect; they tell higher-level languages how to interpret an atom.

`mold`
: A type expressed as a function from noun to noun—a noun that's a member of the mold "bunts" through itself unchanged.  Hoon's type system.

`bunt`
: To produce the default/zero value of a mold.

`loobean`
: Nock's truth values:  `0` is true, `1` is false.  Returned by [opcode 3](specification/opcode-3.ipynb), [opcode 5](specification/opcode-5.ipynb), and consumed by [opcode 6](specification/opcode-6.ipynb).  See [Loobeans](specification/loobeans.md).

`cord`
: An atom interpreted as a little-endian UTF-8 string.

`tape`
: A list of UTF-8 codepoints (each codepoint a cord).  Strings as nouns at the cost of one cell per character.

## Naming and Addressing

`face`
: A name bound to a part of the subject.  Lookups by face resolve at compile time to tree addresses.

`wing`
: A path through the subject—either a face chain (resolving to a leg) or an arm reference.

## Higher-Level Concepts

`rune`
: A two-character ASCII digraph that names a Hoon syntactic construct.  Each rune expands to a Nock pattern.  See [Relationship to Hoon](languages/relationship-to-hoon.md).

`slam`
: To invoke a gate—set the sample, evaluate the `$` arm.

`subject-oriented programming`
: The paradigm Nock uses:  every expression is evaluated against a subject that supplies both its scope and its argument.

`wet-gate`
: A gate that accepts arguments of a type other than what its sample declared, by recompiling its arm against the actual argument's type.

`dry-gate`
: An ordinary gate—accepts only arguments matching its sample's declared type.

`generator`
: A standalone Hoon script meant to be run from a runtime's command line.

`monad`
: The Hoon design pattern for sequencing computations that thread an additional value (state, error, etc.) through each step.

## Meta

`nock`
: The combinator calculus this site describes—Urbit's lowest-level language and the compilation target for Hoon and Jock.

`hoon`
: A higher-order typed functional language that compiles to Nock.  See [Relationship to Hoon](languages/relationship-to-hoon.md).

`vase`
: A runtime pair of `[type noun]`—a noun together with its type.  Hoon uses vases for dynamic evaluation.

`jet`
: A native-code reimplementation of a known Nock formula, swapped in by the runtime for performance.  See [Hints & Jetting](hints-jetting/index.md).

`kelvin`
: Nock's versioning convention:  versions count downward toward zero.  Once at `0K`, the spec is frozen forever.  See [History](history/index.md).
