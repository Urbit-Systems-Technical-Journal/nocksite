# Composite Opcodes

The composite opcodes combine multiple operations into higher-level constructs.  These opcodes enable conditional logic, function composition, subject manipulation, and computation dispatch, which are affordances necessary for practical programming in Nock.

| Opcode | Name | Signature | Purpose |
| ------ | ---- | --------- | ------- |
| [`6`](opcode-6.ipynb) | [If](opcode-6.ipynb) | `[6 b c d]` | Conditional branch |
| [`7`](opcode-7.ipynb) | [Compose](opcode-7.ipynb) | `[7 b c]` | Sequential/pipe |
| [`8`](opcode-8.ipynb) | [Extend](opcode-8.ipynb) | `[8 b c]` | Pin to subject |
| [`9`](opcode-9.ipynb) | [Invoke](opcode-9.ipynb) | `[9 b c]` | Core arm call |
| [`11`](opcode-11.ipynb) | [Hint](opcode-11.ipynb) | `[11 b c]`/`[11 [b c] d]` | Interpreter hint |
