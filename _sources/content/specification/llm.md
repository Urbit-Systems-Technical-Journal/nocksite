# Nock Opcode Reference (Nock 4K)

> A comprehensive guide to Nock's twelve opcodes, designed for both human understanding and LLM processing.

## Foundational Concepts

Before examining individual opcodes, understand these core principles:

### The Nock Evaluation Model

Nock is a pure function from **noun** to **noun**. The evaluation function `*` (pronounced "nock") takes a cell `[subject formula]` and produces a **product**:

- **Subject**: The data environment (analogous to scope/context)
- **Formula**: The code to execute (always a cell with an opcode head)
- **Product**: The result of evaluation

```
*[subject formula] → product
```

### Data Model: Nouns

All data in Nock is a **noun**:
- An **atom** is any natural number (0, 1, 2, 3, ...)
- A **cell** is an ordered pair of nouns: `[noun noun]`

There are no other types. Strings, lists, trees, code—everything is nouns.

### Tree Addressing

Nouns form binary trees. Every position has an address:

```
        1           (root)
       / \
      2   3         (head, tail)
     / \ / \
    4  5 6  7
   /\
  8  9
```

- Address 1 is the root (entire noun)
- Address 2 is the head (left child)
- Address 3 is the tail (right child)
- Address 2n is head of node n
- Address 2n+1 is tail of node n

### Boolean Convention

- `0` = yes/true
- `1` = no/false

This follows Unix convention (0 for success).

### Crash Semantics

Nock is "crash-only." Invalid operations (incrementing a cell, addressing into an atom) don't throw exceptions—they cause non-termination. Practical interpreters detect these and halt.

---

## Primitive Opcodes (0–5)

These six opcodes provide Turing-complete computation. Everything else is syntactic sugar.

---

## Opcode 0: Slot (Tree Addressing)

### Formal Definition
```
*[subject 0 b] → /[b subject]
```

### Human Description
Retrieve the noun at address `b` within the subject. This is Nock's fundamental data access operation—the only way to read from the subject.

### Detailed Behavior
- `b` must be a positive atom (the address)
- Returns the subtree at that address in the subject
- Crashes if the address doesn't exist (e.g., addressing into an atom)

### Examples

```nock
*[[10 20] 0 1]     → [10 20]     :: Address 1 = entire subject
*[[10 20] 0 2]     → 10          :: Address 2 = head
*[[10 20] 0 3]     → 20          :: Address 3 = tail
*[[[1 2] 3] 0 4]   → 1           :: Address 4 = head of head
*[[[1 2] 3] 0 5]   → 2           :: Address 5 = tail of head
*[[1 [2 3]] 0 7]   → 3           :: Address 7 = tail of tail
```

### Common Patterns

| Address | Meaning | Hoon Equivalent |
|---------|---------|-----------------|
| `[0 1]` | Entire subject | `.` |
| `[0 2]` | Head (battery of core) | `-` or `+2` |
| `[0 3]` | Tail (payload of core) | `+` or `+3` |
| `[0 6]` | Sample of gate | `+6` |
| `[0 7]` | Context of gate | `+7` |

### LLM Implementation Notes
- Always validate that `b` is a positive atom
- Implement tree traversal: even addresses go left, odd go right
- Return crash/bottom for invalid addresses

---

## Opcode 1: Constant (Quote)

### Formal Definition
```
*[subject 1 b] → b
```

### Human Description
Return `b` unchanged, completely ignoring the subject. This is how you embed literal values in Nock code.

### Detailed Behavior
- The subject is entirely ignored
- `b` is returned as-is (not evaluated)
- Works for any noun `b` (atom or cell)

### Examples

```nock
*[999 1 42]        → 42          :: Ignores subject, returns constant
*[[1 2] 1 [3 4]]   → [3 4]       :: Returns cell constant
*[0 1 0]           → 0           :: Even 0 works as a constant
*[42 1 [0 1]]      → [0 1]       :: Returns formula literally (not evaluated)
```

### Common Patterns

