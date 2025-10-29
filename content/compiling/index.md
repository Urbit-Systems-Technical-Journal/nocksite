# Languages

Nock is Turing-complete, but as you've probably come to realize, it's not exactly a “programming” language:  it's too abstruse and economical to be used directly for most programming tasks.  Instead, Nock is best thought of as a compilation target for higher-level languages.

At the current time, the high-level languages under most active development that target Nock are Hoon and Jock.  There is also an Urwasm Nock compatibility layer for executing WebAssembly code on a Nock runtime.

- [Hoon](../compiling/relationship-to-hoon.md) is a mature systems programming language with much syntax and flexibility.
- [Jock](../compiling/relationship-to-jock.md) is a scripting language designed as a more developer-friendly alternative to Hoon.

There have also been a few experimental compilers built to play with language concepts:

- [Hick by ~tacryt-socryp](https://gist.github.com/tacryt-socryp/b08dc66b7bcc760e914c4db5c9fd7ba7)
- [Loon by ~fodwyt-ragful](https://github.com/frodwith/loon)
