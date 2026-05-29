# Loobeans

Loobeans are Nock's conventional representation of truth values.  Nock takes `0` to mean `TRUE` and `1` to mean `FALSE`.

While this is the opposite of many contemporary programming languages, it aligns with aspects of traditional logic and historic usage.

* [Claude Shannon](https://circeinstitute.org/blog/shannon-part-1/):  “He assigns open switches (i.e. in the “off” position) a value of 1 and closed switches (i.e. in the “on” position) a value of 0.”  (Describing [Shannon (1948), “A Mathematical Theory of Communication”, _The Bell System Technical Journal_ volume 27, pp. 379–423, 623–656](https://people.math.harvard.edu/~ctm/home/text/others/shannon/entropy/entropy.pdf).)
* C programs return `0` to indicate success (truth) and non-zero to indicate failure (falsehood).

Other reasons have been adduced, but the dependence is baked deeply into Nock in any case.  This choice can be confusing to newcomers, and affordances tend to exist in runtimes and higher-level languages to mask a need to think about specific values for `TRUE` and `FALSE`.

## See Also

The opcodes that produce or consume loobeans:

* [Opcode 3 (Cell Check)](opcode-3.ipynb) — returns `0` if its argument is a cell, `1` if an atom.
* [Opcode 5 (Equality Check)](opcode-5.ipynb) — returns `0` if its two arguments are equal, `1` otherwise.
* [Opcode 6 (Conditional)](opcode-6.ipynb) — branches on a loobean, taking the second formula if `0`, the third if `1`.

## Further Reading

* [Stephen Wolfram (2015), “George Boole:  A 200-Year View”](https://writings.stephenwolfram.com/2015/11/george-boole-a-200-year-view/)