Opcode 1 is essential for:
- Embedding literal data in formulas
- Quoting code that should not be evaluated
- Building data structures within computations

```nock
:: Build a cell of constants
*[x [[1 10] [1 20]]]  → [10 20]    :: Distribution + constants
```

### LLM Implementation Notes
- Simplest opcode: just return the argument
- No subject access, no evaluation
- Critical for constructing values and quoting formulas

---

## Opcode 2: Evaluate (Nock)

### Formal Definition
```
*[subject 2 b c] → *[*[subject b] *[subject c]]
```

### Human Description
The "eval" of Nock. Compute a new subject from formula `b`, compute a new formula from formula `c`, then nock the results together. This enables dynamic code execution and is how Nock achieves Turing completeness.

### Detailed Behavior
1. Evaluate `b` against the subject → produces a noun (new subject)
2. Evaluate `c` against the subject → produces a noun (new formula)
3. Evaluate the new formula against the new subject → final product

### Examples

```nock
:: Simple: constant subject, constant formula
*[42 2 [1 100] [1 [0 1]]]
  → *[100 [0 1]]           :: Compute *[100 0 1]
  → 100                     :: Returns the subject

:: Dynamic formula selection
*[[5 [4 0 1]] 2 [0 2] [0 3]]
  → *[5 [4 0 1]]           :: New subject is 5, formula is [4 0 1]
  → 6                       :: Increment 5

:: Self-application (Y-combinator style)
*[[[4 0 1] 42] 2 [0 3] [0 2]]
  → *[42 [4 0 1]]          :: Apply increment formula to 42
  → 43
```

### Common Patterns

Opcode 2 is the foundation for:
- Function calls
- Code generation and metaprogramming
- Implementing higher-order patterns

```nock
:: Pattern: Apply a stored formula to data
*[[formula data] 2 [0 3] [0 2]]  :: Apply formula at +3 to data at +2
```

### LLM Implementation Notes
- This is recursive: both `b` and `c` are formulas that must be evaluated
- The inner evaluations happen first, then the outer nock
- Be careful with evaluation order: left-to-right for the inner nocks
- This is where infinite loops typically originate

---

## Opcode 3: Cell Test (Is Cell?)

### Formal Definition
```
*[subject 3 b] → ?*[subject b]
```

Where `?` is the cell test operator:
```
?[a b] → 0    (cells are true)
?a     → 1    (atoms are false)
```

### Human Description
Test whether the product of formula `b` is a cell or an atom. Returns `0` (yes) if it's a cell, `1` (no) if it's an atom.

### Detailed Behavior
1. Evaluate `b` against the subject → produces a noun
2. Test if that noun is a cell
3. Return `0` if cell, `1` if atom

### Examples

```nock
*[[1 2] 3 [0 1]]   → 0      :: [1 2] is a cell
*[42 3 [0 1]]      → 1      :: 42 is an atom
*[[1 2] 3 [0 2]]   → 1      :: Head of [1 2] is 1, an atom
*[[[1 2] 3] 3 [0 2]] → 0    :: Head is [1 2], a cell
```

### Common Patterns

Opcode 3 is used for:
- Type discrimination (before pattern matching)
- Conditional logic based on structure
- Validating data shapes

```nock
:: Pattern: Check if slot contains a cell
*[data [3 [0 n]]]  :: Is the noun at address n a cell?
```

### LLM Implementation Notes
- Simple boolean test after evaluation
- Remember: 0 means "yes, it's a cell"
- Often combined with opcode 6 for branching

---

## Opcode 4: Increment

### Formal Definition
```
*[subject 4 b] → +*[subject b]
```

Where `+` is the increment operator:
```
+a → 1 + a    (for atoms only)
+[a b] → crash
```

### Human Description
Add 1 to the product of formula `b`. This is Nock's only arithmetic primitive—all other arithmetic must be built from increment.

### Detailed Behavior
1. Evaluate `b` against the subject → must produce an atom
2. Return that atom plus 1
3. Crashes if the product is a cell

### Examples

