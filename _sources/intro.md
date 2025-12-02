# Nock

Nock is a computational specification which can be described as an instruction set architecture, a programming language, or a behavior standard.  Nock seeks a balanced minimalism which makes it easy to reason about and prove statements about.  "As simple as viable, and no simpler."

Today, Nock is used as the computational layer for [Urbit](https://urbit.org) and [NockApp](https://zorp.io/blog/nockapp-dev-alpha) (currently shipped as part of [Nockchain](https://www.nockchain.org/)).

This site will interactively teach you about Nock and the high-level languages that compile to it:

* [Hoon](https://docs.urbit.org), an assembly-like systems language (the "C" of Nock).
* [Jock](https://jock.org), a user-friendly scripting language (the "Python" of Nock).

## What is Nock?

Nock is a minimal combinator calculus that serves as the foundation for functional programming systems like Urbit. This tutorial provides multiple perspectives on understanding Nock, from theoretical foundations to practical implementation.

Nock as a computing platform is:

* Turing-complete.  It's a complete real language with all that implies.
* Functional-as-in-language.  Necessary side effects are achieved through runtime hints.  There is no undefined behavior in the specification.
* Homoiconic.  Code and data share the same representation.
* Tiny.  Only twelve opcodes are necessary for the full specification, and first-class virtualization allows this capability to be arbitrarily extended.

Most Nock interpreters have the additional virtue of being:

* Solid-state.  Each evaluation is deterministic and self-contained, resulting in a new updated state with no transient state from crashes or system (mis)configuration.
* Verifiable.  The entire state of a Nock system can be captured in a single data structure, allowing for easy auditing and verification.

## How to Use This Tutorial

The website can be traversed from several starting points, depending on your background:

- [**The Specification**](./content/specification/index.md): Start here to understand the core Nock operations.
- [**Understanding Nock**](./content/understanding/index.md): Start here if you want to start from different mental models to think about Nock.
- [**Code Examples**](./content/examples/index.md): Start here to run and modify interactive examples.

Let's dive in!
