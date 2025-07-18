# Defining Nock

Nock consists of only twelve opcodes based on a few axiomatic operators for addressing and equality, etc.  The quip is that it's small enough to fit on a T-shirt—and you can find such T-shirts in circulation!  This situates it in complexity somewhere higher than a lambda calculus or SKI combinator and somewhere lower than an assembly language.

We'll dig into these in detail as we move along, but let's start with—

##  The Spec

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

The current specification for Nock is 4K, meaning that only four possible revisions are possible.{footnote}`See ~lagrev-nocfep and ~sorreg-namtyv (2025) for the history of Nock.`


## Commentary

While we defer the opcode discussion to our "Understanding Nock" section, the operators merit some explanation.

### Addressing

Everything in Nock is a noun, which means it is an unsigned integer ("atom") or a pair of nouns ("cell").  This means that all nouns are binary trees (which gives us some nice properties).  Code and data share the same basic language of nouns, but code means something specific in structure while data can be arbitrary.

* **Code** consists of a _formula_ (expression made up of opcodes and data) evaluated against a _subject_ (operating context).

* **Data** means any noun, which can resolve to a structured tree of values (like XML or JSON), a large number (intepreted as a byte array), or even deferred code for future evaluation.

```
[a b c]             [a [b c]]
```

For convenience, we omit right-hand cell brackets in our notation.  (Nock branches to the right _a lot_ and so this saves us from Lisp-style end-paren piles.)

```
+[a b]              +[a b]
+a                  1 + a
```

We can increment atoms, but not cells (which makes sense).  Every natural number (atom) has a successor, so there is no possible crash here (as long as our interpreter actually supports arbitrarily sized integers).

```
/[1 a]              a
/[2 a b]            a
/[3 a b]            b
/[(a + a) b]        /[2 /[a b]]
/[(a + a + 1) b]    /[3 /[a b]]
/a                  /a
```

TODO

One implication of nouns is that an easy way to tell data apart is by their structure:

```
?[a b]              0
?a                  1

=[a a]              0
=[a b]              1
```

`?` wut is useful to ask whether a given noun is a cell or an atom.  (Like C's `int main()` return type and error codes, `0` means `TRUE` and `1` means `FALSE`.)

`=` tis similarly checks whether two nouns are the same as each other, which means by structure and value.

### Evaluating

The last line of the Nock specification reads:

```
*a                  *a
```

What this means is that a formula which reduces to itself continues to do so, i.e. becomes an infinite loop or "bottom".  The Nock interpreter should detect this "crash" and yield the result instead of spinning on it forever.

### What's Missing?

Nock is mathematically complete, but it doesn't seem to have many affordances that programmers expect from a language.  Nock leaves some pragmatic elements of programming and the computer environment to its evaluator, or runtime environment.

- Boolean logic (`AND`, `XOR`, `NOT`, etc.) must be implemented out of Nock primitives rather than being axiomatically supplied as operators.
- Side effects (like printing) will be handled by raising special noun patterns to the Nock evaluator.
- Memory is entirely handled by the Nock evaluator.
- Evaluation rules are defined, but their implementation is omitted.  You can use a tree-walking interpreter, a bytecode interpreter, or something even more clever to run Nock in practice.  (In fact, you can treat Nock as a spec and not run it at all, as long as you get the same answer!)


## Evaluating Nock

So much for the specification itself, but what does it _mean_?  You can treat it like a puzzle and work things out yourself, but we've also prepared several complementary approaches to Nock.  Start with one that best fits your background.

1. [ The Combinator Approach](../understanding/combinator-approach.ipynb)
2. [ The Turing Machine Approach](../understanding/turing-machine-approach.ipynb)
3. [ The Lambda Calculus Approach](../understanding/lambda-approach.ipynb)
4. [ The Assembly Language Approach](../understanding/assembly-language-approach.ipynb)
5. [ The Cellular Automaton Approach]()


## Resources

Other online versions of the specification match the above but provide additional perspectives and commentary.  Check them out, too.

- [Urbit:  What is Nock?](https://docs.urbit.org/nock/what-is-nock)
- [Zorp:  Nock Definition](https://zorp.io/nock/)