```nock
*[42 4 [0 1]]      → 43     :: Increment the subject
*[[10 20] 4 [0 2]] → 11     :: Increment the head
*[0 4 [0 1]]       → 1      :: Increment zero
*[[1 2] 4 [0 1]]   → crash  :: Can't increment a cell
```

### Common Patterns

```nock
:: Double increment
*[5 [4 [4 [0 1]]]]  → 7

:: Increment a constant
*[x [4 [1 99]]]     → 100
```

### Arithmetic Note

Since increment is the only arithmetic operation:
- Decrement requires counting up from 0
- Addition is repeated increment
- All arithmetic is theoretically O(n) or worse

In practice, interpreters "jet" (accelerate) known arithmetic patterns.

### LLM Implementation Notes
- Must validate product is an atom before incrementing
- This is a crash point for type errors
- Foundation for all numeric computation

---

## Opcode 5: Equality Test

### Formal Definition
```
*[subject 5 b c] → =[*[subject b] *[subject c]]
```

Where `=` is the equality test:
```
=[a a] → 0    (equal → true)
=[a b] → 1    (not equal → false)
```

### Human Description
Test whether the products of formulas `b` and `c` are structurally identical. Returns `0` if equal, `1` if not.

### Detailed Behavior
1. Evaluate `b` against the subject → noun X
2. Evaluate `c` against the subject → noun Y
3. Return `0` if X and Y are identical nouns, `1` otherwise

Equality is deep structural comparison: two cells are equal iff their heads are equal and their tails are equal.

### Examples

```nock
*[[5 5] 5 [0 2] [0 3]]     → 0      :: 5 equals 5
*[[5 6] 5 [0 2] [0 3]]     → 1      :: 5 doesn't equal 6
*[42 5 [0 1] [1 42]]       → 0      :: Subject equals constant 42
*[[[1 2] [1 2]] 5 [0 2] [0 3]] → 0  :: Deep equality works
```

### Common Patterns

```nock
:: Pattern: Check if value equals a constant
*[x [5 [0 1] [1 target]]]   :: Does x equal target?

:: Pattern: Compare two slots
*[data [5 [0 a] [0 b]]]     :: Do slots a and b hold equal values?
```

### LLM Implementation Notes
- Deep structural comparison, not pointer equality
- Both arguments are formulas (must be evaluated first)
- Essential for conditional branching (combined with opcode 6)

---

## Macro Opcodes (6–11)

Opcodes 6–11 are "sugar"—they can be expressed in terms of opcodes 0–5 but exist for efficiency and convenience.

---

## Opcode 6: Conditional (If-Then-Else)

### Formal Definition
```
*[subject 6 b c d] → *[subject *[[c d] 0 *[[2 3] 0 *[subject 4 4 b]]]]
```

### Simplified Semantics
```
If *[subject b] equals 0:  return *[subject c]
If *[subject b] equals 1:  return *[subject d]
Otherwise: crash
```

### Human Description
The conditional branch. Evaluate test formula `b`; if true (0), evaluate and return `c`; if false (1), evaluate and return `d`. Crashes on non-boolean test results.

### Detailed Behavior
1. Evaluate `b` against the subject → must produce 0 or 1
2. If 0 (true): evaluate `c` against subject and return
3. If 1 (false): evaluate `d` against subject and return
4. Any other value crashes (enforced by the macro expansion)

### Examples

```nock
:: If 0 (true), return 10; else return 20
*[0 6 [0 1] [1 10] [1 20]]  → 10

:: If 1 (false), return 10; else return 20
*[1 6 [0 1] [1 10] [1 20]]  → 20

:: Conditional on cell test
*[[1 2] 6 [3 [0 1]] [1 "cell"] [1 "atom"]]  → "cell"
*[42 6 [3 [0 1]] [1 "cell"] [1 "atom"]]     → "atom"
```

### Common Patterns

```nock
:: Pattern: If x equals y, then a, else b
*[subject [6 [5 [0 x] [0 y]] formula-a formula-b]]

:: Pattern: If slot is a cell, then a, else b
*[subject [6 [3 [0 n]] formula-cell formula-atom]]

:: Pattern: Guard against zero (for decrement)
*[n [6 [5 [0 1] [1 0]] [1 crash] [decrement-formula]]]
```

