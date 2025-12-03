# U:  A Small Model

```
U: Definition

1 Purpose
    This document defines the U function and its data
    model.

2 License
    U is in the public domain.

3 Status
    This text is a DRAFT (version 0.15).

4 Data
    A value in U is called a "term."  There are three
    kinds of term: "number," "pair," and "foo."

    A number is any natural number (ie, nonnegative
    integer).

    A pair is an ordered pair of any two terms.

    There is only one foo.

5 Syntax
    U is a computational model, not a programming
    language.

    But a trivial ASCII syntax for terms is useful.

5.1 Trivial syntax: briefly
    Numbers are in decimal.  Pairs are in parentheses
    that nest to the right.  Foo is "~".

    Whitespace is space or newline.  Line comments
    use "#".

5.2 Trivial syntax: exactly
    term    : number
            | 40 ?white pair ?white 41
            | foo

    number  : 48
            | [49-57] *[48-57]

    pair    : term white term
            | term white pair

    foo     : 126

    white   : *(32 | 10 | (35 *[32-126] 10))

6 Semantics
    U is a pure function from term to term.

    This document completely defines U.  There is no
    compatible way to extend or revise U.

6.1 Rules
    [name]   [pattern]                [definition]

    (a)      ($a 0 $b)                $b
    (b)      ($a 1 $b $c)             1
    (c)      ($a 1 $b)                0
    (d)      ($a 2 0 $b $c)           $b
    (e)      ($a 2 %n $b $c)          $c
    (f)      ($a 3 $b $c)             =($b $c)
    (g)      ($a 4 %n)                +%n

    (h)      ($a 5 (~ ~ $b) $c)       $b
    (i)      ($a 5 (~ $b $c) $d)      *($a $b $c $d)
    (j)      ($a 5 (~ ~) $b)          ~
    (k)      ($a 5 (~ $b) $c)         *($a $b $c)
    (l)      ($a 5 ($b $c) $d)
                            (*($a $b $d) *($a $c $d))
    (m)      ($a 5 $b $c)             $b

    (n)      ($a 6 $b $c)   *($a *($a 5 $b $c))
    (o)      ($a 7 $b)                *($a 5 $a $a $b)
    (p)      ($a 8 $b $c $d)          >($b $c $d)

    (q)      ($a $b $c)     *($a 5 *($a 7 $b) $c)
    (r)      ($a $b)                  *($a $b)
    (s)      $a                       *$a

    The rule notation is a pseudocode, only used in
    this file. Its definition follows.

6.2 Rule pseudocode: briefly
    Each line is a pattern match.  "%" means
    "number."  Match in order.  See operators below.

6.3 Rule pseudocode: exactly
    Both pattern and definition use the same
    evaluation language, an extension of the trivial
    syntax.

    An evaluation is a tree in which each node is a
    term, a term-valued variable, or a unary
    operation.

    Variables are symbols marked with a constraint.
    A variable "$name" matches any term.  "%name"
    matches any number.

    There are four unary prefix operators, each of
    which is a pure function from term to term: "=",
    "+", "*", and ">". Their semantics follow.

6.4 Evaluation semantics
    For any term $term, to compute U($term):

        - find the first pattern, in order, that
          matches $term.
        - substitute its variable matches into its
          definition.
        - compute the substituted definition.

    Iff this sequence of steps terminates, U($term)
    "completes." Otherwise it "chokes."

    Evaluation is strict: incorrect completion is a
    bug.  Choking is U's only error or exception
    mechanism.

6.5 Simple operators: equal, increment, evaluate
    =($a $b) is 0 if $a and $b are equal; 1 if they
    are not.

    +%n is %n plus 1.

    *$a is U($a).

6.6 The follow operator
    >($a $b $c) is always 0.  But it does not always
    complete.

    We say "$c follows $b in $a" iff, for every $term:

        if *($a 5 $b $term) chokes:
            *($a 5 $c $term) chokes.

        if *($a 5 $b $term) completes:
            either:
                *($a 5 $c $term) completes, and
                *($a 5 $c $term) equals
                  *($a 5 $b $term)
            or:
                *($a 5 $c $term) chokes.

    If $c follows $b in $a, >($a $b $c) is 0.

    If this statement cannot be shown (ie, if there
    exists any $term that falsifies it, generates an
    infinitely recursive series of follow tests, or is
    inversely self-dependent, ie, exhibits Russell's
    paradox), >($a $b $c) chokes.

7 Implementation issues
    This section is not normative.

7.1 The follow operator
    Of course, no algorithm can completely implement
    the follow operator.  So no program can completely
    implement U.

    But this does not stop us from stating the
    correctness of a partial implementation - for
    example, one that assumes a hardcoded set of
    follow cases, and fails when it would otherwise
    have to compute a follow case outside this set.

    U calls this a "trust failure."  One way to
    standardize trust failures would be to standardize
    a fixed set of follow cases as part of the
    definition of U.  However, this is equivalent to standardizing a fixed trusted code base.  The
    problems with this approach are well-known.

    A better design for U implementations is to
    depend on a voluntary, unstandardized failure
    mechanism.  Because all computers have bounded
    memory, and it is impractical to standardize a
    fixed memory size and allocation strategy, every
    real computing environment has such a mechanism.

    For example, packet loss in an unreliable packet
    protocol, such as UDP, is a voluntary failure
    mechanism.

    If the packet transfer function of a stateful UDP
    server is defined in terms of U, failure to
    compute means dropping a packet.  If the server
    has no other I/O, its semantics are completely
    defined by its initial state and packet function.

7.2 Other unstandardized implementation details
    A practical implementation of U will detect and
    log common cases of choking.  It will also need a
    timeout or some other unspecified mechanism to
    abort undetected infinite loops.

    (Although trust failure, allocation failure or
    timeout, and choke detection all depend on what
    is presumably a single voluntary failure
    mechanism, they are orthogonal and should not be
    confused.)

    Also, because U is so abstract, differences in
    implementation strategy can result in performance
    disparities which are almost arbitrarily extreme.
    The difficulty of standardizing performance is
    well-known.

    No magic bullet can stop these unstandardized
    issues from becoming practical causes of lock-in
    and incompatibility. Systems which depend on U
    must manage them at every layer.
```

* [Source](https://web.archive.org/web/20060701070718/http://urbit.sourceforge.net/u.txt)
