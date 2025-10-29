# Relationship to Hoon

Hoon is a systems programming language designed to compile from a high-level syntax down to Nock code.  Because Hoon and Nock developed in tandem, Hoon is very close to a macro over Nock, and an experienced eye can predict much of the particular Nock noun to which a given Hoon expression will correspond.

To quote the [Hoon docs](https://docs.urbit.org/hoon/why-hoon):

> Subject orientation in Nock ... stems partly from minimalism: there's just one subject, which serves as state, lexical scope, environment, and function argument; partly from a desire to simplify compilation: the type of the subject is a full specification of the compile-time environment for a source file; and partly to give the language a more imperative feel.

## Syntax

Hoon organizes code by “runes”, which are ASCII digraphs that represent syntactic constructs.  Each rune compiles down to a specific Nock pattern, often involving multiple Nock opcodes.

For example, the `:-` colhep rune constructs a cell, compiling directly to a Nock cell over its two daughter nouns as a constant.

```hoon
:-  42
43
```

```nock
[1 42 43]
```

The `?:` rune implements conditional branching, compiling to Nock opcode 6.

```hoon
?:  .?  42
  40
20
```

```nock
[6 [3 1 42] [1 40] 1 20]
```

Compare equality using `.=` tisdot, direct Nock opcode 3.

```hoon
=/  a  42
?:  .=  a  43
  %hello
%world
```

```nock
[8 [1 42] 6 [5 [0 2] 1 43] [1 478.560.413.032] 1 431.316.168.567]
```

More complex runes like `|=` (gate construction) expand into multi-opcode Nock patterns involving core creation and subject manipulation.

The regularity of this mapping means that Hoon code maintains a relatively transparent relationship to its Nock representation, making the compilation process predictable and the language suitable for systems programming where understanding the lower-level execution model is valuable.  (In fact, you can directly obtain the Nock code for any Hoon expression using the `!=` zaptis rune in a Hoon interpreter.)

## Design Patterns

### Cores

Hoon organizes its Nock code into “cores”, which are cells of `[battery payload]`, essentially code and data.  This produces a clean modularity that is easy to reason about, particularly when constructing a runtime system.  Many of the consequences (and peculiar named structures) of Hoon are direct results of this design pattern.

Cores consist of named arms and legs (more or less, functions and data accessors) that can be accessed by name in Hoon but reduce to fixed binary tree addresses in Nock.

```hoon
|%
++  add-two
  |=  x=@
  (add x two)
++  two
  2
--
```

```nock
[[1 [8 [1 0] [1 8 [9 36 0 16.383] 9 2 10 [6 [0 14] 7 [0 3] 9 5 0 7] 0 2] 0 1] 1 2] 0 1]
```

The core structure posts its members as pinned constants, which are selected for and modified by opcode 9 and 10.  The argument to the function, called the “sample”, is changed based on the invocation.

```hoon
=>
  |%
  ++  add-two
  |=  x=@
  (add x two)
  ++  two
  2
  --
(add-two 40)
```

```nock
[8 [1 [8 [1 0] [1 8 [9 36 0 16.383] 9 2 10 [6 [0 14] 7 [0 3] 9 5 0 7] 0 2] 0 1] 1 2] 8 [9 4 0 1] 9 2 10 [6 7 [0 3] 1 40] 0 2]
```

One last note:  the `[battery payload]` pattern is a Hoon convention:  nothing in Nock requires it, not even opcode 9.

### Atoms

Hoon produces untyped Nock, so ultimately all data values must reduce to nouns.  Nock atoms are unsigned integers, so Hoon represents more complex data types (like signed integers, floating-point numbers, and strings) as encoded atoms.  Hoon has a number of affordances to make it easy to work with typed atoms.

For instance, every atom type in Hoon can be written with its own unique syntax.  A date, for instance, cannot be parsed as a floating-point value or an IP address, even in the case in which they all happen to share the same underlying integer representation.

### Head Tags

Hoon frequently uses “head tags” (text constants) to label data structures.  These tags are simply atoms that serve as markers to indicate the type or purpose of a given noun.  This allows Hoon to quickly identify and dispatch on different data types at runtime, despite Nock itself being untyped.  Two simple checks can determine many code branches:  whether a noun is a cell, and what its head is.

### Vases

Hoon uses “vases” as a way to package up Nock code along with metadata about its type and structure.  This allows Hoon to maintain strong typing and structure while still compiling down to the untyped Nock specification.

## Further Reading

* [Hoon Documentation](https://docs.urbit.org/hoon/): The official Hoon documentation provides a comprehensive overview of the language and its relationship to Nock.
* [~rovnys-ricfer (2019), “Why Hoon?”](https://urbit.org/blog/why-hoon): An article discussing the motivations behind Hoon's design and its relationship to Nock.
* [~lagrev-nocfep (2025), “Notes on Vases”](https://urbitsystems.tech/article/v02-i01/notes-on-vases): A detailed exploration of Hoon's vase structure, the compiler's vase mode, and implications for Nock compilation.