### Why the Complex Macro?

The macro `*[a *[[c d] 0 *[[2 3] 0 *[a 4 4 b]]]]` works by:
1. `*[a 4 4 b]` → evaluates b, then adds 2 (so 0→2, 1→3)
2. `*[[2 3] 0 ...]` → uses result as address into `[2 3]`
3. `*[[c d] 0 ...]` → uses 2 or 3 as address into `[c d]`

This cleverly selects `c` (at address 2) for true, `d` (at address 3) for false.

### LLM Implementation Notes
- The test MUST produce exactly 0 or 1
- Only one branch is evaluated (short-circuit)
- The Hoon rune `?:` compiles to opcode 6
- Crashes enforce boolean discipline

---

## Opcode 7: Compose (Sequential)

### Formal Definition
```
*[subject 7 b c] → *[*[subject b] c]
```

### Human Description
Function composition. Evaluate `b` against the subject, then use that result as the subject for evaluating `c`. The classic "pipe" pattern.

### Detailed Behavior
1. Evaluate `b` against subject → intermediate noun
2. Evaluate `c` against that intermediate → final product

### Examples

```nock
:: Compose two increments
*[5 7 [4 0 1] [4 0 1]]     → 7    :: 5 → 6 → 7

:: Transform subject, then extract
*[[1 2] 7 [0 3] [0 1]]     → 2    :: Get tail, then get whole (which is 2)

:: Build structure, then index
*[42 7 [[0 1] [1 10]] [0 3]]  → 10  :: Make [42 10], get tail
```

### Common Patterns

```nock
:: Pattern: Chain transformations
*[x [7 transform1 [7 transform2 transform3]]]

:: Pattern: Set up context, then compute
*[input [7 [build-context] [main-computation]]]
```

### Relationship to Opcode 2

Opcode 7 is opcode 2 with a quoted formula:
```
*[a 7 b c] ≡ *[a 2 b [1 c]]
```

Opcode 7 exists because this pattern is extremely common.

### LLM Implementation Notes
- Think of it as "then" or "pipe"
- First formula changes the subject, second operates on new subject
- The Hoon rune `=>` compiles to opcode 7

---

## Opcode 8: Extend (Push)

### Formal Definition
```
*[subject 8 b c] → *[[*[subject b] subject] c]
```

### Human Description
Pin a new value to the head of the subject, then evaluate the body. This is how Nock implements variable binding—the new value becomes accessible at address 2.

### Detailed Behavior
1. Evaluate `b` against subject → new value
2. Construct `[new-value subject]` as the extended subject
3. Evaluate `c` against the extended subject

### Examples

```nock
:: Pin 10 to head, then get it
*[42 8 [1 10] [0 2]]        → 10   :: 10 is now at +2

:: Pin 10, still access original subject at +3
*[42 8 [1 10] [0 3]]        → 42   :: Original subject at +3

:: Pin computation result
*[5 8 [4 0 1] [0 2]]        → 6    :: Pin (5+1), return it

:: Pin and use both
*[5 8 [4 0 1] [[0 2] [0 3]]] → [6 5]  :: [pinned, original]
```

### Address Shift

After opcode 8, addresses shift:
- Address 2 → the new pinned value
- Address 3 → the original subject
- Address 6 → what was address 2
- Address 7 → what was address 3

### Common Patterns

```nock
:: Pattern: Local variable
*[data [8 [compute-value] [body-using-value-at-+2]]]

:: Pattern: Build a core (battery + payload)
*[context [8 [1 battery] [9 2 [0 1]]]]  :: Create core, invoke arm
```

### Relationship to Opcode 7

Opcode 8 extends the subject; opcode 7 replaces it:
```
*[a 7 b c]  →  *[*[a b] c]        :: New subject is *[a b]
*[a 8 b c]  →  *[[*[a b] a] c]   :: New subject is [*[a b] a]
```

