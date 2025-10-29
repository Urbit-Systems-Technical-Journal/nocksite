# Relationship to Jock

Jock is a scripting language designed to compile from a high-level syntax down to Nock code.  Jock aims to be more user-friendly and accessible than Hoon, making it easier for developers to write and understand code that compiles to Nock.  In particular, Jock models its syntax on Swift and Rust.

Jock permits direct expression of Nock concepts while providing syntactic sugar to make common patterns easier to write.  This makes Jock a good choice for developers who want to work with Nock without the complexity of Hoon.

At the current time, Jock is in its alpha release stage, with ongoing development to expand its features and capabilities.

## Example

This Jock program:

```jock
let a: ? = true;
a = false;
a
```

compiles to the following Nock code:

```nock
[8 [1 0] 7 [10 [2 1 1] 0 1] 0 2]
```

## Further Reading

* [Jock Documentation](https://docs.jock.org): The official Jock documentation provides a comprehensive overview of the language and its relationship to Nock.
* [Jock GitHub Repository](https://github.com/zorp-corp/jock-lang): The official GitHub repository.
