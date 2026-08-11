# Relationship to Jock

[Jock](https://jock.is) is a programming language designed to compile from a high-level syntax down to Nock code.  Jock aims to be more user-friendly and accessible than Hoon, making it easier for developers to write and understand code that compiles to Nock.  In particular, Jock models its syntax on Swift and Rust.

Jock permits direct expression of Nock concepts while providing syntactic sugar to make common patterns easier to write.  This makes Jock a good choice for developers who want to work with Nock without the complexity of Hoon.

At the current time, the [public release of Jock](https://github.com/zorp-corp/jock-lang) is at alpha stage, with [ongoing development by ~lagrev-nocfep](https://github.com/sigilante/jock) to expand its features and capabilities.

## Example

This Jock program:

```jock
var a: Bool = true;
a = false;
a
```

compiles to the following Nock code:

```nock
[8 [1 0] 7 [10 [2 1 1] 0 1] 0 2]
```

More examples are available [at the Jock site](https://jock.is).

## Further Reading

* [Jock Documentation](https://jock.is): The Jock landing page provides a brief overview of the language and its relationship to Nock.
* [Jock GitHub Repository](https://github.com/zorp-corp/jock-lang): The original GitHub repository.
* [Jock Recommenced GitHub Repository](https://github.com/sigilante/jock): The new GitHub repository (currently private).