### LLM Implementation Notes
- Primary mechanism for variable binding
- Creates nested scope structure
- The Hoon runes `=+`, `=/`, `=|` compile to opcode 8
- Essential for understanding core/gate construction

---

## Opcode 9: Invoke (Call)

### Formal Definition
```
*[subject 9 b c] → *[*[subject c] 2 [0 1] 0 b]
```

### Expanded Form
```
*[subject 9 b c] → *[*[subject c] *[*[subject c] [0 b]]]
```

### Human Description
The core invocation pattern. Produce a **core** (code + data bundle) from formula `c`, then execute the **arm** (code) at axis `b` within that core, with the core itself as subject.

### Understanding Cores

A **core** in Nock/Hoon is a cell `[battery payload]`:
- **Battery** (address 2): One or more formulas (the "arms")
- **Payload** (address 3): Data the formulas operate on

Opcode 9 is how you "call" a core's arm.

### Detailed Behavior
1. Evaluate `c` against subject → produces a core
2. Look up the formula at address `b` in the core (the arm)
3. Evaluate that formula with the core as subject
4. Return the result

### Examples

```nock
:: Simple: core with one arm that returns payload
*[42 9 2 [1 [[0 3] 100]]]
  :: Core is [[0 3] 100] (battery=[0 3], payload=100)
  :: Arm at +2 is [0 3], which gets the payload
  → 100

:: Increment arm
*[5 9 2 [1 [[4 0 3] 5]]]
  :: Core is [[4 0 3] 5]
  :: Arm [4 0 3] increments slot 3 (the payload)
  → 6

:: Multi-arm core
*[10 9 4 [1 [[[0 3] [4 0 3]] 10]]]
  :: Battery has two arms: [[0 3] [4 0 3]]
  :: Arm at +4 (head of head of battery... wait, +4 is head of battery head)
  :: Actually: +2 = battery, +4 = head of battery = [0 3]
  → 10
```

### Common Pattern: The Gate Call

A **gate** is a core with a specific structure for function calls:

```
[formula [sample context]]
   +2       +6     +7
```

Calling a gate:
```nock
*[gate-core 9 2 [0 1]]  :: Invoke arm at +2 with core as subject
```

### LLM Implementation Notes
- Opcode 9 is the standard function call mechanism
- `b` is typically 2 (the main arm)
- The Hoon expression `(gate arg)` compiles to opcode 9
- Understanding cores is key to understanding Hoon

---

## Opcode 10: Edit (Replace)

### Formal Definition
```
*[subject 10 [b c] d] → #[b *[subject c] *[subject d]]
```

Where `#` is the edit operator:
```
#[1 a b]           → a                           :: Replace whole
#[(a + a) b c]     → #[a [b /[(a + a + 1) c]] c] :: Edit head path
#[(a + a + 1) b c] → #[a [/[(a + a) c] b] c]     :: Edit tail path
```

### Human Description
Produce a modified copy of a noun by replacing the value at a specific address. This is how Nock achieves functional update—creating new versions with targeted changes.

### Detailed Behavior
1. `b` is the target address (atom)
2. Evaluate `c` against subject → the replacement value
3. Evaluate `d` against subject → the target structure
4. Return target with address `b` replaced by replacement

### Examples

```nock
:: Replace head of [1 2]
*[[[1 2] 99] 10 [2 [0 3]] [0 2]]  → [99 2]
  :: b=2, c=[0 3] produces 99, d=[0 2] produces [1 2]
  :: Replace address 2 of [1 2] with 99

:: Replace tail
*[[[1 2] 99] 10 [3 [0 3]] [0 2]]  → [1 99]

:: Replace deeply nested
*[[[[1 2] 3] 99] 10 [4 [0 3]] [0 2]]  → [[[99 2] 3]]
  :: Address 4 is head of head
```

### Common Patterns

```nock
:: Pattern: Update a slot in a structure
*[[old-data new-value] [10 [target-addr [0 3]] [0 2]]]

:: Pattern: Modify sample of a gate (for function call)
*[[gate arg] [10 [6 [0 3]] [0 2]]]  :: Put arg at +6 of gate
```

