# Relationship to North

[North](https://github.com/sigilante/north) (Nock Forth) is a Forth interpreter for Nock by ~lagrev-nocfep, aiming for broad ANSI-Standard-flavored Forth compatibility while adapting memory-bound features to Nock's noun model.  Forth is a concatenative, stack-based language:  words consume and produce values on a shared data stack, definitions compose by juxtaposition, and the interpreter and compiler are simple enough to bootstrap from a few hundred lines of primitives.

North runs interactively as a REPL on a live Urbit ship and can be driven from a Jupyter notebook via [Jupytur](https://github.com/sigilante/jupytur), demonstrating that stack-based concatenative languages map cleanly onto a Nock host.

North is written in Hoon as a standalone library and runs as a Gall `%shoe` agent on an Urbit ship, providing a persistent REPL with the usual Forth state:  data stack, return stack, dictionary, input buffer, and compile/interpret mode.  North supports stack and arithmetic operators, control flow, defining words (`CREATE`/`DOES>`), counted loops, exceptions (`CATCH`/`THROW`), strings, `CASE`/`OF`/`ENDOF`/`ENDCASE`, and `IMMEDIATE` words.

North's relationship to Nock is indirect:  Forth source executes through a Hoon-written interpreter, which itself compiles to Nock.

## Example

A North session at the dojo REPL:

```forth
2 3 + .         \ prints 5
: SQUARE DUP * ;
5 SQUARE .      \ prints 25
```

`: SQUARE DUP * ;` adds an entry to the dictionary with body `DUP *`.

## Further Reading

* [North GitHub Repository](https://github.com/sigilante/north):  Hoon implementation, test suite, and Gall agent.
