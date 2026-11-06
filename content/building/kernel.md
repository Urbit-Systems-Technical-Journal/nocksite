# Kernels

A kernel is an executable Nock noun that has computable arms at certain axes of its core.  These arms can be invoked by a runtime to perform computations, manage state, and interact with the outside world.  A state is maintained with the kernel (in practice, the core type is what we call a “door”, or core with a sample), and the kernel's arms can read from and write to this state as needed.

The most common kernel shape is a core with arms at certain fixed axes:

* `+4` is the `+load` arm, which handles loading and upgrading the kernel state.  It accepts the current state type and returns a state of the kernel's most up-to-date type.
* `+10` is the `+wish` arm, which evaluates Hoon expressions against the current state.  It accepts a core to evaluate against the kernel's state (this varies by runtime).  One use for `+wish` is to read out the version of a standard library for compatibility checks on upgrades.
* `+22` is the `+peek` arm, which provides read-only access to the kernel state.  It accepts a `path` (list of text atoms) and returns the value corresponding to that path within the kernel's state.
* `+23` is the `+poke` arm, which processes state-altering requests.  It accepts a `cause` (formatted noun) and returns a cell of effects and the new kernel state.

The arm order arises naturally from the `+$set` type used in Hoon, which orders the arms according to a hash of each name.  Notice that they are all in the `battery` of the core, nested under axis `+2`.

* [NockApp's kernel](https://docs.nockchain.org/reference-kernel/architecture#kernel-structure)
* [Urbit's Arvo kernel](https://docs.urbit.org/urbit-os/kernel/arvo)

## `+peek` Read-Only Access

`+22`/`+peek` accepts a `path`, or list of text atoms, `(list knot)`.  Its invocation from a kernel results in a `(unit (unit noun))`, where:

* `~` means a result is not currently available (block).

* `[~ ~]` means a result will never become available (halt).

* `[~ ~ noun]` means a successful result.  The caller unwraps it twice (the tail of the tail) to get the raw noun.

Because peeks are read-only, they can be cached for efficiency.  Peeks are often called “scries” in Urbit terminology.

## `+poke` State-Altering Requests

`+23`/`+poke` accepts a `cause` or `move` and processes them; this is the only arm that actually alters Arvo’s state.  It results in a `[(list effects) new-state]`.

The runtime is generally responsible to queue `cause`s and call `+poke` serially, ensuring that state changes are atomic and consistent.  The kernel processes each `cause` in order, producing a new state each time.

## A Simple Kernel

The simplest possible kernel is one that does nothing; we will write one that simply returns its state unchanged for `+load` and `+poke`, crashes on `+wish`, and returns `~`/`0` for `+peek`.

```{nockmark}
:caption: A kernel that does nothing.  `S` is the subject it is built from.
[8 {{[1 0]|st}}
%% note st push the state (the sample), 0 by default: the subject is `[0 S]`
   [1
     {{[8 [1 0] [1 0 6] 0 1]|load}}
%% note load `+load`, axis 4: a gate whose arm `[0 6]` returns its sample, the old state
     {{[0 0]|wish}}
%% note wish `+wish`, axis 10: `[0 0]` crashes whenever it runs
     {{[8 [1 0] [1 1 0] 0 1]|peek}}
%% note peek `+peek`, axis 22: a gate whose arm `[1 0]` returns `~` for any path
     {{8 [1 0] [1 [1 0] 0 30] 0 1|poke}}]
%% note poke `+poke`, axis 23: a gate that returns `[~ state]` (the state is at 30 inside it)
   {{0 1|ctx}}]
%% note ctx the context: the core is `[battery [0 S]]`, with the state at 6 and `S` at 7
```

Each arm is itself a gate builder:  `[8 [1 0] [1 <arm>] 0 1]` pushes a default sample of 0 and returns the gate `[<arm> 0 <kernel>]`, so the kernel sits at axis 7 of every gate it builds.  Inside the `+poke` gate the kernel's state is at axis 30 (axis 6 of the kernel at axis 7), and the arm `[[1 0] 0 30]` builds the cell `[~ state]`.

<!-- 
```hoon
|_  old=*
++  load
  |=  [old=*]
  ^+  old
  old
++  wish  !!
++  peek
  |=  path=(list knot)
  ^-  (unit (unit noun))
  ~
++  poke
  |=  cause=*
  ^-  [(list noun) *]
  [~ old]
--
```
 -->

A runtime would evaluate this kernel by supplying it with an actual state (sample) at axis `+6` (with context/stdlib at `+7`), then invoking its arms as needed.

## Calling an Arm

Here is a `+poke` as a runtime would make it, written out in Nock.  `K` is the kernel formula above, the kernel's state is set to 33, and the cause is 99:

```{nockmark}
[7 {{<K>|k}}
%% note k build the kernel core `[battery [0 S]]`
   7 {{[10 [6 1 33] 0 1]|s}}
%% note s set its state (axis 6) to 33
   8 {{[9 23 0 1]|g}}
%% note g run arm 23 to build the `+poke` gate, and push it: the subject is `[gate kernel]`
   9 2 {{10 [6 1 99] 0 2|c}}]
%% note c set the gate's sample to the cause, 99, and run its arm: `[0 33]`
```

The result is `[0 33]`:  no effects (`~`), and the state 33, unchanged.  A `+peek` is made the same way with arm 22 and a path as the sample, and returns `0`, which is `~`.