### Relationship to Gate Calls

The full Hoon function call `(gate arg)` is roughly:
```nock
[9 2 [10 [6 [1 arg]] [0 gate-addr]]]
:: Get gate, put arg in sample slot (+6), invoke
```

### LLM Implementation Notes
- Functional update: original is unchanged, new copy returned
- Address must be valid in the target structure
- The Hoon rune `%=` compiles to opcode 10
- Essential for modifying cores before invocation

---

## Opcode 11: Hint

### Formal Definition

Two forms:

**Static hint (atom hint):**
```
*[subject 11 b c] → *[subject c]
```

**Dynamic hint (cell hint):**
```
*[subject 11 [b c] d] → *[[*[subject c] *[subject d]] 0 3]
```

Which simplifies to:
```
*[subject 11 [b c] d] → *[subject d]  (after computing c)
```

### Human Description
Provide metadata to the interpreter without changing the computation result. Hints can trigger optimizations (jets), debugging output, or other interpreter-specific behaviors.

### Static Hints

When `b` is an atom, it's a simple tag that the interpreter may recognize:
```nock
*[subject 11 tag formula]  → *[subject formula]
```

The `tag` is noted by the interpreter, then `formula` is evaluated normally.

### Dynamic Hints

When the second argument is a cell `[tag clue]`:
```nock
*[subject 11 [tag clue] formula]
```

1. The `clue` formula is evaluated (its result may be used by the interpreter)
2. The `formula` is evaluated and returned
3. The hint tag and clue value are available to the interpreter

### Examples

```nock
:: Static hint (interpreter may or may not recognize 12345)
*[42 11 12345 [4 0 1]]  → 43

:: Dynamic hint (compute a clue, then proceed)
*[42 11 [12345 [1 "debugging"]] [4 0 1]]  → 43
```

### Common Hint Tags (in Urbit)

| Tag | Meaning | Usage |
|-----|---------|-------|
| `%fast` | Jet registration | Mark code for acceleration |
| `%memo` | Memoization | Cache results |
| `%slog` | Side-effect output | Print debugging info |
| `%mean` | Error annotation | Add context to crashes |
| `%spot` | Source location | Stack traces |

### Why Dynamic Hints Evaluate the Clue

The clue formula might crash! A correct Nock interpreter cannot skip it:
```nock
*[0 11 [1234 [4 0 1]] [1 99]]
:: Must attempt to evaluate [4 0 1] against 0 (crashes)
:: Even though the final result would be 99
```

### LLM Implementation Notes
- Hints don't change semantic results
- Practical interpreters use hints for jets (native code acceleration)
- Dynamic hints: clue is evaluated first, then discarded
- The Hoon `~` sig runes compile to opcode 11
- Critical for performance but semantically transparent

---

## Distribution (Implicit Cons)

### Formal Definition
```
*[subject [b c] d] → [*[subject b c] *[subject d]]
```

### Human Description
When a formula's head is a cell (not an atom/opcode), Nock treats both parts as separate formulas and returns a cell of their results.

### Detailed Behavior
- If formula is `[[x y] z]` where `[x y]` is a cell
- Evaluate `[x y]` as a formula → result A
- Evaluate `z` as a formula → result B
- Return `[A B]`

### Examples

```nock
:: Two constants
*[42 [[1 10] [1 20]]]  → [10 20]

:: Slot and increment
*[5 [[0 1] [4 0 1]]]   → [5 6]

:: Nested distribution
*[1 [[[0 1] [0 1]] [4 0 1]]]  → [[1 1] 2]
```

### Common Patterns

```nock
:: Build a cell of computed values
*[data [[compute-a] [compute-b]]]

:: Duplicate a value
*[x [[0 1] [0 1]]]  → [x x]
```

### LLM Implementation Notes
- This is NOT an opcode—it's a structural pattern
- Enables building data structures within formulas
- Equivalent to Lisp's `cons` as implicit operation
- Recognizable by cell-headed formulas

---

