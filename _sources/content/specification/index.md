# Defining Nock

Nock consists of only twelve opcodes based on a few axiomatic operators for addressing and equality, etc.  The quip is that it's small enough to fit on a T-shirt—and you can find such T-shirts in circulation!  This situates it in complexity somewhere higher than a lambda calculus or SKI combinator and somewhere lower than an assembly language.

Before examining the specification, let's briefly coer a couple of core principle of Nock evaluation.  Nock is a pure function from noun to noun. The evaluation function `*` takes a pair (or “cell”) `[subject formula]` and produces a product.  That is,

* Subject:  the data environment (analogous to scope or context).
* Formula:  the code to execute (always a cell with an opcode head).
* Product:  the result of evaluation.

All data in Nock is a noun:

* An _atom_ is any natural number (`0`, `1`, `2`, `3`, ...).
* A _cell_ is an ordered pair of nouns: `[noun noun]`.

There are no types in the classical sense, only structure.  Every noun is a binary tree, and code and data share the same representation.

* [Deep Nock](deep-nock.md) provides more context on Nock's design goals.

##  The Specification

The official definition of Nock is rather briefly expressed:

```
Nock 4K

A noun is an atom or a cell. An atom is a natural number. A cell is an ordered pair of nouns.

Reduce by the first matching pattern; variables match any noun.

nock(a)             *a
[a b c]             [a [b c]]

?[a b]              0
?a                  1
+[a b]              +[a b]
+a                  1 + a
=[a a]              0
=[a b]              1

/[1 a]              a
/[2 a b]            a
/[3 a b]            b
/[(a + a) b]        /[2 /[a b]]
/[(a + a + 1) b]    /[3 /[a b]]
/a                  /a

#[1 a b]            a
#[(a + a) b c]      #[a [b /[(a + a + 1) c]] c]
#[(a + a + 1) b c]  #[a [/[(a + a) c] b] c]
#a                  #a

*[a [b c] d]        [*[a b c] *[a d]]

*[a 0 b]            /[b a]
*[a 1 b]            b
*[a 2 b c]          *[*[a b] *[a c]]
*[a 3 b]            ?*[a b]
*[a 4 b]            +*[a b]
*[a 5 b c]          =[*[a b] *[a c]]

*[a 6 b c d]        *[a *[[c d] 0 *[[2 3] 0 *[a 4 4 b]]]]
*[a 7 b c]          *[*[a b] c]
*[a 8 b c]          *[[*[a b] a] c]
*[a 9 b c]          *[*[a c] 2 [0 1] 0 b]
*[a 10 [b c] d]     #[b *[a c] *[a d]]

*[a 11 [b c] d]     *[[*[a c] *[a d]] 0 3]
*[a 11 b c]         *[a c]

*a                  *a
```

The current specification for Nock is 4K, meaning that only four possible revisions remain.  (See [History](../history/index.md) for more details.)

## Commentary

### Axiomatic Operators

The preface of the Nock specification defines several axiomatic operators that describe the behavior of the Nock opcodes.  These are:

- `*` tar, which evaluates a Nock expression.
- `?` wut, which tests whether a noun is a cell or an atom.
- `+` lus, which increments an atom and has no effect on cells (in practice, crashes).
- `=` tis, which tests whether two nouns are equal.
- `/` fas, which addresses a noun by a numeric address.
- `#` hax, which edits a cell.

These will be discussed in detail with the opcodes that implement them.

### Nouns

As mentioned above, everything in Nock is a noun, which means it is an unsigned integer (“atom”) or a pair of nouns (“cell”).  This means that all nouns are binary trees (which gives us some nice properties).  Code and data share the same basic language of nouns, but code means something specific in structure while data can be arbitrary.

* **Code** consists of a _formula_ (expression made up of opcodes and data) evaluated against a _subject_ (operating context).

* **Data** means any noun, which can resolve to a structured tree of values (like XML or JSON), a large number (intepreted as a byte array), or even deferred code for future evaluation.

### Evaluating

> A valid Nock formula is always a cell.  If the head of the formula is a cell, Nock treats both head and tail as formulas, resolves each against the subject, and produces the cell of their products.  In other words, the Lisp program `(cons x y)` becomes the Nock formula `[x y]`.  ([docs.urbit.org](https://docs.urbit.org/nock/definition))

Nock evaluation continues until a noun is reached that is not a formula (i.e., it does not result in an axiomatic operator including `*` tar).  This noun is then the result of the evaluation.

Nock evaluation is formally Turing-complete but will be quite verbose for many tasks.  Even with higher-level abstractions, the resulting nouns may be impractical to compute in a reasonable amount of time.  Thus Nock can be treated as a formal specification of behavior, with [jet-accelerated code](../hints-jetting/index.md) providing enormous performance improvements.

### Crashing

The last line of the Nock specification reads:

```nock
*a                  *a
```

What this means is that a formula which reduces to itself continues to do so, i.e. becomes an infinite loop or “bottom” in formal logic.  Practical interpreters detect these and halt.

## Approaching Nock

So much for the specification itself, but what does it _mean_?  You can treat it like a puzzle and work things out yourself, but we've also prepared several complementary approaches to Nock.  Start with one that best fits your background.

1. [ The Combinator Approach](../understanding/combinator-approach.ipynb)
<!-- 2. [ The Turing Machine Approach](../understanding/turing-machine-approach.ipynb) -->
3. [ The Lambda Calculus Approach](../understanding/lambda-approach.ipynb)
4. [ The Assembly Language Approach](../understanding/assembly-language-approach.ipynb)
<!-- 5. [ The Cellular Automaton Approach](../understanding/cellular-automaton-approach.ipynb) -->
<!-- 5. [The Alchemy Approach](../understanding/alchemy-approach.ipynb) -->


## References

Other online versions of the specification match the above but provide additional perspectives and commentary.  Check them out, too.

- [Urbit:  What is Nock?](https://docs.urbit.org/nock/what-is-nock)
- [Zorp:  Nock Definition](https://zorp.io/nock/)
