# Basic Opcodes

The basic opcodes provide fundamental operations on nouns: addressing into tree structures, creating constants, evaluation, structure checking, arithmetic, comparison, and editing. These are the primitive building blocks upon which the composite opcodes are constructed.

| Opcode | Name | Signature | Purpose |
| ------ | ---- | --------- | ------- |
| [`0`](opcode-0.ipynb) | [Slot](opcode-0.ipynb) | `[0 b]` | Tree address lookup. |
| [`1`](opcode-1.ipynb) | [Constant](opcode-1.ipynb) | `[1 b]` | Return literal value. |
| [`2`](opcode-2.ipynb) | [Evaluate](opcode-2.ipynb) | `[2 b c]` | Dynamic nock. |
| [`3`](opcode-3.ipynb) | [Cell?](opcode-3.ipynb) | `[3 b]` | Test if cell. |
| [`4`](opcode-4.ipynb) | [Increment](opcode-4.ipynb) | `[4 b]` | Add 1 to atom. |
| [`5`](opcode-5.ipynb) | [Equal?](opcode-5.ipynb) | `[5 b c]` | Deep equality test. |
| [`10`](opcode-10.ipynb) | [Edit](opcode-10.ipynb) | `[10 [b c] d]` | Functional update |
|   | [Cell Distribution](cell-distribution.ipynb)   | `[*[a b c] *[a d]]`  |   |