## Opcode Composition Patterns

### Pattern: Function Application

```nock
:: Apply gate to argument
[9 2 [10 [6 [1 arg]] [0 gate-slot]]]
```
1. Get gate from subject
2. Replace sample (slot 6) with argument
3. Invoke arm at slot 2

### Pattern: Loop/Recursion

```nock
:: Build core with loop body, invoke
[8 [1 loop-body] [9 2 [0 1]]]
```
1. Pin loop body to subject (creates core)
2. Invoke the body with core as subject
3. Body can recurse via `[9 2 [0 1]]`

### Pattern: Let Binding

```nock
:: Bind x = expr, then body
[8 expr body-using-x-at-+2]
```

### Pattern: Conditional Expression

```nock
:: If test then a else b
[6 test-formula formula-a formula-b]
```

### Pattern: Sequential Computation

```nock
:: Do A, then do B with result
[7 formula-a formula-b]
```

---

## Complete Nock 4K Specification

For reference, here is the complete specification:

```
Nock 4K

A noun is an atom or a cell.
An atom is a natural number.
A cell is an ordered pair of nouns.

Reduce by the first matching pattern; variables match any noun.

nock(a)            *a
[a b c]            [a [b c]]

?[a b]             0
?a                 1
+[a b]             +[a b]
+a                 1 + a
=[a a]             0
=[a b]             1

/[1 a]             a
/[2 a b]           a
/[3 a b]           b
/[(a + a) b]       /[2 /[a b]]
/[(a + a + 1) b]   /[3 /[a b]]
/a                 /a

#[1 a b]           a
#[(a + a) b c]     #[a [b /[(a + a + 1) c]] c]
#[(a + a + 1) b c] #[a [/[(a + a) c] b] c]
#a                 #a

*[a [b c] d]       [*[a b c] *[a d]]

*[a 0 b]           /[b a]
*[a 1 b]           b
*[a 2 b c]         *[*[a b] *[a c]]
*[a 3 b]           ?*[a b]
*[a 4 b]           +*[a b]
*[a 5 b c]         =[*[a b] *[a c]]

*[a 6 b c d]       *[a *[[c d] 0 *[[2 3] 0 *[a 4 4 b]]]]
*[a 7 b c]         *[*[a b] c]
*[a 8 b c]         *[[*[a b] a] c]
*[a 9 b c]         *[*[a c] 2 [0 1] 0 b]
*[a 10 [b c] d]    #[b *[a c] *[a d]]
*[a 11 [b c] d]    *[[*[a c] *[a d]] 0 3]
*[a 11 b c]        *[a c]

*a                 *a
```

---

## Quick Reference Table

| Op | Name | Signature | Purpose | Hoon |
|----|------|-----------|---------|------|
| 0 | Slot | `[0 b]` | Tree address lookup | `.` `+n` |
| 1 | Constant | `[1 b]` | Return literal value | Literals |
| 2 | Evaluate | `[2 b c]` | Dynamic nock | `.*` |
| 3 | Cell? | `[3 b]` | Test if cell | `.?` |
| 4 | Increment | `[4 b]` | Add 1 to atom | `.+` |
| 5 | Equal? | `[5 b c]` | Deep equality test | `.=` |
| 6 | If | `[6 b c d]` | Conditional branch | `?:` |
| 7 | Compose | `[7 b c]` | Sequential/pipe | `=>` |
| 8 | Extend | `[8 b c]` | Pin to subject | `=+` `=/` |
| 9 | Invoke | `[9 b c]` | Core arm call | `%-` |
| 10 | Edit | `[10 [b c] d]` | Functional update | `%=` |
| 11 | Hint | `[11 b c]` | Interpreter hint | `~` runes |

---

## Further Reading

- [Urbit Documentation: Nock Specification](https://docs.urbit.org/nock/specification)
- [Urbit Core Academy: Evaluating Nock](https://docs.urbit.org/build-on-urbit/core-academy/ca00)
- [Nockchain: What is Nock ISA?](https://docs.nockchain.org/nockapp/what-is-nock-isa)