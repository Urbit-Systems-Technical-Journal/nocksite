# Relationship to Hoon

[Hoon](https://docs.urbit.org/hoon/) is a systems programming language designed to compile from a high-level syntax down to Nock code.  Because Hoon and Nock developed in tandem, Hoon is very close to a macro over Nock, and an experienced eye can predict much of the particular Nock noun to which a given Hoon expression will correspond.

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

Compare equality using `.=` dottis, direct Nock opcode 5.  The `=/` tisfas rune names a value by pushing it onto the subject with opcode 8, so the name becomes an address.

```hoon
=/  a  42
?:  .=  a  43
  %hello
%world
```

```{nockmark}
[8 {{[1 42]|a}}
%% note a `=/  a  42`: push 42, so the subject is `[42 S]` and *a* is at 2
   6 {{[5 [0 2] 1 43]|t}}
%% note t `.=  a  43`: opcode 5 compares *a* (address 2) with 43
     {{[1 478.560.413.032]|y}}
%% note y yes: `%hello`, a text constant, is just this atom
     {{1 431.316.168.567|n}}]
%% note n no: `%world`, the result here, since 42 is not 43
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

```{nockmark}
[{{[1 <B>]|bat}} {{0 1|pay}}]
%% note bat `|%`: the battery *B*, as a constant
%% below pay the payload, the subject *S*: the core is `[B S]`
%% skip
<B> = [{{<A>|arm}}
%% note arm `++  add-two`: address 4 of the core
       {{1 2|two}}]
%% note two `++  two`: address 5 of the core, the formula `[1 2]`
%% skip
<A> = [8 {{[1 0]|sam}}
%% note sam `|=  x=@`: push the sample's default value, 0
       {{[1 <G>]|g}}
%% note g the gate's battery *G*, as a constant
       {{0 1|gp}}]
%% note gp with `[0 core]`: the gate is `[G 0 core]`, and *x* is at 6
%% skip
<G> = [8 {{[9 36 0 16.383]|add}}
%% note add `add`: build the standard library's gate, deep in the context
         9 2 10 [6 {{[0 14]|x}}
%% note x the new sample's head: *x*, at 14 with `add` pushed in front
                   {{7 [0 3] 9 5 0 7|tw}}]
%% note tw its tail: `two`, from the gate (now at 3), arm 5 of its core at 7
         {{0 2|slam}}]
%% note slam edit the sample of `add` (address 2), then run its arm 2
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

```{nockmark}
[8 {{[1 <B>]|core}}
%% note core `=>` and `|%`: push the battery, so the subject is the core `[B S]`
   8 {{[9 4 0 1]|gate}}
%% note gate `add-two`: run arm 4, which builds the gate: `[gate B S]`
   9 2 10 [6 {{7 [0 3] 1 40|arg}}]
%% note arg the sample `40`, computed against the core (address 3)
   {{0 2|g}}]
%% note g edit it into the gate (address 2), then run the gate's arm 2
```

*B* is the battery from the previous example.  The argument is compiled against the core, not against the gate pushed in front of it, which is why it sits under `[7 [0 3] ...]` even though a constant does not need it.

When you invoke an arm at axis `n` in a core, the Nock computation is essentially `[9 n [0 1]]`—take the formula at axis `n` and evaluate it with the entire core as the subject.

The **battery** is a tree of Nock formulas, each identified by an axis position. These formulas are the “arms” of the core—named computations that can be invoked at need.  Each arm is computed with the entire core as its subject, giving it access to both the code (other arms) and data (payload) of the core.

The **payload** contains the data and context for the battery's operation. It includes the **sample**, or arguments, and the **context**, or overall subject provided such as the standard library.

### A gate, rune by rune

The [urbit/benchmark](https://github.com/urbit/benchmark) suite compiles small Hoon programs to Nock with `!=`.  Its `dec` program carries its own copy of the standard library's `++dec`, which decrements by counting up from zero:

```{nockmark}
:language: hoon
{{|=  a=@|gate}}
%% note gate a gate: the core `[battery [a context]]`, with *a* at address 6
{{?<  =(0 a)|assert}}
%% note assert opcode 6 on `[5 [1 0] 0 6]`: crash with `[0 0]` if *a* is 0
{{=+  b=0|push}}
%% note push opcode 8: push *b* = 0 onto the subject
{{|-|trap}}  ^-  @
%% note trap a trap: push a one-arm core and run it with `[9 2 0 1]`
?:  {{=(a +(b))|test}}  b
%% note test opcode 6 on `[5 [0 30] 4 0 6]`: is *a* equal to *b* + 1?
{{$(b +(b))|again}}
%% note again `[9 2 10 [6 4 0 6] 0 1]`: edit *b* and run the trap again
```

Here is the arm that builds this gate, exactly as it appears in the benchmark's compiled `dec.nock`.  The cast `^-  @` produces no Nock at all.

```{nockmark}
[8 {{[1 0]|sam}}
%% note sam `|=  a=@`: push the sample's default value, 0
   {{[1 <D>]|bat}}
%% note bat the gate's battery *D*, as a constant
   {{0 1|pay}}]
%% note pay with the payload `[0 C]`: the gate is `[D 0 C]`
%% skip
<D> = [6 {{[5 [1 0] 0 6]|z}}
%% note z `?<  =(0 a)`: is the sample *a* (address 6) zero?
         {{[0 0]|crash}}
%% note crash yes: address 0 does not exist, so this crashes
         8 {{[1 0]|b}}
%% note b `=+  b=0`: the subject is `[0 D a C]`, *b* at 2 and *a* at 14
         8 {{[1 <L>]|trap}}
%% note trap `|-`: push the battery *L*: the core is `[L 0 D a C]`
         {{9 2 0 1|go}}]
%% note go run arm 2 of that core, which is *L*
%% skip
<L> = [6 {{[5 [0 30] 4 0 6]|t}}
%% note t `=(a +(b))`: *a* is at 30 and *b* at 6 in the trap's core
         {{[0 6]|y}}
%% note y yes: produce *b*
         {{9 2 10 [6 4 0 6] 0 1|n}}]
%% note n `$(b +(b))`: put *b* + 1 at 6 and run arm 2 of the edited core
```

`C` is the core the arm lives in.  The gate, the trap and the loop are all the same Nock pattern, a battery pinned in front of the subject.  A gate keeps a sample slot at 6 for its caller to fill; a trap runs at once.  The call `(dec m)` fills that slot:

```{nockmark}
[8 {{[9 5 0 1]|build}}
%% note build run the arm above (arm 5 here), pushing the gate: `[gate core]`
   9 2 10 [6 {{0 7|m}}]
%% note m the new sample: `m`, the core's payload (at 3 in the core, so 7)
   {{0 2|g}}]
%% note g edit it into the gate (address 2), then run the gate's arm 2
```

One last note:  the `[battery payload]` pattern is a Hoon convention:  nothing in Nock requires it, not even opcode 9.

### Atoms

Hoon produces untyped Nock, so ultimately all data values must reduce to nouns.  Nock atoms are unsigned integers, so Hoon represents more complex data types (like signed integers, floating-point numbers, and strings) as encoded atoms.  Hoon has a number of affordances to make it easy to work with typed atoms.

For instance, every atom type in Hoon can be written with its own unique syntax.  A date, for instance, cannot be parsed as a floating-point value or an IP address, even in the case in which they all happen to share the same underlying integer representation.

```hoon
:: as time
> ~m42
~m42

:: as uint
> `@`~m42
46.485.795.065.748.070.072.320

:: as hex
> `@ux`~m42
0x9d8.0000.0000.0000.0000
```

All of these reduce to the Nock noun `46.485.795.065.748.070.072.320`.

### Head Tags

Hoon frequently uses “head tags” (text constants) to label data structures.  These tags are simply atoms that serve as markers to indicate the type or purpose of a given noun.  This allows Hoon to quickly identify and dispatch on different data types at runtime, despite Nock itself being untyped.  Two simple checks can determine many code branches:  whether a noun is a cell, and what its head is.

### Vases

Hoon uses "vases" as a way to package up Nock code along with metadata about its type and structure. A vase is a cell of `[type value]` where the type is itself a Nock noun representing Hoon's type information.

This allows Hoon to maintain strong typing and structure while still compiling down to the untyped Nock specification. The type information in a vase enables:

* Runtime type checking and validation.
* Dynamic code generation with type safety.
* Metaprogramming with full type awareness.
* Safe composition of separately-compiled code.

Vases are particularly important in Hoon's compilation model, where the compiler itself operates on vases to type-check and transform code, maintaining the invariant that typed Hoon expressions correspond to correctly-typed Nock nouns.

## Further Reading

* [Hoon Documentation](https://docs.urbit.org/hoon/): The official Hoon documentation provides a comprehensive overview of the language and its relationship to Nock.
* [~rovnys-ricfer (2019), “Why Hoon?”](https://urbit.org/blog/why-hoon): An article discussing the motivations behind Hoon's design and its relationship to Nock.
* [~lagrev-nocfep (2025), “Notes on Vases”](https://urbitsystems.tech/article/v02-i01/notes-on-vases): A detailed exploration of Hoon's vase structure, the compiler's vase mode, and implications for Nock compilation.
