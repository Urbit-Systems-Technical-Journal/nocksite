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

```
[ 8
  :: sample, default of constant 0
  [1 0]
  :: arms
  [1 
     :: +load, +4
     [8 [1 0] [1 0 6] 0 1]
     :: +wish, +10
     [0 0]
     :: +peek, +22
     [8 [1 0] [1 1 0] 0 1]
     :: +poke, +23
     8 [1 0] [1 [1 0] 0 30] 0 1]
  0
  1
]
```

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
