# Defining Nock

Nock consists of only twelve opcodes based on a few axiomatic operators for addressing and equality, etc.  The quip is that it's small enough to fit on a T-shirt—and you can find such T-shirts in circulation!  This situates it in complexity somewhere higher than a lambda calculus or SKI combinator and somewhere lower than an assembly language.

Everything in Nock is a noun, which means it is an unsigned integer ("atom") or a pair of nouns ("cell").  This means that all nouns are binary trees (which gives us some nice properties).  Code and data share the same basic language of nouns, but code means something specific in structure while data can be arbitrary.

* **Code** consists of a _formula_ (expression made up of opcodes and data) evaluated against a _subject_ (operating context).

* **Data** means any noun, which can resolve to a structured tree of values (like XML or JSON), a large number (intepreted as a byte array), or even deferred code for future evaluation.

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

The current specification for Nock is 4K, meaning that only four possible revisions are possible.

Other online versions of the specification match the above but provide additional perspectives and commentary.

- [Urbit:  What is Nock?](https://docs.urbit.org/nock/what-is-nock)
- [Zorp:  Nock Definition](https://zorp.io/nock/)

## Commentary

A formula that reduces to itself is an infinite loop, which we define as a crash (“bottom” in formal logic). A real interpreter can detect this crash and produce an out-of-band value instead.

