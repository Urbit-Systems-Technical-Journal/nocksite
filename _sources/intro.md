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
* Functional-as-in-language.  Necessary side effects are achieved through runtime hints.
* Homoiconic.  Code and data share the same representation.
* Solid-state.  Each evaluation is deterministic and self-contained, resulting in a new updated state with no transient state from crashes or system (mis)configuration.
* Tiny.  Only twelve opcodes are necessary for the full specification, and first-class virtualization allows this capability to be arbitrarily extended.

## How to Use This Tutorial

- [**The Specification**](./content/specification/index.md): Start here to understand the core Nock operations
- [**Understanding Nock**](./content/understanding/index.md): Explore different mental models for thinking about Nock
- [**Code Examples**](./content/examples/index.md): Interactive examples you can run and modify
- [**Compiling**](./content/compiling/index.md): How higher-level languages compile to Nock
- [**Side Effects**](./content/hints-jetting/index.md): Side effects and performance optimization techniques

Let's begin!
