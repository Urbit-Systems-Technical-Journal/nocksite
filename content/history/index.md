# History of Nock

Nock is a combinator calculus designed by Curtis Yarvin from 2002 onwards and elaborated subsequently by other contributors (including ~rovnys-ricfer and ~fodwyt-ragful for 4K).  While it has undergone several revisions, all have in common these design principles:

1. Pragmatic minimalism:  as simple as viable, and no simpler.
2. Functional purity:  no undefined behavior, no side effects except via explicit runtime hints.
3. Homoiconicity:  code and data share the same representation.
4. Virtualizability:  the ability to extend the base language via first-class virtualization.
5. Namespace extension:  the ability to step beyond apparent scope restrictions using referential transparency.

Namespace extension also implies hyper-Turing completeness:  a system architected on Nock can build a virtualization function that has the ability to answer, in certain cases, whether or not the computation will halt.

* [~lagrev-nocfep, ~sorreg-namtyv (2025), “A Documentary History of the Nock Combinator Calculus”](https://urbitsystems.tech/article/v02-i01/a-documentary-history-of-the-nock-combinator-calculus)

Specific historical revisions of Nock are mirrored here as documents of historical significance.

## Nock Versions

Nock versions count _downwards_ following a theory called “kelvin versioning”, in which the protocol “freezes” over time as a commitment to future stability.  While four more revisions are in principle possible, it is unlikely that Nock will ever change again.

* [Nock 4K (2018)](../specification/index.md), the current specification.
* [Nock 5K (2012)](./nock-5k.md)
* [Nock 6K (2011)](./nock-6k.md)
* [Nock 7K (2010)](./nock-7k.md)
* [Nock 8K (2010)](./nock-8k.md)
* [Nock 9K (2010)](./nock-9k.md)
* [Nock 10K (2008)](./nock-10k.md)
* [Nock 11K (2008)](./nock-11k.md)
* [Nock 12K (2008)](./nock-12k.md)
* [Nock 13K (2008)](./nock-13k.md)
* [U: a small model (2006)](./u-model.md)
